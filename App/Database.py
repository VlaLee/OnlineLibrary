from sqlalchemy import create_engine, MetaData, Column, Row, Integer, String, ForeignKey
from sqlalchemy import func
from sqlalchemy.orm import sessionmaker
from sqlalchemy.orm import declarative_base
from json import loads, dumps
from cryptography.fernet import Fernet



class init():
    def __init__(self):
        self.login = 'library_owner'
        self.password = '102255'

        self.engine = create_engine(
            F'postgresql+psycopg2://{self.login}:{self.password}@localhost/library',
            echo=False,
            isolation_level='SERIALIZABLE'
        )

        self.Session = sessionmaker(bind=self.engine)
        self.session = self.Session()

session = init()



def search_authors_by_author_nsp(arg : String):
    data = session.session.query(func.online_library_functional.search_authors_by_author_nsp(arg)).all()
    row0 = "["
    for row in data:
        if (row[0] != None):
            for item in row[0]:
                string_data = dumps(item)
                if (item != row[0][0]):
                    row0 += ', ' + string_data
                else:
                    row0 += string_data
        else:
            return None
    row0 += "]"

    res = []
    for item in loads(row0):
        tmp = (item['author_id'], item['first_name'], item['last_name'], item['patronymic'], item['rating'])
        res.append(tmp)
    return res

def search_books_by_title(arg : String):
    data = session.session.query(func.online_library_functional.search_books_by_title(arg)).all()
    row0 = "["
    for row in data:
        if (row[0] != None):
            for item in row[0]:
                string_data = dumps(item)
                if (item != row[0][0]):
                    row0 += ', ' + string_data
                else:
                    row0 += string_data
        else:
            return None
    row0 += "]"

    res = []
    for item in loads(row0):
        tmp = (item['book_id'], item['title'], item['genre'], item['publication_year'], item['rating'])
        res.append(tmp)
    return res


def search_books_by_author_nsp(arg : String):
    data = session.session.query(func.online_library_functional.search_books_by_author_nsp(arg)).all()
    row0 = "["
    for row in data:
        if (row[0] != None):
            for item in row[0]:
                string_data = dumps(item)
                if (item != row[0][0]):
                    row0 += ', ' + string_data
                else:
                    row0 += string_data
        else:
            return None
    row0 += "]"

    res = []
    for item in loads(row0):
        tmp = (item['book_id'], item['title'], item['genre'], item['publication_year'], item['rating'])
        res.append(tmp)
    return res



def search_books_by_publisher_name(arg : str):
    data = session.session.query(func.online_library_functional.search_books_by_publisher_name(arg)).all()
    row0 = "["
    for row in data:
        if (row[0] != None):
            for item in row[0]:
                string_data = dumps(item)
                if (item != row[0][0]):
                    row0 += ', ' + string_data
                else:
                    row0 += string_data
        else:
            return None
    row0 += "]"

    res = []
    for item in loads(row0):
        tmp = (item['book_id'], item['title'], item['genre'], item['publication_year'], item['rating'])
        res.append(tmp)
    return res


def search_publishers_by_city(arg : str):
    data = session.session.query(func.online_library_functional.search_publishers_by_city(arg)).all()
    row0 = "["
    for row in data:
        if (row[0] != None):
            for item in row[0]:
                string_data = dumps(item)
                if (item != row[0][0]):
                    row0 += ', ' + string_data
                else:
                    row0 += string_data
        else:
            return None
    row0 += "]"

    res = []
    for item in loads(row0):
        tmp = (item['publisher_id'], item['publisher_name'], item['city'], item['email'], item['address'])
        res.append(tmp)
    return res


def search_publishers_by_name(arg : str):
    data = session.session.query(func.online_library_functional.search_publishers_by_name(arg)).all()
    row0 = "["
    for row in data:
        if (row[0] != None):
            for item in row[0]:
                string_data = dumps(item)
                if (item != row[0][0]):
                    row0 += ', ' + string_data
                else:
                    row0 += string_data
        else:
            return None
    row0 += "]"

    res = []
    for item in loads(row0):
        tmp = (item['publisher_id'], item['publisher_name'], item['city'], item['email'], item['address'])
        res.append(tmp)
    return res



def search_books_by_genre(arg : str):
    data = session.session.execute(func.online_library_functional.search_books_by_genre(arg)).all()
    row0 = "["
    for row in data:
        if (row[0] != None):
            for item in row[0]:
                string_data = dumps(item)
                if (item != row[0][0]):
                    row0 += ', ' + string_data
                else:
                    row0 += string_data
        else:
            return None
    row0 += "]"

    res = []
    for item in loads(row0):
        tmp = (item['book_id'], item['title'], item['genre'], item['publication_year'], item['rating'])
        res.append(tmp)
    return res


def login_func_data(login : str, password : str) -> int:
    # login = encrypte_string(login)
    # password = encrypte_string(password)
    data = session.session.execute(func.online_library_functional.get_user_id_and_is_admin_by_user_email_and_password(login, password)).all()
    row0 = "["
    for row in data:
        if (row[0] != None):
            for item in row[0]:
                string_data = dumps(item)
                if (item != row[0][0]):
                    row0 += ', ' + string_data
                else:
                    row0 += string_data
        else:
            return None
    row0 += "]"
    for item in loads(row0):
        return item


def register_func_data(
    first_name : str,
	last_name : str,
	phone : str,
	email : str,
	password : str,
	is_admin = False,
	patronymic = None
):

    session.session.execute(func.online_library_functional.insert_into_table_user(first_name, last_name, phone, email, password, is_admin, patronymic))
    session.session.commit()


def search_all_books():
    data = session.session.execute(func.online_library_functional.get_all_data_from_table_by_table_name('book')).all()
    row0 = "["
    for row in data:
        if (row[0] != None):
            for item in row[0]:
                string_data = dumps(item)
                if (item != row[0][0]):
                    row0 += ', ' + string_data
                else:
                    row0 += string_data
        else:
            return None
    row0 += "]"

    res = []
    for item in loads(row0):
        tmp = (item['book_id'], item['title'], item['genre'], item['publication_year'], item['rating'])
        res.append(tmp)
    return res


def search_all_authors():
    data = session.session.execute(func.online_library_functional.get_all_data_from_table_by_table_name('author')).all()
    row0 = "["
    for row in data:
        if (row[0] != None):
            for item in row[0]:
                string_data = dumps(item)
                if (item != row[0][0]):
                    row0 += ', ' + string_data
                else:
                    row0 += string_data
        else:
            return None
    row0 += "]"
    res = []
    for item in loads(row0):
        tmp = (item['author_id'], item['first_name'], item['last_name'], item['patronymic'], item['rating'])
        res.append(tmp)
    return res


def search_all_publishers():
    data = session.session.execute(func.online_library_functional.get_all_data_from_table_by_table_name('publisher')).all()
    row0 = "["
    for row in data:
        if (row[0] != None):
            for item in row[0]:
                string_data = dumps(item)
                if (item != row[0][0]):
                    row0 += ', ' + string_data
                else:
                    row0 += string_data
        else:
            return None
    row0 += "]"
    res = []
    for item in loads(row0):
        tmp = (item['publisher_id'], item['publisher_name'], item['city'], item['email'], item['address'])
        res.append(tmp)
    return res

def insert_into_table_saving(id: int, arg: int):
    session.session.execute(func.online_library_functional.insert_into_table_saving(id, arg))
    session.session.commit()

def search_all_my_books():
    data = session.session.execute(func.online_library_functional.get_all_data_from_table_saving()).all()
    row0 = "["
    for row in data:
        if (row[0] != None):
            for item in row[0]:
                string_data = dumps(item)
                if (item != row[0][0]):
                    row0 += ', ' + string_data
                else:
                    row0 += string_data
        else:
            return None
    row0 += "]"
    res = []
    for item in loads(row0):
        tmp = (item['saving_id'], item['title'], item['genre'], item['user_rating'], item['saving_date'])
        res.append(tmp)
    return res

def search_all_users():
    data = session.session.execute(func.online_library_functional.get_all_data_from_table_by_table_name('user')).all()
    row0 = "["
    for row in data:
        if (row[0] != None):
            for item in row[0]:
                string_data = dumps(item)
                if (item != row[0][0]):
                    row0 += ', ' + string_data
                else:
                    row0 += string_data
        else:
            return None
    row0 += "]"
    res = []
    for item in loads(row0):
        tmp = (item['user_id'], item['email'], item['phone'], f'{item['last_name']} {item['first_name']} {item['patronymic']}')
        res.append(tmp)
    return res

def remove_book_in_saving(id: int):
    session.session.execute(func.online_library_functional.delete_row_by_id('saving', 'saving_id', id))
    session.session.commit()


def drop_database():
    session.session.execute(func.online_library_init.drop_database())
    session.session.commit()


def initialize_database():
    session.session.execute(func.online_library_init.initialize_database())
    session.session.commit()


def rate_book(id: int, rate: int):
    session.session.execute(func.online_library_functional.set_rating_into_table_saving(id, rate))
    session.session.commit()

def delete_author(id: int):
    session.session.execute(func.online_library_functional.delete_row_by_id('author', 'author_id', id))
    session.session.commit()

def delete_book(id: int):
    session.session.execute(func.online_library_functional.delete_row_by_id('book', 'book_id', id))
    session.session.commit()

def delete_publisher(id: int):
    session.session.execute(func.online_library_functional.delete_row_by_id('publisher', 'publisher_id', id))
    session.session.commit()

def add_book(in_title: str, in_genre: str, in_publisher_id: int, in_publication_year: int, author_id: int):
    data = session.session.execute(func.online_library_functional.insert_into_table_book(in_title, in_genre, in_publisher_id, in_publication_year)).all()
    session.session.commit()
    session.session.execute(func.online_library_functional.insert_into_table_book_author(data[0][0], author_id))
    session.session.commit()


def add_author(in_first_name: str, in_last_name: str, in_patronymic: str):
    session.session.execute(func.online_library_functional.insert_into_table_author(in_first_name, in_last_name, in_patronymic))
    session.session.commit()

def add_publisher(in_name: str, city: str, adress: str, email: str):
    session.session.execute(func.online_library_functional.insert_into_table_publisher(in_name, city, adress, email))
    session.session.commit()

def edit_publisher(id: int, title: str, city: str, adress: str, email: str):
    session.session.execute(func.online_library_functional.update_into_table_publisher(id, title, city, adress, email))
    session.session.commit()

def edit_book(id: int, in_title: str, in_genre: str, in_publisher_id: int, in_publication_year: int, author_id: int):
    session.session.execute(func.online_library_functional.update_into_table_book(id, in_title, in_genre, in_publisher_id, in_publication_year)).all()
    session.session.commit()
def edit_author(id: int, in_first_name: str, in_last_name: str, in_patronymic: str):
    session.session.execute(func.online_library_functional.update_into_table_author(id, in_first_name, in_last_name, in_patronymic))
    session.session.commit()

def delete_user(id: int):
    session.session.execute(func.online_library_functional.delete_row_by_id('user', 'user_id', id))
    session.session.commit()