---
--- СОЗДАНИЕ ПОЛЬЗОВАТЕЛЯ БАЗЫ ДАННЫХ
---

CREATE USER reader_user WITH PASSWORD 'reader1000';

-- даем разрешение на подключение к базе данных
GRANT CONNECT ON DATABASE library TO reader_user;

-- даем разрешение на использование схем
GRANT USAGE ON SCHEMA online_library_tables TO reader_user;
GRANT USAGE ON SCHEMA online_library_functional TO reader_user;

-- даем разрешение на возможность делать SELECT запросы ко всем таблицам, кроме user
GRANT SELECT ON ALL TABLES IN SCHEMA online_library_tables TO reader_user;
REVOKE SELECT ON TABLE online_library_tables.user FROM reader_user;

-- даем разрешение на вставку и удаление для таблицы saving (для сохранения книг к себе "на полку")
GRANT INSERT, DELETE ON TABLE online_library_tables.saving TO reader_user;

---
--- СОЗДАНИЕ СХЕМЫ
---

CREATE SCHEMA online_library_init AUTHORIZATION library_owner;

---
--- СОЗДАНИЕ ФУНКЦИЙ ДЛЯ ИНИЦИАЛИЗАЦИИ И УДАЛЕНИЯ БАЗЫ ДАННЫХ (СХЕМЫ)
---

CREATE OR REPLACE FUNCTION online_library_init.initialize_database() RETURNS VOID AS $$
BEGIN
	---
	--- СОЗДАНИЕ СХЕМЫ
	---


	CREATE SCHEMA online_library_tables AUTHORIZATION library_owner;


	---
	--- СОЗДАНИЕ ТАБЛИЦ
	---
	

	CREATE TABLE online_library_tables.user
	(
		user_id serial PRIMARY KEY,
		first_name varchar(256) NOT NULL,
		last_name varchar(256) NOT NULL,
		patronymic varchar(256),
		phone varchar(256) NOT NULL UNIQUE,
		email varchar(256) NOT NULL UNIQUE,
		user_password varchar(256) NOT NULL,
		is_admin boolean NOT NULL DEFAULT false
	);
	
	CREATE TABLE online_library_tables.saving
	(
		saving_id serial PRIMARY KEY,
		saving_date date NOT NULL,
		user_id int NOT NULL,
		book_id int NOT NULL,
		rating numeric(4, 2) DEFAULT NULL
	);
	
	CREATE TABLE online_library_tables.book
	(
		book_id serial PRIMARY KEY,
		title varchar(256) NOT NULL,
		genre varchar(64) NOT NULL,
		rating numeric(4, 2) DEFAULT NULL,
		publisher_id int NOT NULL,
		publication_year int NOT NULL
	);
	
	CREATE TABLE online_library_tables.publisher
	(
		publisher_id serial PRIMARY KEY,
		publisher_name varchar(64) NOT NULL,
		city varchar(64) NOT NULL,
		address varchar(256) NOT NULL,
		email varchar(256) NOT NULL UNIQUE
	);
	
	CREATE TABLE online_library_tables.book_author
	(
		book_id int NOT NULL,
		author_id int NOT NULL,
	
		CONSTRAINT pk_book_author PRIMARY KEY (book_id, author_id)
	);
	
	CREATE TABLE online_library_tables.author
	(
		author_id serial PRIMARY KEY,
		first_name varchar(64) NOT NULL,
		last_name varchar(64) NOT NULL,
		patronymic varchar(64) DEFAULT NULL,
		rating numeric(4, 2) DEFAULT NULL
	);


	--
	-- ДОБАВЛЕНИЕ ВНЕШНИХ КЛЮЧЕЙ
	--


	ALTER TABLE online_library_tables.saving
	ADD CONSTRAINT fk_saving_user FOREIGN KEY (user_id) REFERENCES online_library_tables.user (user_id)
		ON UPDATE CASCADE ON DELETE CASCADE;
	
	ALTER TABLE online_library_tables.saving
	ADD CONSTRAINT fk_saving_book FOREIGN KEY (book_id) REFERENCES online_library_tables.book (book_id)
		ON UPDATE CASCADE ON DELETE CASCADE;
	
	ALTER TABLE online_library_tables.book
	ADD CONSTRAINT fk_book_publisher FOREIGN KEY (publisher_id) REFERENCES online_library_tables.publisher (publisher_id)
		ON UPDATE CASCADE ON DELETE CASCADE;
	
	ALTER TABLE online_library_tables.book_author
	ADD CONSTRAINT fk_book_author_book FOREIGN KEY (book_id) REFERENCES online_library_tables.book (book_id)
		ON UPDATE CASCADE ON DELETE CASCADE;
	
	ALTER TABLE online_library_tables.book_author
	ADD CONSTRAINT fk_book_author_author FOREIGN KEY (author_id) REFERENCES online_library_tables.author (author_id)
		ON UPDATE CASCADE ON DELETE CASCADE;


	---
	--- ДОБАВЛЕНИЕ ДРУГИХ ОГРАНИЧЕНИЙ
	---
	

	ALTER TABLE online_library_tables.saving
	ADD CONSTRAINT unq_saving_user_id_book_id UNIQUE (user_id, book_id);
	
	ALTER TABLE online_library_tables.publisher
	ADD CONSTRAINT unq_publisher_city_address UNIQUE (city, address);

	
	---
	--- СОЗДАНИЕ ИНДЕКСОВ
	---
	

	CREATE INDEX idx_user_email ON online_library_tables.user(email);
	CREATE INDEX idx_book_genre_lower ON online_library_tables.book( LOWER (genre) );
	CREATE INDEX idx_author_last_name_lower ON online_library_tables.author( LOWER (last_name) );


	---
	--- СОЗДАНИЕ ТРИГГЕРОВ
	---

	CREATE TRIGGER trg_set_saving_date BEFORE INSERT ON online_library_tables.saving
	FOR EACH ROW EXECUTE PROCEDURE online_library_functional.track_saving_data();

	CREATE TRIGGER trg_update_book_rating AFTER UPDATE OR DELETE ON online_library_tables.saving
	FOR EACH ROW EXECUTE PROCEDURE online_library_functional.update_book_rating();

	CREATE TRIGGER trg_update_author_rating AFTER UPDATE OR DELETE ON online_library_tables.book
	FOR EACH ROW EXECUTE PROCEDURE online_library_functional.update_author_rating();


	---
	--- ВСТАВКА ТЕСТОВЫХ ДАННЫХ
	---

	INSERT INTO online_library_tables.author (first_name, last_name, patronymic)
	VALUES
	('Фёдор', 'Достоевский', 'Михайлович'),
	('Михаил', 'Булгаков', 'Афанасьевич'),
	('Джек', 'Лондон', null);
	
	INSERT INTO online_library_tables.publisher (publisher_name, city, address, email)
	VALUES
	('АСТ', 'Москва', 'Ленинская 23/11', 'ASTPublisherMoscow@inbox.ru'),
	('Литрес', 'Санкт-Петербург', 'Яблоневая 47', 'LitresPublisherSPb@mail.ru'),
	('XL Media', 'Екатеринбург', 'Матросова 27/3', 'XLMediaPublisherEkb@mail.ru');
	
	INSERT INTO online_library_tables.book (title, genre, publisher_id, publication_year)
	VALUES
	('Преступление и наказание', 'роман', 1, 2017),
	('Идиот', 'роман', 1, 2017),
	('Униженные и оскорбленные', 'роман', 2, 2018),
	('Мастер и маргарита', 'роман', 1, 2015),
	('Морфий', 'рассказ', 3, 2023),
	('Мартин Иден', 'роман', 1, 2018),
	('Странник по звездам', 'роман', 2, 2020);
	
	INSERT INTO online_library_tables.book_author VALUES
	(1, 1),
	(2, 1),
	(3, 1),
	(4, 2),
	(5, 2),
	(6, 3),
	(7, 3);
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION online_library_init.drop_database() RETURNS VOID AS $$
BEGIN
	--
	-- ОЧИЩЕНИЕ ТАБЛИЦ
	--
	
	
	DROP TABLE IF EXISTS online_library_tables.user CASCADE;
	DROP TABLE IF EXISTS online_library_tables.saving CASCADE;
	DROP TABLE IF EXISTS online_library_tables.book CASCADE;
	DROP TABLE IF EXISTS online_library_tables.publisher CASCADE;
	DROP TABLE IF EXISTS online_library_tables.book_author CASCADE;
	DROP TABLE IF EXISTS online_library_tables.author CASCADE;


	--
	-- ОЧИЩЕНИЕ СХЕМ
	--

	DROP SCHEMA IF EXISTS online_library_tables;
END
$$ LANGUAGE plpgsql;