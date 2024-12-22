from sqlalchemy import create_engine, MetaData, Column, Row, Integer, String, ForeignKey
from sqlalchemy import func
from sqlalchemy.orm import sessionmaker
from sqlalchemy.orm import declarative_base
from json import loads, dumps

login = 'library_owner'
password = '102255'

engine = create_engine(
    'postgresql+psycopg2://library_owner:102255@localhost/library',
    echo=False,
    isolation_level='SERIALIZABLE'
)

Base = declarative_base()
metadata = MetaData()

Session = sessionmaker(bind=engine)

session = Session()

def search_authors_by_author_nsp(str : String):
    data = session.query(func.online_library_functional.search_authors_by_author_nsp(str)).all()
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
        tmp = (item['first_name'], item['last_name'], item['patronymic'])
        res.append(tmp)
    return res

def search_books_by_title(str : String):
    data = session.query(func.online_library_functional.search_books_by_title(str)).all()
    row0 = "["
    print(data)
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
        tmp = (item['title'], item['genre'], item['publication_year'], item['rating'])
        res.append(tmp)
    return res


def search_books_by_author_nsp(str : String):
    data = session.query(func.online_library_functional.search_books_by_author_nsp(str)).all()
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
        tmp = (item['title'], item['genre'], item['publication_year'], item['rating'])
        res.append(tmp)
    return res



def search_books_by_publisher_name(str : String):
    data = session.query(func.online_library_functional.search_books_by_publisher_name(str)).all()
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
        tmp = (item['title'], item['genre'], item['publication_year'], item['rating'])
        res.append(tmp)
    return res


def search_books_by_genre(str : String):
    data = session.query(func.online_library_functional.search_books_by_genre(str)).all()
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
        tmp = (item['title'], item['genre'], item['publication_year'], item['rating'])
        res.append(tmp)
    return res