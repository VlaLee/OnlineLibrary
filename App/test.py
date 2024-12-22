from sqlalchemy import create_engine, MetaData, Column, Row, Integer, String, ForeignKey
from sqlalchemy import func
from sqlalchemy.orm import sessionmaker
from sqlalchemy.orm import declarative_base
from json import loads, dumps


login = 'library_owner'
password = '102255'


# connection = psycopg2.connect(
#     dbname="library",
#     user="library_owner",
#     password="102255",
#     host="localhost",  # Или IP-адрес сервера базы данных
#     port="5432"        # По умолчанию 5432
# )

engine = create_engine(
    'postgresql+psycopg2://library_owner:102255@localhost/library',
    echo=False,
    isolation_level='SERIALIZABLE'
)

Base = declarative_base()
metadata = MetaData()

Session = sessionmaker(bind=engine)

with Session() as session:

    _upload = {
        'in_author_nsp': 'Достоевский'
    }
    data = session.query(func.online_library_functional.search_authors_by_author_nsp('фёдор')).all()
    row0 = "["
    for row in data:
        for item in row[0]:
            string_data = dumps(item)
            if (item != row[0][0]):
                row0 += ', ' + string_data
            else:
                row0 += string_data
    row0 += "]"
    print(loads(row0))
  #  [('(1,'Фёдор','Достоевский','Михайлович',)',)]