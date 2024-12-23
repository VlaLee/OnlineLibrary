---
--- СОЗДАНИЕ ТРИГГЕР-ФУНКЦИЙ И ТРИГГЕРОВ
---


CREATE OR REPLACE FUNCTION online_library_functional.track_saving_data() RETURNS TRIGGER AS $$
BEGIN
	NEW.saving_date = now();
	RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_saving_date BEFORE INSERT ON online_library_tables.saving
	FOR EACH ROW EXECUTE PROCEDURE online_library_functional.track_saving_data();


CREATE OR REPLACE FUNCTION online_library_functional.update_book_rating() RETURNS TRIGGER AS $$
BEGIN
	UPDATE online_library_tables.book
	SET rating = (
		SELECT AVG (rating)::numeric(4, 2)
		FROM online_library_tables.saving
		WHERE book_id = NEW.book_id
	)
	WHERE book_id = NEW.book_id;

	RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_book_rating AFTER UPDATE OR DELETE ON online_library_tables.saving
	FOR EACH ROW EXECUTE PROCEDURE online_library_functional.update_book_rating();


CREATE OR REPLACE FUNCTION online_library_functional.update_author_rating() RETURNS TRIGGER AS $$
DECLARE
	searched_author_id int;
BEGIN
	-- Находим нужного автора через таблицы book и book_author
	SELECT online_library_tables.book_author.author_id
	INTO searched_author_id
	FROM online_library_tables.book
		INNER JOIN online_library_tables.book_author USING (book_id)
	WHERE online_library_tables.book.book_id = NEW.book_id
	LIMIT 1;

	-- Обновляем рейтинг автора
	UPDATE online_library_tables.author
	SET rating = (
		SELECT AVG (online_library_tables.book.rating)::numeric(4, 2)
		FROM online_library_tables.book
			INNER JOIN online_library_tables.book_author USING (book_id)
		WHERE online_library_tables.book_author.author_id = searched_author_id
	)
	WHERE author_id = searched_author_id;
	
	RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_author_rating AFTER UPDATE OR DELETE ON online_library_tables.book
	FOR EACH ROW EXECUTE PROCEDURE online_library_functional.update_author_rating();


CREATE OR REPLACE FUNCTION online_library_functional.delete_books_after_author_delete() RETURNS TRIGGER AS $$
BEGIN
   DELETE FROM online_library_tables.book
   WHERE book_id IN (
      SELECT book_id
      FROM online_library_tables.book_author
      WHERE author_id = OLD.author_id
   );
   RETURN OLD;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_delete_books_after_author_delete BEFORE DELETE ON online_library_tables.author
	FOR EACH ROW EXECUTE FUNCTION online_library_functional.delete_books_after_author_delete();


---
--- ФУНКЦИЯ НА ВЫВОД СОДЕРЖИМОГО ТАБЛИЦ
---


-- получить все данные из всех таблиц в формате json
CREATE OR REPLACE FUNCTION online_library_functional.get_all_data_from_tables()
RETURNS TABLE(table_name text, row_data jsonb) AS $$
DECLARE
    table_record record;
    select_query text;
BEGIN
    FOR table_record IN (
        SELECT information_schema.tables.table_name
        FROM information_schema.tables
        WHERE table_schema = 'online_library_tables' AND table_type = 'BASE TABLE'
	)
    LOOP
        select_query = format('SELECT ''%s'' AS table_name, row_to_json(t)::jsonb FROM online_library_tables.%I t',
						table_record.table_name,
						table_record.table_name);
        RETURN QUERY EXECUTE select_query;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


-- получение всех данных по названию таблицы в формате json
CREATE OR REPLACE FUNCTION online_library_functional.get_all_data_from_table_by_table_name(table_name text)
RETURNS jsonb AS $$
DECLARE
	select_query text;
	result_info jsonb;
BEGIN
	select_query = format('SELECT jsonb_agg(t) FROM online_library_tables.%I t', table_name);
	EXECUTE select_query INTO result_info;

	RETURN COALESCE(result_info, '[]'::jsonb);
END
$$ LANGUAGE plpgsql;


-- получение всех данных из таблицы saving в "красивом" формате + в формате json
CREATE OR REPLACE FUNCTION online_library_functional.get_all_data_from_table_saving()
RETURNS jsonb AS $$
BEGIN
    RETURN (
        SELECT jsonb_agg(jsonb_build_object(
            'saving_id', s.saving_id,
			'saving_date', s.saving_date,
			'user_rating', s.rating,
            'title', b.title,
            'genre', b.genre,
            'first_name', a.first_name,
            'last_name', a.last_name,
            'patronymic', a.patronymic,
			'publisher_name', p.publisher_name
        ))
        FROM online_library_tables.saving s
			INNER JOIN online_library_tables.book b USING (book_id)
			INNER JOIN online_library_tables.book_author ba USING (book_id)
			INNER JOIN online_library_tables.author a USING (author_id)
			INNER JOIN online_library_tables.publisher p USING (publisher_id)
    );
END
$$ LANGUAGE plpgsql;

---
--- ФУНКЦИИ НА ОЧИЩЕНИЕ ТАБЛИЦ
---


-- очищение таблицы по ее имени
CREATE OR REPLACE FUNCTION online_library_functional.truncate_table_by_name(table_name text) RETURNS VOID AS $$
BEGIN
	EXECUTE format('TRUNCATE TABLE online_library_tables.%I RESTART IDENTITY CASCADE', table_name);
END
$$ LANGUAGE plpgsql;


-- очищение всех таблиц
CREATE OR REPLACE FUNCTION online_library_functional.truncate_all_tables() RETURNS VOID AS $$
DECLARE
	table_name text;
BEGIN
	FOR table_name IN (
		SELECT information_schema.tables.table_name
		FROM information_schema.tables
		WHERE table_schema = 'online_library_tables' AND table_type = 'BASE TABLE'
	)
	LOOP
		EXECUTE format('TRUNCATE TABLE online_library_tables.%I RESTART IDENTITY CASCADE', table_name);
	END LOOP;
END
$$ LANGUAGE plpgsql;


---
--- ФУНКЦИИ НА ДОБАВЛЕНИЕ ДАННЫХ В ТАБЛИЦЫ
---


-- добавление в таблицу user
CREATE OR REPLACE FUNCTION online_library_functional.insert_into_table_user(
	in_first_name varchar(256),
	in_last_name varchar(256),
	in_phone varchar(256),
	in_email varchar(256),
	in_password varchar(256),
	in_is_admin boolean DEFAULT false,
	in_patronymic varchar(256) DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
	INSERT INTO online_library_tables.user (first_name, last_name, patronymic, phone, email, user_password, is_admin)
	VALUES (in_first_name, in_last_name, in_patronymic, in_phone, in_email, in_password, in_is_admin);
EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка при добавлении пользователя: %', SQLERRM;
END
$$ LANGUAGE plpgsql;


-- добавление в таблицу saving
CREATE OR REPLACE FUNCTION online_library_functional.insert_into_table_saving(
	in_user_id int,
	in_book_id int
) RETURNS VOID AS $$
BEGIN
	INSERT INTO online_library_tables.saving (user_id, book_id)
	VALUES (in_user_id, in_book_id);
EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка при добавлении пользовательского сохранения: %', SQLERRM;
END
$$ LANGUAGE plpgsql;


-- добавление в таблицу book
CREATE OR REPLACE FUNCTION online_library_functional.insert_into_table_book(
	in_title varchar(256),
	in_genre varchar(64),
	in_publisher_id int,
	in_publication_year int
) RETURNS VOID AS $$
BEGIN
	INSERT INTO online_library_tables.book (title, genre, publisher_id, publication_year)
	VALUES (in_title, in_genre, in_publisher_id, in_publication_year);
EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка при добавлении книги: %', SQLERRM;
END
$$ LANGUAGE plpgsql;


-- добавление в таблицу publisher
CREATE OR REPLACE FUNCTION online_library_functional.insert_into_table_publisher(
	in_publisher_name varchar(64),
	in_city varchar(64),
	in_address varchar(256),
	in_email varchar(256)
) RETURNS VOID AS $$
BEGIN
	INSERT INTO online_library_tables.publisher (publisher_name, city, address, email)
	VALUES (in_publisher_name, in_city, in_address, in_email);
EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка при добавлении издательства: %', SQLERRM;
END
$$ LANGUAGE plpgsql;


-- добавление в таблицу book_author 
CREATE OR REPLACE FUNCTION online_library_functional.insert_into_table_book_author(
	in_book_id int,
	in_author_id int
) RETURNS VOID AS $$
BEGIN
	INSERT INTO online_library_tables.book_author (book_id, author_id)
	VALUES (in_book_id, in_author_id);
EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка при добавлении связи ''книга - автор'': %', SQLERRM;
END
$$ LANGUAGE plpgsql;


-- добавление в таблицу author
CREATE OR REPLACE FUNCTION online_library_functional.insert_into_table_author(
	in_first_name varchar(64),
	in_last_name varchar(64),
	in_patronymic varchar(64) DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
	INSERT INTO online_library_tables.author (first_name, last_name, patronymic)
	VALUES (in_first_name, in_last_name, in_patronymic);
EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка при добавлении автора: %', SQLERRM;
END
$$ LANGUAGE plpgsql;


---
--- ФУНКЦИИ НА ОБНОВЛЕНИЕ ЗНАЧЕНИЙ
---


-- обновление телефона в таблице user по user_id
CREATE OR REPLACE FUNCTION online_library_functional.update_phone_into_table_user(in_user_id int,
	in_phone varchar(256)) RETURNS VOID AS $$
BEGIN
	UPDATE online_library_tables.user
	SET phone = in_phone
	WHERE user_id = in_user_id;
EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка [user_id = %] при изменении номера телефона пользователя: %', in_user_id, SQLERRM;
END
$$ LANGUAGE plpgsql;


-- обновление электронной почты в таблице user по user_id
CREATE OR REPLACE FUNCTION online_library_functional.update_email_into_table_user(in_user_id int,
	in_email varchar(256)) RETURNS VOID AS $$
BEGIN
	UPDATE online_library_tables.user
	SET email = in_email
	WHERE user_id = in_user_id;
EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка [user_id = %] при изменении адреса электронной почты пользователя: %', in_user_id, SQLERRM;
END
$$ LANGUAGE plpgsql;


-- установление отчества (если его не было при регистрации) в таблице user по user_id
CREATE OR REPLACE FUNCTION online_library_functional.set_patronymic_into_table_user(in_user_id int,
	in_patronymic varchar(256)) RETURNS VOID AS $$
DECLARE
	current_patronymic varchar(256);
BEGIN
	SELECT patronymic
	INTO current_patronymic
	FROM online_library_tables.user
	WHERE user_id = in_user_id;

	IF current_patronymic IS NULL THEN
		UPDATE online_library_tables.user
		SET patronymic = in_patronymic
		WHERE user_id = in_user_id;
	ELSE
		RAISE EXCEPTION 'Ошибка [user_id = %]: поле "отчество" уже заполнено', in_user_id;
	END IF;
EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка [user_id = %] при изменении отчества пользователя: %', in_user_id, SQLERRM;
END
$$ LANGUAGE plpgsql;


-- установление рейтинга книге пользователем по saving_id
CREATE OR REPLACE FUNCTION online_library_functional.set_rating_into_table_saving(in_saving_id int,
	in_rating numeric(4, 2)) RETURNS VOID AS $$
BEGIN
	UPDATE online_library_tables.saving
	SET rating = in_rating
	WHERE saving_id = in_saving_id;
EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка [saving_id = %] при попытке пользователем выставить рейтинг: %', in_saving_id, SQLERRM;
END
$$ LANGUAGE plpgsql;


-- обновление книги в таблице book
CREATE OR REPLACE FUNCTION online_library_functional.update_into_table_book(
	in_book_id int,
	in_title varchar(256),
	in_genre varchar(64),
	in_publisher_id int,
	in_publication_year int
) RETURNS VOID AS $$
BEGIN
	UPDATE online_library_tables.book
	SET title = in_title,
		genre = in_genre,
		publisher_id = in_publisher_id,
		publication_year = in_publication_year
	WHERE in_book_id = book_id;
EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка [book_id = %] при обновлении книги: %', in_book_id, SQLERRM;
END
$$ LANGUAGE plpgsql;


-- обновление издательства в таблице publisher
CREATE OR REPLACE FUNCTION online_library_functional.update_into_table_publisher(
	in_publisher_id int,
	in_publisher_name varchar(64),
	in_city varchar(64),
	in_address varchar(256),
	in_email varchar(256)
) RETURNS VOID AS $$
BEGIN
	UPDATE online_library_tables.publisher
	SET publisher_name = in_publisher_name,
		city = in_city,
		address = in_address,
		email = in_email
	WHERE publisher_id = in_publisher_id;
EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка [publisher_id = %] при обновлении издательства: %', in_publisher_id, SQLERRM;
END
$$ LANGUAGE plpgsql;


-- обновление в таблице book_author
CREATE OR REPLACE FUNCTION online_library_functional.update_into_table_book_author(
	old_book_id int,
	old_author_id int,
	new_book_id int,
	new_author_id int
) RETURNS VOID AS $$
BEGIN
	UPDATE online_library_tables.book_author
	SET book_id = new_book_id,
		author_id = new_author_id
	WHERE book_id = old_book_id AND author_id = old_author_id;
EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка [book_id = %, author_id = %] при изменении связи ''книга - автор'': %',
		old_book_id, old_author_id, SQLERRM;
END
$$ LANGUAGE plpgsql;


-- обновление автора в таблице author
CREATE OR REPLACE FUNCTION online_library_functional.update_into_table_author(
	in_author_id int,
	in_first_name varchar(64),
	in_last_name varchar(64),
	in_patronymic varchar(64)
) RETURNS VOID AS $$
BEGIN
	UPDATE online_library_tables.author
	SET first_name = in_first_name,
		last_name = in_last_name,
		patronymic = in_patronymic
	WHERE author_id = in_author_id;
EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка [author_id = %] при изменении автора: %', in_author_id, SQLERRM;
END
$$ LANGUAGE plpgsql;


---
--- ФУНКЦИИ ДЛЯ ПОИСКА
---


-- поиск по имени таблицы, названию первичного ключа этой таблицы и первичному ключу
CREATE OR REPLACE FUNCTION online_library_functional.find_row_by_id(table_name text, pk_column text, id int)
RETURNS jsonb AS $$
DECLARE
	select_query text;
	result_row jsonb;
BEGIN
	select_query = format('SELECT row_to_json(t)::jsonb FROM online_library_tables.%I t WHERE t.%I = %L', table_name, pk_column, id);
	EXECUTE select_query INTO result_row;
	
	IF result_row IS NULL THEN
		RAISE EXCEPTION 'Ошибка: строка с id = % не найден в таблице %', id, table_name;
	END IF;

	RETURN result_row;
END
$$ LANGUAGE plpgsql;


-- поиск книг по жанру
CREATE OR REPLACE FUNCTION online_library_functional.search_books_by_genre(in_genre varchar(64))
RETURNS jsonb AS $$
DECLARE
    in_genre_lower varchar(64);
BEGIN
    in_genre_lower = LOWER(in_genre);

    RETURN (
        SELECT jsonb_agg(jsonb_build_object(
            'book_id', book_id,
            'title', title,
            'genre', genre,
            'rating', rating,
            'publisher_id', publisher_id,
            'publication_year', publication_year
        ))
        FROM online_library_tables.book
        WHERE LOWER(online_library_tables.book.genre) = in_genre_lower
    );
END;
$$ LANGUAGE plpgsql;


-- поиск книг по названию
CREATE OR REPLACE FUNCTION online_library_functional.search_books_by_title(in_title varchar(256))
RETURNS jsonb AS $$
DECLARE
    in_title_lower varchar(256);
BEGIN
    in_title_lower = LOWER(in_title);

    RETURN (
        SELECT jsonb_agg(jsonb_build_object(
            'book_id', book_id,
            'title', title,
            'genre', genre,
            'rating', rating,
            'publisher_id', publisher_id,
            'publication_year', publication_year
        ))
        FROM online_library_tables.book
        WHERE LOWER(online_library_tables.book.title) = in_title_lower
    );
END;
$$ LANGUAGE plpgsql;


-- поиск книг по авторам (имя, либо фамилия, либо отчество)
CREATE OR REPLACE FUNCTION online_library_functional.search_books_by_author_nsp(in_author_nsp varchar(64))
RETURNS jsonb AS $$
DECLARE
    in_author_nsp_lower varchar(64);
BEGIN
    in_author_nsp_lower = LOWER(in_author_nsp);

    RETURN (
        SELECT jsonb_agg(jsonb_build_object(
            'book_id', b.book_id,
            'title', b.title,
            'genre', b.genre,
            'rating', b.rating,
            'publisher_id', b.publisher_id,
            'publication_year', b.publication_year
        ))
        FROM online_library_tables.book b
        INNER JOIN online_library_tables.book_author ba ON b.book_id = ba.book_id
        INNER JOIN online_library_tables.author a ON ba.author_id = a.author_id
        WHERE LOWER(a.first_name) = in_author_nsp_lower 
           OR LOWER(a.last_name) = in_author_nsp_lower
           OR LOWER(a.patronymic) = in_author_nsp_lower
    );
END;
$$ LANGUAGE plpgsql;


-- поиск книг по издательствам
CREATE OR REPLACE FUNCTION online_library_functional.search_books_by_publisher_name(in_publisher_name varchar(64))
RETURNS jsonb AS $$
DECLARE
    in_publisher_name_lower varchar(64);
BEGIN
    in_publisher_name_lower = LOWER(in_publisher_name);

    RETURN (
        SELECT jsonb_agg(jsonb_build_object(
            'book_id', b.book_id,
            'title', b.title,
            'genre', b.genre,
            'rating', b.rating,
            'publisher_id', b.publisher_id,
            'publication_year', b.publication_year
        ))
        FROM online_library_tables.book b
        INNER JOIN online_library_tables.publisher p ON b.publisher_id = p.publisher_id
        WHERE LOWER(p.publisher_name) = in_publisher_name_lower
    );
END;
$$ LANGUAGE plpgsql;


-- поиск авторов по имени/фамилии/отчеству
CREATE OR REPLACE FUNCTION online_library_functional.search_authors_by_author_nsp(in_author_nsp varchar(64))
RETURNS jsonb AS $$
DECLARE
    in_author_nsp_lower varchar(64);
BEGIN
    in_author_nsp_lower = LOWER(in_author_nsp);

    RETURN (
        SELECT jsonb_agg(jsonb_build_object(
            'author_id', author_id,
            'first_name', first_name,
            'last_name', last_name,
            'patronymic', patronymic,
            'rating', rating
        ))
        FROM online_library_tables.author
        WHERE LOWER(online_library_tables.author.first_name) = in_author_nsp_lower 
           OR LOWER(online_library_tables.author.last_name) = in_author_nsp_lower
           OR LOWER(online_library_tables.author.patronymic) = in_author_nsp_lower
    );
END;
$$ LANGUAGE plpgsql;


-- поиск издательств по имени
CREATE OR REPLACE FUNCTION online_library_functional.search_publishers_by_name(in_name varchar(64))
RETURNS jsonb AS $$
DECLARE
    in_name_lower varchar(64);
BEGIN
    in_name_lower = LOWER(in_name);

    RETURN (
        SELECT jsonb_agg(jsonb_build_object(
            'publisher_id', publisher_id,
            'publisher_name', publisher_name,
            'city', city,
            'address', address,
            'email', email
        ))
        FROM online_library_tables.publisher
        WHERE LOWER(publisher_name) = in_name_lower
    );
END;
$$ LANGUAGE plpgsql;


-- поиск издательств по городам
CREATE OR REPLACE FUNCTION online_library_functional.search_publishers_by_city(in_city varchar(64))
RETURNS jsonb AS $$
DECLARE
    in_city_lower varchar(64);
BEGIN
    in_city_lower = LOWER(in_city);

    RETURN (
        SELECT jsonb_agg(jsonb_build_object(
            'publisher_id', publisher_id,
            'publisher_name', publisher_name,
            'city', city,
            'address', address,
            'email', email
        ))
        FROM online_library_tables.publisher
        WHERE LOWER(city) = in_city_lower
    );
END;
$$ LANGUAGE plpgsql;


-- поиск читателей
CREATE OR REPLACE FUNCTION online_library_functional.search_users_by_user_nsp(in_user_nsp varchar(256))
RETURNS jsonb AS $$
DECLARE
    in_user_nsp_lower varchar(256);
BEGIN
    in_user_nsp_lower = LOWER(in_user_nsp);

    RETURN (
        SELECT jsonb_agg(jsonb_build_object(
            'user_id', user_id,
            'first_name', first_name,
            'last_name', last_name,
            'patronymic', patronymic,
            'phone', phone,
            'email', email,
			'is_admin', is_admin
        ))
        FROM online_library_tables.user r
        WHERE LOWER(r.first_name) = in_user_nsp_lower 
           OR LOWER(r.last_name) = in_user_nsp_lower
           OR LOWER(r.patronymic) = in_user_nsp_lower
    );
END;
$$ LANGUAGE plpgsql;


-- поиск user_id и статуса is_admin по логину и паролю пользователя
CREATE OR REPLACE FUNCTION online_library_functional.get_user_id_and_is_admin_by_user_email_and_password(in_email varchar(256),
in_password varchar(256)) RETURNS jsonb AS $$
BEGIN
    RETURN (
        SELECT jsonb_agg(jsonb_build_object(
			'user_id', user_id,
			'is_admin', is_admin
        ))
        FROM online_library_tables.user u
        WHERE u.email = in_email AND u.user_password = in_password
    );
END;
$$ LANGUAGE plpgsql;


---
--- ФУНКЦИИ ДЛЯ УДАЛЕНИЙ
---


-- удаление по имени таблицы, названию первичного ключа в этой таблице и первичному ключу
CREATE OR REPLACE FUNCTION online_library_functional.delete_row_by_id(table_name text, pk_column text, id int)
RETURNS VOID AS $$
DECLARE
	delete_query text;
BEGIN
	delete_query = format('DELETE FROM online_library_tables.%I WHERE %I = %L', table_name, pk_column, id);

	EXECUTE delete_query;

EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка при удалении из таблицы % по первичному ключу id = %: %', table_name, id, SQLERRM;
END
$$ LANGUAGE plpgsql;


-- удаление авторов по имени/фамилии/отчеству
CREATE OR REPLACE FUNCTION online_library_functional.delete_author_by_author_nsp(in_author_nsp varchar(64))
RETURNS VOID AS $$
DECLARE
	in_author_nsp_lower varchar(64);
BEGIN
	in_author_nsp_lower = LOWER(in_author_nsp);

    DELETE FROM online_library_tables.author
    WHERE LOWER(first_name) = in_author_nsp_lower OR LOWER(last_name) = in_author_nsp_lower
    	OR LOWER(patronymic) = in_author_nsp_lower;

EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка при удалении автора по имени/фамилии/отчеству: %', SQLERRM;
END
$$ LANGUAGE plpgsql;


-- удаление издательств по имени
CREATE OR REPLACE FUNCTION online_library_functional.delete_publisher_by_name(in_name varchar(64))
RETURNS VOID AS $$
DECLARE
	in_name_lower varchar(64);
BEGIN
	in_name_lower = LOWER(in_name);

    DELETE FROM online_library_tables.publisher
    WHERE LOWER(publisher_name) = in_name_lower; 

EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка при удалении автора по имени/фамилии/отчеству: %', SQLERRM;
END
$$ LANGUAGE plpgsql;


-- удаление пользователя по имени
CREATE OR REPLACE FUNCTION online_library_functional.delete_user_by_user_nsp(in_user_nsp varchar(256))
RETURNS VOID AS $$
DECLARE
	in_user_nsp_lower varchar(256);
BEGIN
	in_user_nsp_lower = LOWER(in_user_nsp);

    DELETE FROM online_library_tables.user
        WHERE LOWER(first_name) = in_user_nsp_lower OR LOWER(last_name) = in_user_nsp_lower
    	OR LOWER(patronymic) = in_user_nsp_lower;

EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка при удалении автора по имени/фамилии/отчеству: %', SQLERRM;
END
$$ LANGUAGE plpgsql;
