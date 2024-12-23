from sqlalchemy import create_engine, MetaData, Column, Row, Integer, String, ForeignKey
from sqlalchemy import func
from sqlalchemy.orm import sessionmaker
from sqlalchemy.orm import declarative_base
from json import loads, dumps
import re
from cryptography.fernet import Fernet



class Book():
    def __init__(self):
        self.book_data = {
            'title': None,
            'id': None,
            'genre': None,
            'publication_year': None,
            'rating': None
        }
    def __init__(self, title, genre, id, publication_year, rating):
        self.book_data = {
            'title': title,
            'id': id,
            'genre': genre,
            'publication_year': publication_year,
            'rating': rating
        }
    

login = 'library_owner'
password = '102255'

key = b'4qmRF8hE7ti5lIFmsKNlMe0VgrNwsav0pi4DNMgxAsI='
cipher_suite = Fernet(key)


engine = create_engine(
    'postgresql+psycopg2://library_owner:102255@localhost/library',
    echo=False,
    isolation_level='SERIALIZABLE'
)

Base = declarative_base()
metadata = MetaData()

Session = sessionmaker(bind=engine)

session = Session()

def encrypte_string(arg : str):
    # Шифрование данных
    encrypted_data = cipher_suite.encrypt(arg.encode())

    return encrypted_data.decode()


def decrypte_string(arg : str):
    # Дешифрование данных
    decrypted_data = cipher_suite.decrypt(arg.encode())

    return decrypted_data.decode()
    


def search_authors_by_author_nsp(arg : String):
    data = session.query(func.online_library_functional.search_authors_by_author_nsp(arg)).all()
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
        tmp = (item['first_name'], item['last_name'], item['patronymic'], item['rating'])
        res.append(tmp)
    return res

def search_books_by_title(arg : String):
    data = session.query(func.online_library_functional.search_books_by_title(arg)).all()
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
        tmp = (item['title'], item['genre'], item['publication_year'], item['rating'], item['book_id'])
        res.append(tmp)
    return res


def search_books_by_author_nsp(arg : String):
    data = session.query(func.online_library_functional.search_books_by_author_nsp(arg)).all()
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
        tmp = (item['title'], item['genre'], item['publication_year'], item['rating'], item['book_id'])
        res.append(tmp)
    return res



def search_books_by_publisher_name(arg : str):
    data = session.query(func.online_library_functional.search_books_by_publisher_name(arg)).all()
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
        tmp = (item['title'], item['genre'], item['publication_year'], item['rating'], item['book_id'])
        res.append(tmp)
    return res


def search_publishers_by_city(arg : str):
    data = session.query(func.online_library_functional.search_publishers_by_city(arg)).all()
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
        tmp = (item['publisher_name'], item['city'], item['email'], item['address'])
        res.append(tmp)
    return res


def search_publishers_by_name(arg : str):
    data = session.query(func.online_library_functional.search_publishers_by_name(arg)).all()
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
        tmp = (item['publisher_name'], item['city'], item['email'], item['address'])
        res.append(tmp)
    return res



def search_books_by_genre(arg : str):
    data = session.execute(func.online_library_functional.search_books_by_genre(arg)).all()
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
        tmp = (item['title'], item['genre'], item['publication_year'], item['rating'], item['book_id'])
        res.append(tmp)
    return res


def login_func_data(login : str, password : str) -> int:
    # login = encrypte_string(login)
    # password = encrypte_string(password)
    data = session.execute(func.online_library_functional.get_user_id_and_is_admin_by_user_email_and_password(login, password)).all()
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
    # first_name = encrypte_string(first_name)
    # last_name = encrypte_string(last_name)
    # phone = encrypte_string(phone)
    # email = encrypte_string(email)
    # password = encrypte_string(password)
    # patronymic = encrypte_string(patronymic)

    session.execute(func.online_library_functional.insert_into_table_user(first_name, last_name, phone, email, password, is_admin, patronymic))
    session.commit()


def search_all_books():
    data = session.execute(func.online_library_functional.get_all_data_from_table_by_table_name('book')).all()
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
        tmp = (item['title'], item['genre'], item['publication_year'], item['rating'], item['book_id'])
        res.append(tmp)
    return res


def search_all_authors():
    data = session.execute(func.online_library_functional.get_all_data_from_table_by_table_name('author')).all()
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
        tmp = (item['first_name'], item['last_name'], item['patronymic'], item['rating'])
        res.append(tmp)
    return res


def search_all_publishers():
    data = session.execute(func.online_library_functional.get_all_data_from_table_by_table_name('publisher')).all()
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
        tmp = (item['publisher_name'], item['city'], item['email'], item['address'])
        res.append(tmp)
    return res

def insert_into_table_saving(id: int, arg: int):
    session.execute(func.online_library_functional.insert_into_table_saving(id, arg)).all()
    session.commit()

def search_all_my_books():
    data = session.execute(func.online_library_functional.get_all_data_from_table_by_table_name('saving')).all()
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
        print(item)
        # tmp = (item['title'], item['genre'], item['publication_year'], item['rating'], item['saving_id'])
        # res.append(tmp)
    return res
