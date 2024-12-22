---
--- ОЧИСТКА ТРИГГЕРОВ
---

DROP TRIGGER IF EXISTS trg_set_saving_date ON online_library.saving;
DROP TRIGGER IF EXISTS trg_update_book_rating ON online_library.saving;
DROP TRIGGER IF EXISTS trg_update_author_rating ON online_library.book;
DROP TRIGGER IF EXISTS trg_delete_books_after_author_delete ON online_library.author;

---
--- ОЧИСТКА ФУНКЦИЙ
---


DROP FUNCTION IF EXISTS online_library_functional.track_saving_data;
DROP FUNCTION IF EXISTS online_library_functional.update_book_rating;
DROP FUNCTION IF EXISTS online_library_functional.update_author_rating;
DROP FUNCTION IF EXISTS online_library_functional.delete_books_after_author_delete;
DROP FUNCTION IF EXISTS online_library_functional.get_all_data_from_tables;
DROP FUNCTION IF EXISTS online_library_functional.truncate_table_by_name;
DROP FUNCTION IF EXISTS online_library_functional.truncate_all_tables;
DROP FUNCTION IF EXISTS online_library_functional.insert_into_table_reader;
DROP FUNCTION IF EXISTS online_library_functional.insert_into_table_saving;
DROP FUNCTION IF EXISTS online_library_functional.insert_into_table_book;
DROP FUNCTION IF EXISTS online_library_functional.insert_into_table_publisher;
DROP FUNCTION IF EXISTS online_library_functional.insert_into_table_book_author;
DROP FUNCTION IF EXISTS online_library_functional.insert_into_table_author;
DROP FUNCTION IF EXISTS online_library_functional.update_phone_into_table_reader;
DROP FUNCTION IF EXISTS online_library_functional.update_email_into_table_reader;
DROP FUNCTION IF EXISTS online_library_functional.set_patronymic_into_table_reader;
DROP FUNCTION IF EXISTS online_library_functional.set_has_read_into_table_saving;
DROP FUNCTION IF EXISTS online_library_functional.set_rating_into_table_saving;
DROP FUNCTION IF EXISTS online_library_functional.update_into_table_book;
DROP FUNCTION IF EXISTS online_library_functional.update_into_table_publisher;
DROP FUNCTION IF EXISTS online_library_functional.update_into_table_book_author;
DROP FUNCTION IF EXISTS online_library_functional.update_into_table_author;
DROP FUNCTION IF EXISTS online_library_functional.find_row_by_id;
DROP FUNCTION IF EXISTS online_library_functional.search_books_by_genre;
DROP FUNCTION IF EXISTS online_library_functional.search_books_by_title;
DROP FUNCTION IF EXISTS online_library_functional.search_books_by_author_nsp;
DROP FUNCTION IF EXISTS online_library_functional.search_books_by_publisher_name;
DROP FUNCTION IF EXISTS online_library_functional.search_authors_by_author_nsp;
DROP FUNCTION IF EXISTS online_library_functional.search_publishers_by_name;
DROP FUNCTION IF EXISTS online_library_functional.search_publishers_by_city;
DROP FUNCTION IF EXISTS online_library_functional.search_readers_by_reader_nsp;
DROP FUNCTION IF EXISTS online_library_functional.delete_row_by_id;
DROP FUNCTION IF EXISTS online_library_functional.delete_author_by_author_nsp;
DROP FUNCTION IF EXISTS online_library_functional.delete_publisher_by_name;
DROP FUNCTION IF EXISTS online_library_functional.delete_reader_by_reader_nsp;


---
--- СОЗДАНИЕ ТРИГГЕР-ФУНКЦИЙ И ТРИГГЕРОВ
---


CREATE OR REPLACE FUNCTION online_library_functional.track_saving_data() RETURNS TRIGGER AS $$
BEGIN
	NEW.saving_date = now();
	RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_saving_date BEFORE INSERT ON online_library.saving
	FOR EACH ROW EXECUTE PROCEDURE online_library_functional.track_saving_data();


CREATE OR REPLACE FUNCTION online_library_functional.update_book_rating() RETURNS TRIGGER AS $$
BEGIN
	UPDATE online_library.book
	SET rating = (
		SELECT AVG (rating)::numeric(4, 2)
		FROM online_library.saving
		WHERE book_id = NEW.book_id
	)
	WHERE book_id = NEW.book_id;

	RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_book_rating AFTER UPDATE OR DELETE ON online_library.saving
	FOR EACH ROW EXECUTE PROCEDURE online_library_functional.update_book_rating();


CREATE OR REPLACE FUNCTION online_library_functional.update_author_rating() RETURNS TRIGGER AS $$
DECLARE
	searched_author_id int;
BEGIN
	-- Находим нужного автора через таблицы book и book_author
	SELECT online_library.book_author.author_id
	INTO searched_author_id
	FROM online_library.book
		INNER JOIN online_library.book_author USING (book_id)
	WHERE online_library.book.book_id = NEW.book_id
	LIMIT 1;

	-- Обновляем рейтинг автора
	UPDATE online_library.author
	SET rating = (
		SELECT AVG (online_library.book.rating)::numeric(4, 2)
		FROM online_library.book
			INNER JOIN online_library.book_author USING (book_id)
		WHERE online_library.book_author.author_id = searched_author_id
	)
	WHERE author_id = searched_author_id;
	
	RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_author_rating AFTER UPDATE OR DELETE ON online_library.book
	FOR EACH ROW EXECUTE PROCEDURE online_library_functional.update_author_rating();


CREATE OR REPLACE FUNCTION online_library_functional.delete_books_after_author_delete() RETURNS TRIGGER AS $$
BEGIN
   DELETE FROM online_library.book
   WHERE book_id IN (
      SELECT book_id
      FROM online_library.book_author
      WHERE author_id = OLD.author_id
   );
   RETURN OLD;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_delete_books_after_author_delete BEFORE DELETE ON online_library.author
	FOR EACH ROW EXECUTE FUNCTION online_library_functional.delete_books_after_author_delete();


---
--- ФУНКЦИЯ НА ВЫВОД СОДЕРЖИМОГО ТАБЛИЦ
---


CREATE OR REPLACE FUNCTION online_library_functional.get_all_data_from_tables()
RETURNS TABLE(table_name text, row_data jsonb) AS $$
DECLARE
    table_record record;
    select_query text;
BEGIN
    FOR table_record IN (
        SELECT information_schema.tables.table_name
        FROM information_schema.tables
        WHERE table_schema = 'online_library' AND table_type = 'BASE TABLE'
	)
    LOOP
        select_query = format('SELECT ''%s'' AS table_name, row_to_json(t)::jsonb FROM online_library.%I t',
						table_record.table_name,
						table_record.table_name);
        RETURN QUERY EXECUTE select_query;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


---
--- ФУНКЦИИ НА ОЧИЩЕНИЕ ТАБЛИЦ
---


-- Очищение таблицы по ее имени
CREATE OR REPLACE FUNCTION online_library_functional.truncate_table_by_name(table_name text) RETURNS VOID AS $$
BEGIN
	EXECUTE format('TRUNCATE TABLE online_library.%I RESTART IDENTITY CASCADE', table_name);
END
$$ LANGUAGE plpgsql;


-- Очищение всех таблиц
CREATE OR REPLACE FUNCTION online_library_functional.truncate_all_tables() RETURNS VOID AS $$
DECLARE
	table_name text;
BEGIN
	FOR table_name IN (
		SELECT information_schema.tables.table_name
		FROM information_schema.tables
		WHERE table_schema = 'online_library' AND table_type = 'BASE TABLE'
	)
	LOOP
		EXECUTE format('TRUNCATE TABLE online_library.%I RESTART IDENTITY CASCADE', table_name);
	END LOOP;
END
$$ LANGUAGE plpgsql;


---
--- ФУНКЦИИ НА ДОБАВЛЕНИЕ ДАННЫХ В ТАБЛИЦЫ
---


CREATE OR REPLACE FUNCTION online_library_functional.insert_into_table_reader(
	in_first_name varchar(64),
	in_last_name varchar(64),
	in_phone varchar(32),
	in_email varchar(256),
	in_password varchar(256),
	in_patronymic varchar(64) DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
	INSERT INTO online_library.reader (first_name, last_name, patronymic, phone, email, reader_password)
	VALUES (in_first_name, in_last_name, in_patronymic, in_phone, in_email, in_password);
EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка при добавлении читателя: %', SQLERRM;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION online_library_functional.insert_into_table_saving(
	in_reader_id int,
	in_book_id int
) RETURNS VOID AS $$
BEGIN
	INSERT INTO online_library.saving (reader_id, book_id)
	VALUES (in_reader_id, in_book_id);
EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка при добавлении пользовательского сохранения: %', SQLERRM;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION online_library_functional.insert_into_table_book(
	in_title varchar(256),
	in_genre varchar(64),
	in_publisher_id int,
	in_publication_year int
) RETURNS VOID AS $$
BEGIN
	INSERT INTO online_library.book (title, genre, publisher_id, publication_year)
	VALUES (in_title, in_genre, in_publisher_id, in_publication_year);
EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка при добавлении книги: %', SQLERRM;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION online_library_functional.insert_into_table_publisher(
	in_publisher_name varchar(64),
	in_city varchar(64),
	in_address varchar(256),
	in_email varchar(256)
) RETURNS VOID AS $$
BEGIN
	INSERT INTO online_library.publisher (publisher_name, city, address, email)
	VALUES (in_publisher_name, in_city, in_address, in_email);
EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка при добавлении издательства: %', SQLERRM;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION online_library_functional.insert_into_table_book_author(
	in_book_id int,
	in_author_id int
) RETURNS VOID AS $$
BEGIN
	INSERT INTO online_library.book_author (book_id, author_id)
	VALUES (in_book_id, in_author_id);
EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка при добавлении связи ''книга - автор'': %', SQLERRM;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION online_library_functional.insert_into_table_author(
	in_first_name varchar(64),
	in_last_name varchar(64),
	in_patronymic varchar(64) DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
	INSERT INTO online_library.author (first_name, last_name, patronymic)
	VALUES (in_first_name, in_last_name, in_patronymic);
EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка при добавлении автора: %', SQLERRM;
END
$$ LANGUAGE plpgsql;


---
--- ФУНКЦИИ НА ОБНОВЛЕНИЕ ЗНАЧЕНИЙ
---


CREATE OR REPLACE FUNCTION online_library_functional.update_phone_into_table_reader(in_reader_id int,
	in_phone varchar(32)) RETURNS VOID AS $$
BEGIN
	UPDATE online_library.reader
	SET phone = in_phone
	WHERE reader_id = in_reader_id;
EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка [reader_id = %] при изменении номера телефона читателя: %', in_reader_id, SQLERRM;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION online_library_functional.update_email_into_table_reader(in_reader_id int,
	in_email varchar(256)) RETURNS VOID AS $$
BEGIN
	UPDATE online_library.reader
	SET email = in_email
	WHERE reader_id = in_reader_id;
EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка [reader_id = %] при изменении адреса электронной почты читателя: %', in_reader_id, SQLERRM;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION online_library_functional.set_patronymic_into_table_reader(in_reader_id int,
	in_patronymic varchar(64)) RETURNS VOID AS $$
DECLARE
	current_patronymic varchar(64);
BEGIN
	SELECT patronymic
	INTO current_patronymic
	FROM online_library.reader
	WHERE reader_id = in_reader_id;

	IF current_patronymic IS NULL THEN
		UPDATE online_library.reader
		SET patronymic = in_patronymic
		WHERE reader_id = in_reader_id;
	ELSE
		RAISE EXCEPTION 'Ошибка [reader_id = %]: поле "отчество" уже заполнено', in_reader_id;
	END IF;
EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка [reader_id = %] при изменении отчества читателя: %', in_reader_id, SQLERRM;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION online_library_functional.set_has_read_into_table_saving(in_saving_id int)
RETURNS VOID AS $$
DECLARE
	current_has_read boolean;
BEGIN
	SELECT has_read
	INTO current_has_read
	FROM online_library.saving
	WHERE saving_id = in_saving_id;

	IF has_read = false THEN
		UPDATE online_library.saving
		SET has_read = true
		WHERE saving_id = in_saving_id;
	ELSE
		RAISE EXCEPTION 'Ошибка [saving_id = %]: пользователь уже прочитал эту книгу', in_saving_id;
	END IF;
EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка [saving_id = %] при попытке пользователем прочитать книгу: %', in_saving_id, SQLERRM;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION online_library_functional.set_rating_into_table_saving(in_saving_id int,
	in_rating numeric(4, 2)) RETURNS VOID AS $$
BEGIN
	UPDATE online_library.saving
	SET rating = in_rating
	WHERE saving_id = in_saving_id;
EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка [saving_id = %] при попытке пользователем выставить рейтинг: %', in_saving_id, SQLERRM;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION online_library_functional.update_into_table_book(
	in_book_id int,
	in_title varchar(256),
	in_genre varchar(64),
	in_publisher_id int,
	in_publication_year int
) RETURNS VOID AS $$
BEGIN
	UPDATE online_library.book
	SET title = in_title,
		genre = in_genre,
		publisher_id = in_publisher_id,
		publication_year = in_publication_year
	WHERE in_book_id = book_id;
EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка [book_id = %] при обновлении книги: %', in_book_id, SQLERRM;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION online_library_functional.update_into_table_publisher(
	in_publisher_id int,
	in_publisher_name varchar(64),
	in_city varchar(64),
	in_address varchar(256),
	in_email varchar(256)
) RETURNS VOID AS $$
BEGIN
	UPDATE online_library.publisher
	SET publisher_name = in_publisher_name,
		city = in_city,
		address = in_address,
		email = in_email
	WHERE publisher_id = in_publisher_id;
EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка [publisher_id = %] при обновлении издательства: %', in_publisher_id, SQLERRM;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION online_library_functional.update_into_table_book_author(
	old_book_id int,
	old_author_id int,
	new_book_id int,
	new_author_id int
) RETURNS VOID AS $$
BEGIN
	UPDATE online_library.book_author
	SET book_id = new_book_id,
		author_id = new_author_id
	WHERE book_id = old_book_id AND author_id = old_author_id;
EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка [book_id = %, author_id = %] при изменении связи ''книга - автор'': %',
		old_book_id, old_author_id, SQLERRM;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION online_library_functional.update_into_table_author(
	in_author_id int,
	in_first_name varchar(64),
	in_last_name varchar(64),
	in_patronymic varchar(64)
) RETURNS VOID AS $$
BEGIN
	UPDATE online_library.author
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


-- поиск по первичному ключу
CREATE OR REPLACE FUNCTION online_library_functional.find_row_by_id(table_name text, pk_column text, id int)
RETURNS jsonb AS $$
DECLARE
	select_query text;
	result_row jsonb;
BEGIN
	select_query = format('SELECT row_to_json(t)::jsonb FROM online_library.%I t WHERE t.%I = %L', table_name, pk_column, id);
	EXECUTE select_query INTO result_row;
	
	IF result_row IS NULL THEN
		RAISE EXCEPTION 'Ошибка: строка с id = % не найден в таблице %', id, table_name;
	END IF;

	RETURN result_row;
END
$$ LANGUAGE plpgsql;


-- поиск книг по жанру
CREATE OR REPLACE FUNCTION online_library_functional.search_books_by_genre(in_genre varchar(64))
RETURNS TABLE(
	book_id int,
	title varchar(256),
	genre varchar(64),
	rating numeric(4, 2),
	publisher_id int,
	publication_year int) AS $$
DECLARE
	in_genre_lower varchar(64);
BEGIN
	in_genre_lower = LOWER(in_genre);

    RETURN QUERY
    SELECT *
    FROM online_library.book
    WHERE LOWER(online_library.book.genre) = in_genre_lower;
END
$$ LANGUAGE plpgsql;


-- поиск книг по названию
CREATE OR REPLACE FUNCTION online_library_functional.search_books_by_title(in_title varchar(256))
RETURNS TABLE(
	book_id int,
	title varchar(256),
	genre varchar(64),
	rating numeric(4, 2),
	publisher_id int,
	publication_year int
) AS $$
DECLARE
	in_title_lower varchar(256);
BEGIN
	in_title_lower = LOWER(in_title);

    RETURN QUERY
    SELECT *
    FROM online_library.book
    WHERE LOWER(online_library.book.title) = in_title_lower;
END
$$ LANGUAGE plpgsql;


-- поиск книг по авторам (имя, либо фамилия, либо отчество)
CREATE OR REPLACE FUNCTION online_library_functional.search_books_by_author_nsp(in_author_nsp varchar(64))
RETURNS TABLE(
	book_id int,
	title varchar(256),
	genre varchar(64),
	rating numeric(4, 2),
	publisher_id int,
	publication_year int
) AS $$
DECLARE
	in_author_nsp_lower varchar(64);
BEGIN
	in_author_nsp_lower = LOWER(in_author_nsp);

    RETURN QUERY
    SELECT b.book_id, b.title, b.genre, b.rating, b.publisher_id, b.publication_year
    FROM online_library.book b
    	INNER JOIN online_library.book_author ba ON b.book_id = ba.book_id
    	INNER JOIN online_library.author a ON ba.author_id = a.author_id
    WHERE LOWER(a.first_name) = in_author_nsp_lower OR LOWER(a.last_name) = in_author_nsp_lower
    	OR LOWER(a.patronymic) = in_author_nsp_lower;
END;
$$ LANGUAGE plpgsql;


-- поиск книг по издательствам
CREATE OR REPLACE FUNCTION online_library_functional.search_books_by_publisher_name(in_publisher_name varchar(64))
RETURNS TABLE(
	book_id int,
	title varchar(256),
	genre varchar(64),
	rating numeric(4, 2),
	publisher_id int,
	publication_year int
) AS $$
DECLARE
	in_publisher_name_lower varchar(64);
BEGIN
	in_publisher_name_lower = LOWER(in_publisher_name);

    RETURN QUERY
    SELECT b.book_id, b.title, b.genre, b.rating, b.publisher_id, b.publication_year
    FROM online_library.book b
    	INNER JOIN online_library.publisher p ON b.publisher_id = p.publisher_id
    WHERE LOWER(p.publisher_name) = in_publisher_name_lower;
END;
$$ LANGUAGE plpgsql;


-- поиск авторов по имени/фамилии/отчеству
CREATE OR REPLACE FUNCTION online_library_functional.search_authors_by_author_nsp(in_author_nsp varchar(64))
RETURNS TABLE(
	author_id int,
	first_name varchar(64),
	last_name varchar(64),
	patronymic varchar(64),
	rating numeric(4, 2)
) AS $$
DECLARE
	in_author_nsp_lower varchar(64);
BEGIN
	in_author_nsp_lower = LOWER(in_author_nsp);

    RETURN QUERY
    SELECT *
    FROM online_library.author
    WHERE LOWER(first_name) = in_author_nsp_lower OR LOWER(last_name) = in_author_nsp_lower
    	OR LOWER(patronymic) = in_author_nsp_lower;
END
$$ LANGUAGE plpgsql;


-- поиск издательств по имени
CREATE OR REPLACE FUNCTION online_library_functional.search_publishers_by_name(in_name varchar(64))
RETURNS TABLE(
	publisher_id int,
	publisher_name varchar(64),
	city varchar(64),
	address varchar(64),
	email varchar(256)
) AS $$
DECLARE
	in_name_lower varchar(64);
BEGIN
	in_name_lower = LOWER(in_name);

    RETURN QUERY
    SELECT *
    FROM online_library.publisher
    WHERE LOWER(online_library.publisher.publisher_name) = in_name_lower;
END
$$ LANGUAGE plpgsql;


-- поиск издательств по городам
CREATE OR REPLACE FUNCTION online_library_functional.search_publishers_by_city(in_city varchar(64))
RETURNS TABLE(
	publisher_id int,
	publisher_name varchar(64),
	city varchar(64),
	address varchar(64),
	email varchar(256)
) AS $$
DECLARE
	in_city_lower varchar(64);
BEGIN
	in_city_lower = LOWER(in_city);

    RETURN QUERY
    SELECT *
    FROM online_library.publisher
    WHERE LOWER(online_library.publisher.city) = in_city_lower;
END
$$ LANGUAGE plpgsql;


-- поиск читателей
CREATE OR REPLACE FUNCTION online_library_functional.search_readers_by_reader_nsp(in_reader_nsp varchar(64))
RETURNS TABLE(
	reader_id int,
	first_name varchar(64),
	last_name varchar(64),
	patronymic varchar(64),
	phone varchar(32),
	email varchar(256)
) AS $$
DECLARE
	in_reader_nsp_lower varchar(64);
BEGIN
	in_reader_nsp_lower = LOWER(in_reader_nsp);

    RETURN QUERY
    SELECT r.first_name, r.last_name, r.patronymic, r.phone, r.email
    FROM online_library.reader r
    WHERE LOWER(first_name) = in_reader_nsp_lower OR LOWER(last_name) = in_reader_nsp_lower
    	OR LOWER(patronymic) = in_reader_nsp_lower;
END
$$ LANGUAGE plpgsql;


---
--- ФУНКЦИИ ДЛЯ УДАЛЕНИЙ
---


-- удаление по первичному ключу
CREATE OR REPLACE FUNCTION online_library_functional.delete_row_by_id(table_name text, pk_column text, id int)
RETURNS VOID AS $$
DECLARE
	delete_query text;
BEGIN
	delete_query = format('DELETE FROM online_library.%I WHERE %I = %L', table_name, pk_column, id);

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

    DELETE FROM online_library.author
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

    DELETE FROM online_library.publisher
    WHERE LOWER(publisher_name) = in_name_lower; 

EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка при удалении автора по имени/фамилии/отчеству: %', SQLERRM;
END
$$ LANGUAGE plpgsql;


-- удаление читателя по имени
CREATE OR REPLACE FUNCTION online_library_functional.delete_reader_by_reader_nsp(in_reader_nsp varchar(64))
RETURNS VOID AS $$
DECLARE
	in_reader_nsp_lower varchar(64);
BEGIN
	in_reader_nsp_lower = LOWER(in_reader_nsp);

    DELETE FROM online_library.reader
        WHERE LOWER(first_name) = in_reader_nsp_lower OR LOWER(last_name) = in_reader_nsp_lower
    	OR LOWER(patronymic) = in_reader_nsp_lower;

EXCEPTION WHEN OTHERS THEN
	RAISE EXCEPTION 'Ошибка при удалении автора по имени/фамилии/отчеству: %', SQLERRM;
END
$$ LANGUAGE plpgsql;
