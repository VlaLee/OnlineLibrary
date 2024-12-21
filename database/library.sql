--
-- PostgreSQL СОЗДАНИЕ БАЗЫ ДАННЫХ
--


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET client_min_messages = warning;
SET row_security = off;


--
-- ОЧИЩЕНИЕ ТАБЛИЦ
--


DROP TABLE IF EXISTS online_library.reader CASCADE;
DROP TABLE IF EXISTS online_library.saving CASCADE;
DROP TABLE IF EXISTS online_library.book CASCADE;
DROP TABLE IF EXISTS online_library.publisher CASCADE;
DROP TABLE IF EXISTS online_library.book_author CASCADE;
DROP TABLE IF EXISTS online_library.author CASCADE;


--
-- ОЧИЩЕНИЕ СХЕМ
--


DROP SCHEMA IF EXISTS online_library;
DROP SCHEMA IF EXISTS online_library_functional;


--
-- СОЗДАНИЕ СХЕМ
--


CREATE SCHEMA online_library AUTHORIZATION library_owner_vlad; 
CREATE SCHEMA online_library_functional AUTHORIZATION library_owner_vlad;


--
-- СОЗДАНИЕ ТАБЛИЦ
--


CREATE TABLE online_library.reader
(
	reader_id serial PRIMARY KEY,
	first_name varchar(64) NOT NULL,
	last_name varchar(64) NOT NULL,
	patronymic varchar(64),
	phone varchar(32) NOT NULL UNIQUE,
	email varchar(256) NOT NULL UNIQUE
);

CREATE TABLE online_library.saving
(
	saving_id serial PRIMARY KEY,
	saving_date date NOT NULL,
	reader_id int NOT NULL,
	book_id int NOT NULL,
	has_read boolean DEFAULT false,
	rating numeric(4, 2) DEFAULT NULL
);

CREATE TABLE online_library.book
(
	book_id serial PRIMARY KEY,
	title varchar(256) NOT NULL,
	genre varchar(64) NOT NULL,
	rating numeric(4, 2) DEFAULT NULL,
	publisher_id int NOT NULL,
	publication_year int NOT NULL
);

CREATE TABLE online_library.publisher
(
	publisher_id serial PRIMARY KEY,
	publisher_name varchar(64) NOT NULL,
	city varchar(64) NOT NULL,
	address varchar(256) NOT NULL,
	email varchar(256) NOT NULL UNIQUE
);

CREATE TABLE online_library.book_author
(
	book_id int NOT NULL,
	author_id int NOT NULL,

	CONSTRAINT pk_book_author PRIMARY KEY (book_id, author_id)
);

CREATE TABLE online_library.author
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


ALTER TABLE online_library.saving
ADD CONSTRAINT fk_saving_reader FOREIGN KEY (reader_id) REFERENCES online_library.reader (reader_id)
	ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE online_library.saving
ADD CONSTRAINT fk_saving_book FOREIGN KEY (book_id) REFERENCES online_library.book (book_id)
	ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE online_library.book
ADD CONSTRAINT fk_book_publisher FOREIGN KEY (publisher_id) REFERENCES online_library.publisher (publisher_id)
	ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE online_library.book_author
ADD CONSTRAINT fk_book_author_book FOREIGN KEY (book_id) REFERENCES online_library.book (book_id)
	ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE online_library.book_author
ADD CONSTRAINT fk_book_author_author FOREIGN KEY (author_id) REFERENCES online_library.author (author_id)
	ON UPDATE CASCADE ON DELETE CASCADE;


---
--- ДРУГИЕ ОГРАНИЧЕНИЯ
---


ALTER TABLE online_library.saving
ADD CONSTRAINT unq_saving_reader_id_book_id UNIQUE (reader_id, book_id);

ALTER TABLE online_library.publisher
ADD CONSTRAINT unq_publisher_city_address UNIQUE (city, address);


---
--- ИНДЕКСЫ
---


CREATE INDEX idx_book_genre_lower ON online_library.book( LOWER (genre) );
CREATE INDEX idx_author_last_name_lower ON online_library.author ( LOWER (last_name) );
CREATE INDEX idx_publisher_city_lower ON online_library.publisher ( LOWER (city) );
