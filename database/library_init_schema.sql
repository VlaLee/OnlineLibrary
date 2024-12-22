DROP FUNCTION IF EXISTS online_library_init.initialize_database;
DROP FUNCTION IF EXISTS online_library_init.drop_database;

DROP SCHEMA IF EXISTS online_library_init;

CREATE SCHEMA online_library_init AUTHORIZATION library_owner;

CREATE OR REPLACE FUNCTION online_library_init.initialize_database() RETURNS VOID AS $$
BEGIN
	---
	--- СОЗДАНИЕ СХЕМ
	---

	CREATE SCHEMA online_library_tables AUTHORIZATION library_owner; 
	CREATE SCHEMA online_library_functional AUTHORIZATION library_owner;


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
		has_read boolean DEFAULT false,
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
	---
	--- ОЧИСТКА ТРИГГЕРОВ
	---

	DROP TRIGGER IF EXISTS trg_set_saving_date ON online_library_tables.saving;
	DROP TRIGGER IF EXISTS trg_update_book_rating ON online_library_tables.saving;
	DROP TRIGGER IF EXISTS trg_update_author_rating ON online_library_tables.book;
	DROP TRIGGER IF EXISTS trg_delete_books_after_author_delete ON online_library_tables.author;

	---
	--- ОЧИСТКА ФУНКЦИЙ
	---
	
	
	DROP FUNCTION IF EXISTS online_library_functional.track_saving_data;
	DROP FUNCTION IF EXISTS online_library_functional.update_book_rating;
	DROP FUNCTION IF EXISTS online_library_functional.update_author_rating;
	DROP FUNCTION IF EXISTS online_library_functional.delete_books_after_author_delete;
	DROP FUNCTION IF EXISTS online_library_functional.get_all_data_from_tables;
	DROP FUNCTION IF EXISTS online_library_functional.get_all_data_from_table_by_table_name;
	DROP FUNCTION IF EXISTS online_library_functional.truncate_table_by_name;
	DROP FUNCTION IF EXISTS online_library_functional.truncate_all_tables();
	DROP FUNCTION IF EXISTS online_library_functional.insert_into_table_user;
	DROP FUNCTION IF EXISTS online_library_functional.insert_into_table_saving;
	DROP FUNCTION IF EXISTS online_library_functional.insert_into_table_book;
	DROP FUNCTION IF EXISTS online_library_functional.insert_into_table_publisher;
	DROP FUNCTION IF EXISTS online_library_functional.insert_into_table_book_author;
	DROP FUNCTION IF EXISTS online_library_functional.insert_into_table_author;
	DROP FUNCTION IF EXISTS online_library_functional.update_phone_into_table_user;
	DROP FUNCTION IF EXISTS online_library_functional.update_email_into_table_user;
	DROP FUNCTION IF EXISTS online_library_functional.set_patronymic_into_table_user;
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
	DROP FUNCTION IF EXISTS online_library_functional.search_users_by_user_nsp;
	DROP FUNCTION IF EXISTS online_library_functional.get_is_admin_by_user_email_and_password;
	DROP FUNCTION IF EXISTS online_library_functional.delete_row_by_id;
	DROP FUNCTION IF EXISTS online_library_functional.delete_author_by_author_nsp;
	DROP FUNCTION IF EXISTS online_library_functional.delete_publisher_by_name;
	DROP FUNCTION IF EXISTS online_library_functional.delete_user_by_user_nsp;


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
	DROP SCHEMA IF EXISTS online_library_functional;
END
$$ LANGUAGE plpgsql;

SELECT 

