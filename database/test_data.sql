---
--- ДОБАВЛЕНИЕ ТЕСТОВЫХ ДАННЫХ
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

INSERT INTO online_library_tables.reader (first_name, last_name, patronymic, phone, email, reader_password) VALUES
('Владислав', 'Ли', 'Владимирович', '88005553535', 'vlavlali@inbox.ru', '111'),
('Владимир', 'Ктотов', 'Владимирович', '81602223445', 'vladimirkrutoy@chill.ru', '222'),
('NoName', 'Pupupu', null, '80001112233', 'hzktononame@noname.ru', '321');

INSERT INTO online_library_tables.saving (reader_id, book_id) VALUES
(1, 6),
(1, 2),
(3, 5),
(2, 1),
(2, 4),
(2, 6);