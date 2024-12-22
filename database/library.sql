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


--
-- СОЗДАНИЕ СХЕМ
--


CREATE SCHEMA online_library_tables AUTHORIZATION library_owner;
CREATE SCHEMA online_library_functional AUTHORIZATION library_owner;


--
-- СОЗДАНИЕ ТАБЛИЦ
--


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
--- ДРУГИЕ ОГРАНИЧЕНИЯ
---


ALTER TABLE online_library_tables.saving
ADD CONSTRAINT unq_saving_user_id_book_id UNIQUE (user_id, book_id);

ALTER TABLE online_library_tables.publisher
ADD CONSTRAINT unq_publisher_city_address UNIQUE (city, address);


---
--- ИНДЕКСЫ
---


CREATE INDEX idx_book_genre_lower ON online_library_tables.book( LOWER (genre) );
CREATE INDEX idx_author_last_name_lower ON online_library_tables.author ( LOWER (last_name) );
CREATE INDEX idx_publisher_city_lower ON online_library_tables.publisher ( LOWER (city) );
