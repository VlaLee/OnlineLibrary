from tkinter import *
from tkinter import ttk
import Database

class Application(Tk):
    def __init__(self, screenName = "Data Base Lab", baseName = None, className = "Tk", useTk = True, sync = False, use = None):
        super().__init__(screenName, baseName, className, useTk, sync, use)
        self.user_data = {
            "username": None,
            "role" : None,
            "id": None
        }
        self.geometry("300x250")
        self.resizable(False, False)
        self.__screenName = screenName
        self.login_show()

        try:
            Database.initialize_database()
        except:
            pass


    def destroy_all(self):
        for i in self.winfo_children():
            i.destroy()


    def show_menu(self):
        self.destroy_all()
        self.geometry("700x700")
        self.title(f'{self.__screenName} (Вход Уже)')
        self.resizable(True, True)

        if (self.user_data["role"] == "admin"):
            admin_frame = Admin_Frame()
            admin_frame.pack(fill=BOTH, expand=True)
        else:
            notebook = ttk.Notebook()
            notebook.pack(fill=BOTH, expand=True)

            profile_frame = Profile_Frame(notebook)
            profile_frame.pack(fill=BOTH, expand=True)
            notebook.add(profile_frame, text="Профиль")

            all_books_frame = All_Books_Frame(notebook)
            all_books_frame.pack(fill=BOTH, expand=True)
            notebook.add(all_books_frame, text="Все книги")

            all_autors_frame = All_Authors_Frame(notebook)
            all_autors_frame.pack(fill=BOTH, expand=True)
            notebook.add(all_autors_frame, text="Все авторы")

            all_publisher_frame = All_Publisher_Frame(notebook)
            all_publisher_frame.pack(fill=BOTH, expand=True)
            notebook.add(all_publisher_frame, text="Все издательства")
            
            search_frame = Search_Frame(notebook)
            search_frame.pack(fill=BOTH, expand=True)
            notebook.add(search_frame, text="Поиск")
            


    def registration_show(self):
        self.title(f'{self.__screenName} (Регистрация)')
        self.geometry("400x450")
        self.destroy_all()

        login_lable = ttk.Label(text="*Логин")
        login_lable.pack(anchor=CENTER, pady=6)

        login_entry = ttk.Entry()
        login_entry.pack(anchor=CENTER)

        login_lable = ttk.Label(text="*Пароль")
        login_lable.pack(anchor=CENTER, pady=6)

        password_entry = ttk.Entry()
        password_entry.pack(anchor=CENTER)

        login_lable = ttk.Label(text="*Подтвердите Пароль")
        login_lable.pack(anchor=CENTER, pady=6)

        check_password_entry = ttk.Entry()
        check_password_entry.pack(anchor=CENTER)

        firstname_lable = ttk.Label(text="*Имя")
        firstname_lable.pack(anchor=CENTER, pady=6)
        
        firstname_entry = ttk.Entry()
        firstname_entry.pack(anchor=CENTER)

        lastname_lable = ttk.Label(text="*Фамилия")
        lastname_lable.pack(anchor=CENTER, pady=6)

        lastname_entry = ttk.Entry()
        lastname_entry.pack(anchor=CENTER)

        patronymic_label = ttk.Label(text="Отчество")
        patronymic_label.pack(anchor=CENTER, pady=6)

        patronymic_entry = ttk.Entry()
        patronymic_entry.pack(anchor=CENTER)

        phone_number_lable = ttk.Label(text="*Телефон")
        phone_number_lable.pack(anchor=CENTER, pady=6)

        phone_number_entry = ttk.Entry()
        phone_number_entry.pack(anchor=CENTER)

        error_label = Label(self, text="", fg="red")
        error_label.pack()

        def registration_func():
            login = login_entry.get()
            password = password_entry.get()
            check_password = check_password_entry.get()
            firstname = firstname_entry.get()
            lastname = lastname_entry.get()
            phone_number = phone_number_entry.get()
            patronymic = patronymic_entry.get()
            if (len(login) == 0 or len(password) == 0 or len(check_password) == 0 or \
                len(firstname) == 0 or len(lastname) == 0 or len(phone_number) == 0):
                error_label.config(text="Заполните все поля с символом *")
            elif (len(login) < 3):
                error_label.config(text="Логин должен быть не менее 3 символов")
            elif (len(password) < 8):
                error_label.config(text="Пароль должен быть не менее 8 символов")
            elif (password == login):
                error_label.config(text="Пароль не должен совпадать с логином")
            elif (password == firstname):
                error_label.config(text="Пароль не должен совпадать с именем")
            elif (password == lastname):
                error_label.config(text="Пароль не должен совпадать с фамилией")
            elif (password == patronymic):
                error_label.config(text="Пароль не должен совпадать с отчеством")
            elif (password == phone_number):
                error_label.config(text="Пароль не должен совпадать с номером телефона")
            elif (password == "12345678"):
                error_label.config(text="Неверный пароль")
            elif (password != check_password):
                error_label.config(text="Пароли не совпадают")
            else:
                try:
                    Database.register_func_data(firstname, lastname, phone_number, login, password, False, patronymic)
                    self.registration_func_off()
                except:
                    error_label.config(text="Такой пользователь уже существует")

        registration_button_off = ttk.Button(text="Зарегистрироваться", command=registration_func)
        registration_button_off.pack(anchor=CENTER, padx=6, pady=6)


    def login_show(self):
        self.geometry("300x250")
        self.title(f'{self.__screenName} (Вход)')
        self.destroy_all()

        login_lable = ttk.Label(text="Логин")
        login_lable.pack(anchor=CENTER, padx=6, pady=6)

        login_entry = ttk.Entry()
        login_entry.pack(anchor=CENTER)

        password_lable = ttk.Label(text="Пароль")
        password_lable.pack(anchor=CENTER, padx=6, pady=6)

        password_entry = ttk.Entry()
        password_entry.pack(anchor=CENTER)

        error_label = Label(self, text="", fg="red")
        error_label.pack()

        def login():
            login = login_entry.get()
            password = password_entry.get()





# ####################################################################################################
#             self.user_data["role"] = "admin"
#             self.show_menu()
#             return
# ####################################################################################################




            data = Database.login_func_data(login=login, password=password)
            if data != None:
                self.user_data["username"] = login_entry.get()
                if (data["is_admin"]):
                    self.user_data["role"] = "admin"
                else:
                    self.user_data["role"] = "admin"
                self.user_data["id"] = data["user_id"]
                self.show_menu()
            else:
                error_label.config(text="Неверный логин/пароль")

        login_button = ttk.Button(text="Войти", command=login)
        login_button.pack(anchor=CENTER, padx=6, pady=6)

        registration_button = ttk.Button(text="Зарегестрироваться", command=self.registration_show)
        registration_button.pack(anchor=CENTER, padx=6, pady=6)


    def registration_func_off(self):
        self.destroy_all()
        self.title(f'{self.__screenName} (Регистрация прошла успешно)')
        succes_label = ttk.Label(text="Регистрация прошла успешно")
        succes_label.pack(anchor=CENTER, padx=6, pady=6)

        go_to_login_button = ttk.Button(text="Вернуться", command=self.login_show)
        go_to_login_button.pack(anchor=CENTER, padx=6, pady=6)

class My_Shelf_Frame(Frame):
    def __init__(self, parent = None):
        super().__init__(parent)
        self.pack(fill=BOTH, expand=True)
        self.__init_ui__()
    def __init_ui__(self):
        frame1 = Frame(self)
        frame1.place(relx=0, rely=0, relheight=0.1, relwidth=1)
        frame1.rowconfigure(0, weight=1)
        frame1.columnconfigure(0, weight=15)
        frame1.columnconfigure(1, weight=1)
        frame2 = Frame(self)
        frame2.place(relx=0, rely=0.1, relheight=0.9, relwidth=1)
        search_treeview = ttk.Treeview(frame2, columns=("1", "2", "3", "4"), show='headings', height=8, selectmode="browse")

        def sort(col, reverse):
            l = [(search_treeview.set(k, col), k) for k in search_treeview.get_children("")]
            l.sort(reverse=reverse)

            for index,  (_, k) in enumerate(l):
                search_treeview.move(k, "", index)

            search_treeview.heading(col, command=lambda: sort(col, not reverse))

        search_treeview.heading("1", text="Название", command=lambda: sort(0, False))
        search_treeview.heading("2", text="Жанр", command=lambda: sort(1, False))
        search_treeview.heading("3", text="Год Публикации", command=lambda: sort(2, False))
        search_treeview.heading("4", text="Рейтинг", command=lambda: sort(3, False))
        search_treeview.pack(fill=BOTH, expand=True)
        data = Database.search_all_my_books()
        if (data != None):
            for i in data:
                search_treeview.insert(parent='', index=END, values=i, tags=i[len(i)-1])
        def add_data():
            for item in search_treeview.get_children():
                search_treeview.delete(item)
            data = Database.search_all_my_books()
            if (data != None):
                for i in data:
                    search_treeview.insert(parent='', index=END, values=i, tags=i[len(i)-1])
        def remove_book():
            item = search_treeview.item(search_treeview.selection())
            print(item["tags"][0])

        search_button = ttk.Button(frame1, text="Обновить", command=add_data)
        search_button.grid(row=0, column=1, sticky=EW, padx=6)
        search_button = ttk.Button(frame1, text="Убрать", command=remove_book)
        search_button.grid(row=1, column=1, sticky=EW, padx=6)


class Delete_User_Frame(Frame):
    def __init__(self, parent = None):
        super().__init__(parent)
        self.pack(fill=BOTH, expand=True)
        self.__init_ui__()
    def __init_ui__(self):
        frame1 = Frame(self)
        frame1.place(relx=0, rely=0, relheight=0.1, relwidth=1)
        frame1.rowconfigure(0, weight=1)
        frame1.columnconfigure(0, weight=15)
        frame1.columnconfigure(1, weight=1)
        frame2 = Frame(self)
        frame2.place(relx=0, rely=0.1, relheight=0.9, relwidth=1)
        search_entry = ttk.Entry(frame1)
        search_entry.grid(row=0, column=0, padx=6, sticky=EW)
        search_treeview = ttk.Treeview(frame2, columns=("1", "2", "3", "4"), show='headings', height=8, selectmode="browse")

        def sort(col, reverse):
            l = [(search_treeview.set(k, col), k) for k in search_treeview.get_children("")]
            l.sort(reverse=reverse)

            for index,  (_, k) in enumerate(l):
                search_treeview.move(k, "", index)

            search_treeview.heading(col, command=lambda: sort(col, not reverse))

        search_treeview.heading("1", text="user_id", command=lambda: sort(0, False))
        search_treeview.heading("2", text="Email(Login)", command=lambda: sort(1, False))
        search_treeview.heading("3", text="Phone", command=lambda: sort(2, False))
        search_treeview.heading("4", text="FIO", command=lambda: sort(3, False))
        search_treeview.pack(fill=BOTH, expand=True)
        data = Database.search_all_users()
        if (data != None):
            for i in data:
                search_treeview.insert(parent='', index=END, values=i, tags=i[0])
        def add_data():
            for item in search_treeview.get_children():
                search_treeview.delete(item)
            str = search_entry.get()
            if (str != ""):
                data = Database.search_all_users()
                if (data != None):
                    for i in data:
                        search_treeview.insert(parent='', index=END, values=i, tags=i[0])
            else:
                data = Database.search_all_users()
                if (data != None):
                    for i in data:
                        search_treeview.insert(parent='', index=END, values=i, tags=i[0])
        def add_book():
            item = search_treeview.item(search_treeview.selection())
            print(item["tags"][0])

        search_button = ttk.Button(frame1, text="Поиск", command=add_data)
        search_button.grid(row=0, column=1, sticky=EW, padx=6)
        search_button = ttk.Button(frame1, text="Удалить", command=add_book)
        search_button.grid(row=1, column=1, sticky=EW, padx=6)


class Delete_Book_Frame(Frame):
    def __init__(self, parent = None):
        super().__init__(parent)
        self.pack(fill=BOTH, expand=True)
        self.__init_ui__()
    def __init_ui__(self):
        notebook = ttk.Notebook(self)
        notebook.pack(fill=BOTH, expand=True)

        author_frame = Search_Book_Title_Frame(notebook)
        author_frame.pack(fill=BOTH, expand=True)
        notebook.add(author_frame, text="По Названию")

        book_frame = Search_Book_Author_Frame(notebook)
        book_frame.pack(fill=BOTH, expand=True)
        notebook.add(book_frame, text="По Авторам")

        publisher_frame = Search_Book_Publisher_Frame(notebook)
        publisher_frame.pack(fill=BOTH, expand=True)
        notebook.add(publisher_frame, text="По Издательсвам")

        publisher_frame = Search_Book_Genre_Frame(notebook)
        publisher_frame.pack(fill=BOTH, expand=True)
        notebook.add(publisher_frame, text="По жанру")

class Buttons_Frame(Frame):
    def __init__(self, parent = None):
        super().__init__(parent)
        self.pack(fill=BOTH, expand=True)
        self.__init_ui__()
    def __init_ui__(self):
        frame = Frame(self)
        frame.pack(fill=BOTH, expand=True)
        frame.rowconfigure(0, weight=1)
        frame.columnconfigure(0, weight=15)
        frame.columnconfigure(1, weight=1)

        def drop_database():
            Database.drop_database()
        def init_database():
            Database.initialize_database()

        label = Label(frame, text="Кнопочки")
        label.pack()
        button1 = ttk.Button(frame, text="Удалить Таблицу", command=drop_database)
        button1.pack()

        label = Label(frame, text="Кнопочки")
        label.pack()
        button1 = ttk.Button(frame, text="Создать Таблицу", command=init_database)
        button1.pack()

        label = Label(frame, text="Кнопочки")
        label.pack()
        button1 = ttk.Button(frame, text="Обновить", command=None)
        button1.pack()

        label = Label(frame, text="Кнопочки")
        label.pack()
        button1 = ttk.Button(frame, text="Обновить", command=None)
        button1.pack()
        

class Admin_Frame(Frame):
    def __init__(self, parent = None):
        super().__init__(parent)
        self.pack(fill=BOTH, expand=True)
        self.__init_ui__()
    def __init_ui__(self):
        notebook = ttk.Notebook(self)
        notebook.pack(fill=BOTH, expand=True)

        author_frame = Me_Frame(notebook)
        author_frame.pack(fill=BOTH, expand=True)
        notebook.add(author_frame, text="Профиль")

        author_frame = Buttons_Frame(notebook)
        author_frame.pack(fill=BOTH, expand=True)
        notebook.add(author_frame, text="Кнопочки")

        author_frame = Delete_Book_Frame(notebook)
        author_frame.pack(fill=BOTH, expand=True)
        notebook.add(author_frame, text="Удалить Книгу")

        author_frame = Delete_User_Frame(notebook)
        author_frame.pack(fill=BOTH, expand=True)
        notebook.add(author_frame, text="Удалить Пользователя")

        author_frame = Me_Frame(notebook)
        author_frame.pack(fill=BOTH, expand=True)
        notebook.add(author_frame, text="Удалить Книгу")

        author_frame = Me_Frame(notebook)
        author_frame.pack(fill=BOTH, expand=True)
        notebook.add(author_frame, text="Удалить Книгу")

class All_Publisher_Frame(Frame):
    def __init__(self, parent = None):
        super().__init__(parent)
        self.pack(fill=BOTH, expand=True)
        self.__init_ui__()
    def __init_ui__(self):
        data = Database.search_all_publishers()
        frame1 = Frame(self)
        frame1.place(relx=0, rely=0, relheight=0.1, relwidth=1)
        frame1.rowconfigure(0, weight=1)
        frame1.columnconfigure(0, weight=15)
        frame1.columnconfigure(1, weight=1)
        frame2 = Frame(self)
        frame2.place(relx=0, rely=0.1, relheight=0.9, relwidth=1)
        search_treeview = ttk.Treeview(frame2, columns=("1", "2", "3", "4"), show='headings', height=8, selectmode="browse")

        def sort(col, reverse):
            l = [(search_treeview.set(k, col), k) for k in search_treeview.get_children("")]
            l.sort(reverse=reverse)

            for index,  (_, k) in enumerate(l):
                search_treeview.move(k, "", index)

            search_treeview.heading(col, command=lambda: sort(col, not reverse))

        search_treeview.heading("1", text="Название", command=lambda: sort(0, False))
        search_treeview.heading("2", text="Город", command=lambda: sort(1, False))
        search_treeview.heading("3", text="Электронная Почта", command=lambda: sort(2, False))
        search_treeview.heading("4", text="Адрес", command=lambda: sort(3, False))
        search_treeview.pack(fill=BOTH, expand=True)
        if (data != None):
            for i in data:
                search_treeview.insert(parent='', index=END, values=i)


        def add_data():
            for item in search_treeview.get_children():
                search_treeview.delete(item)
            data = Database.search_all_publishers()
            if (data != None):
                for i in data:
                    search_treeview.insert(parent='', index=END, values=i)


        search_button = ttk.Button(frame1, text="Обновить", command=add_data)
        search_button.grid(row=0, column=1, sticky=EW, padx=6)

class Me_Frame(Frame):
    def __init__(self, parent = None):
        super().__init__(parent)
        self.pack(fill=BOTH, expand=True)
        self.__init_ui__()
    def __init_ui__(self):
        exit_button = ttk.Button(self, text="Выход", command=root.login_show)
        exit_button.pack()


class Profile_Frame(Frame):
    def __init__(self, parent = None):
        super().__init__(parent)
        self.pack(fill=BOTH, expand=True)
        self.__init_ui__()
    
    def __init_ui__(self):
        notebook = ttk.Notebook(self)
        notebook.pack(fill=BOTH, expand=True)

        author_frame = Me_Frame(notebook)
        author_frame.pack(fill=BOTH, expand=True)
        notebook.add(author_frame, text="        Я        ")

        author_frame = My_Shelf_Frame(notebook)
        author_frame.pack(fill=BOTH, expand=True)
        notebook.add(author_frame, text="Моя Полка")



class All_Books_Frame(Frame):
    def __init__(self, parent = None):
        super().__init__(parent)
        self.pack(fill=BOTH, expand=True)
        self.__init_ui__()
    def __init_ui__(self):
        data = Database.search_all_books()
        frame1 = Frame(self)
        frame1.place(relx=0, rely=0, relheight=0.1, relwidth=1)
        frame1.rowconfigure(0, weight=1)
        frame1.columnconfigure(0, weight=15)
        frame1.columnconfigure(1, weight=1)
        frame2 = Frame(self)
        frame2.place(relx=0, rely=0.1, relheight=0.9, relwidth=1)
        search_treeview = ttk.Treeview(frame2, columns=("1", "2", "3", "4"), show='headings', height=8, selectmode="browse")

        def sort(col, reverse):
            l = [(search_treeview.set(k, col), k) for k in search_treeview.get_children("")]
            l.sort(reverse=reverse)

            for index,  (_, k) in enumerate(l):
                search_treeview.move(k, "", index)

            search_treeview.heading(col, command=lambda: sort(col, not reverse))

        search_treeview.heading("1", text="Название", command=lambda: sort(0, False))
        search_treeview.heading("2", text="Жанр", command=lambda: sort(1, False))
        search_treeview.heading("3", text="Год Публикации", command=lambda: sort(2, False))
        search_treeview.heading("4", text="Рейтинг", command=lambda: sort(3, False))
        search_treeview.pack(fill=BOTH, expand=True)
        if (data != None):
            for i in data:
                search_treeview.insert(parent='', index=END, values=i, tags=i[len(i)-1])
                

        def add_book():
            item = search_treeview.item(search_treeview.selection())["tags"][0]
            Database.insert_into_table_saving(root.user_data["id"], item)
        def add_data():
            for item in search_treeview.get_children():
                search_treeview.delete(item)
            data = Database.search_all_books()
            if (data != None):
                for i in data:
                    search_treeview.insert(parent='', index=END, values=i, tags=i[len(i)-1])

        search_button = ttk.Button(frame1, text="Обновить", command=add_data)
        search_button.grid(row=0, column=1, sticky=EW, padx=6)
        search_button = ttk.Button(frame1, text="Добавить", command=add_book)
        search_button.grid(row=1, column=1, sticky=EW, padx=6)

class All_Authors_Frame(Frame):
    def __init__(self, parent = None):
        super().__init__(parent)
        self.pack(fill=BOTH, expand=True)
        self.__init_ui__()
    def __init_ui__(self):
        data = Database.search_all_authors()
        frame1 = Frame(self)
        frame1.place(relx=0, rely=0, relheight=0.1, relwidth=1)
        frame1.rowconfigure(0, weight=1)
        frame1.columnconfigure(0, weight=15)
        frame1.columnconfigure(1, weight=1)
        frame2 = Frame(self)
        frame2.place(relx=0, rely=0.1, relheight=0.9, relwidth=1)
        search_treeview = ttk.Treeview(frame2, columns=("1", "2", "3", "4"), show='headings', height=8, selectmode="browse")

        def sort(col, reverse):
            l = [(search_treeview.set(k, col), k) for k in search_treeview.get_children("")]
            l.sort(reverse=reverse)

            for index,  (_, k) in enumerate(l):
                search_treeview.move(k, "", index)

            search_treeview.heading(col, command=lambda: sort(col, not reverse))

        search_treeview.heading("1", text="Имя", command=lambda: sort(0, False))
        search_treeview.heading("2", text="Фамилия", command=lambda: sort(1, False))
        search_treeview.heading("3", text="Отчество", command=lambda: sort(2, False))
        search_treeview.heading("4", text="Рейтинг", command=lambda: sort(3, False))
        search_treeview.pack(fill=BOTH, expand=True)
        if (data != None):
            for i in data:
                search_treeview.insert(parent='', index=END, values=i)
        def add_data():
            for item in search_treeview.get_children():
                search_treeview.delete(item)
            data = Database.search_all_authors()
            if (data != None):
                for i in data:
                    search_treeview.insert(parent='', index=END, values=i)


        search_button = ttk.Button(frame1, text="Обновить", command=add_data)
        search_button.grid(row=0, column=1, sticky=EW, padx=6)


class Search_Book_Author_Frame(Frame):
    def __init__(self, parent = None):
        super().__init__(parent)
        self.pack(fill=BOTH, expand=True)
        self.__init_ui__()
    def __init_ui__(self):
        frame1 = Frame(self)
        frame1.place(relx=0, rely=0, relheight=0.1, relwidth=1)
        frame1.rowconfigure(0, weight=1)
        frame1.columnconfigure(0, weight=15)
        frame1.columnconfigure(1, weight=1)
        frame2 = Frame(self)
        frame2.place(relx=0, rely=0.1, relheight=0.9, relwidth=1)
        search_entry = ttk.Entry(frame1)
        search_entry.grid(row=0, column=0, padx=6, sticky=EW)
        search_treeview = ttk.Treeview(frame2, columns=("1", "2", "3", "4"), show='headings', height=8, selectmode="browse")

        def sort(col, reverse):
            l = [(search_treeview.set(k, col), k) for k in search_treeview.get_children("")]
            l.sort(reverse=reverse)

            for index,  (_, k) in enumerate(l):
                search_treeview.move(k, "", index)

            search_treeview.heading(col, command=lambda: sort(col, not reverse))

        search_treeview.heading("1", text="Название", command=lambda: sort(0, False))
        search_treeview.heading("2", text="Жанр", command=lambda: sort(1, False))
        search_treeview.heading("3", text="Год Публикации", command=lambda: sort(2, False))
        search_treeview.heading("4", text="Рейтинг", command=lambda: sort(3, False))
        search_treeview.pack(fill=BOTH, expand=True)

        def add_data():
            for item in search_treeview.get_children():
                search_treeview.delete(item)
            str = search_entry.get()
            data = Database.search_books_by_author_nsp(str)

            if (data != None):
                for i in data:
                    search_treeview.insert(parent='', index=END, values=i, tags=i[len(i)-1])
        def add_book():
            item = search_treeview.item(search_treeview.selection())
            print(item["tags"][0])

        search_button = ttk.Button(frame1, text="Поиск", command=add_data)
        search_button.grid(row=0, column=1, sticky=EW, padx=6)
        search_button = ttk.Button(frame1, text="Добавить", command=add_book)
        search_button.grid(row=1, column=1, sticky=EW, padx=6)

class Search_Book_Publisher_Frame(Frame):
    def __init__(self, parent = None):
        super().__init__(parent)
        self.pack(fill=BOTH, expand=True)
        self.__init_ui__()
    def __init_ui__(self):
        frame1 = Frame(self)
        frame1.place(relx=0, rely=0, relheight=0.1, relwidth=1)
        frame1.rowconfigure(0, weight=1)
        frame1.columnconfigure(0, weight=15)
        frame1.columnconfigure(1, weight=1)
        frame2 = Frame(self)
        frame2.place(relx=0, rely=0.1, relheight=0.9, relwidth=1)
        search_entry = ttk.Entry(frame1)
        search_entry.grid(row=0, column=0, padx=6, sticky=EW)
        search_treeview = ttk.Treeview(frame2, columns=("1", "2", "3", "4"), show='headings', height=8, selectmode="browse")

        def sort(col, reverse):
            l = [(search_treeview.set(k, col), k) for k in search_treeview.get_children("")]
            l.sort(reverse=reverse)

            for index,  (_, k) in enumerate(l):
                search_treeview.move(k, "", index)

            search_treeview.heading(col, command=lambda: sort(col, not reverse))

        search_treeview.heading("1", text="Название", command=lambda: sort(0, False))
        search_treeview.heading("2", text="Жанр", command=lambda: sort(1, False))
        search_treeview.heading("3", text="Год Публикации", command=lambda: sort(2, False))
        search_treeview.heading("4", text="Рейтинг", command=lambda: sort(3, False))
        search_treeview.pack(fill=BOTH, expand=True)

        def add_data():
            for item in search_treeview.get_children():
                search_treeview.delete(item)
            str = search_entry.get()
            data = Database.search_books_by_publisher_name(str)

            if (data != None):
                for i in data:
                    search_treeview.insert(parent='', index=END, values=i, tags=i[len(i)-1])

        def add_book():
            item = search_treeview.item(search_treeview.selection())
            print(item["tags"][0])

        search_button = ttk.Button(frame1, text="Поиск", command=add_data)
        search_button.grid(row=0, column=1, sticky=EW, padx=6)
        search_button = ttk.Button(frame1, text="Добавить", command=add_book)
        search_button.grid(row=1, column=1, sticky=EW, padx=6)


class Search_Book_Title_Frame(Frame):
    def __init__(self, parent = None):
        super().__init__(parent)
        self.pack(fill=BOTH, expand=True)
        self.__init_ui__()
    def __init_ui__(self):
        frame1 = Frame(self)
        frame1.place(relx=0, rely=0, relheight=0.1, relwidth=1)
        frame1.rowconfigure(0, weight=1)
        frame1.columnconfigure(0, weight=15)
        frame1.columnconfigure(1, weight=1)
        frame2 = Frame(self)
        frame2.place(relx=0, rely=0.1, relheight=0.9, relwidth=1)
        search_entry = ttk.Entry(frame1)
        search_entry.grid(row=0, column=0, padx=6, sticky=EW)
        search_treeview = ttk.Treeview(frame2, columns=("1", "2", "3", "4"), show='headings', height=8, selectmode="browse")

        def sort(col, reverse):
            l = [(search_treeview.set(k, col), k) for k in search_treeview.get_children("")]
            l.sort(reverse=reverse)

            for index,  (_, k) in enumerate(l):
                search_treeview.move(k, "", index)

            search_treeview.heading(col, command=lambda: sort(col, not reverse))

        search_treeview.heading("1", text="Название", command=lambda: sort(0, False))
        search_treeview.heading("2", text="Жанр", command=lambda: sort(1, False))
        search_treeview.heading("3", text="Год Публикации", command=lambda: sort(2, False))
        search_treeview.heading("4", text="Рейтинг", command=lambda: sort(3, False))
        search_treeview.pack(fill=BOTH, expand=True)

        def add_data():
            for item in search_treeview.get_children():
                search_treeview.delete(item)
            str = search_entry.get()
            data = Database.search_books_by_title(str)

            if (data != None):
                for i in data:
                    search_treeview.insert(parent='', index=END, values=i, tags=i[len(i)-1])

        def add_book():
            item = search_treeview.item(search_treeview.selection())
            print(item["tags"][0])

        search_button = ttk.Button(frame1, text="Поиск", command=add_data)
        search_button.grid(row=0, column=1, sticky=EW, padx=6)
        search_button = ttk.Button(frame1, text="Добавить", command=add_book)
        search_button.grid(row=1, column=1, sticky=EW, padx=6)


class Search_Book_Genre_Frame(Frame):
    def __init__(self, parent = None):
        super().__init__(parent)
        self.pack(fill=BOTH, expand=True)
        self.__init_ui__()
    def __init_ui__(self):
        frame1 = Frame(self)
        frame1.place(relx=0, rely=0, relheight=0.1, relwidth=1)
        frame1.rowconfigure(0, weight=1)
        frame1.columnconfigure(0, weight=15)
        frame1.columnconfigure(1, weight=1)
        frame2 = Frame(self)
        frame2.place(relx=0, rely=0.1, relheight=0.9, relwidth=1)
        search_entry = ttk.Entry(frame1)
        search_entry.grid(row=0, column=0, padx=6, sticky=EW)
        search_treeview = ttk.Treeview(frame2, columns=("1", "2", "3", "4"), show='headings', height=8, selectmode="browse")

        def sort(col, reverse):
            l = [(search_treeview.set(k, col), k) for k in search_treeview.get_children("")]
            l.sort(reverse=reverse)

            for index,  (_, k) in enumerate(l):
                search_treeview.move(k, "", index)

            search_treeview.heading(col, command=lambda: sort(col, not reverse))

        search_treeview.heading("1", text="Название", command=lambda: sort(0, False))
        search_treeview.heading("2", text="Жанр", command=lambda: sort(1, False))
        search_treeview.heading("3", text="Год Публикации", command=lambda: sort(2, False))
        search_treeview.heading("4", text="Рейтинг", command=lambda: sort(3, False))
        search_treeview.pack(fill=BOTH, expand=True)

        def add_data():
            for item in search_treeview.get_children():
                search_treeview.delete(item)
            str = search_entry.get()
            data = Database.search_books_by_genre(str)

            if (data != None):
                for i in data:
                    search_treeview.insert(parent='', index=END, values=i, tags=i[len(i)-1])

        def add_book():
            item = search_treeview.item(search_treeview.selection())
            print(item["tags"][0])

        search_button = ttk.Button(frame1, text="Поиск", command=add_data)
        search_button.grid(row=0, column=1, sticky=EW, padx=6)
        search_button = ttk.Button(frame1, text="Добавить", command=add_book)
        search_button.grid(row=1, column=1, sticky=EW, padx=6)

class Search_Book_Frame(Frame):
    def __init__(self, parent = None):
        super().__init__(parent)
        self.pack(fill=BOTH, expand=True)
        self.__init_ui__()
    def __init_ui__(self):
        notebook = ttk.Notebook(self)
        notebook.pack(fill=BOTH, expand=True)

        author_frame = Search_Book_Title_Frame(notebook)
        author_frame.pack(fill=BOTH, expand=True)
        notebook.add(author_frame, text="По Названию")

        book_frame = Search_Book_Author_Frame(notebook)
        book_frame.pack(fill=BOTH, expand=True)
        notebook.add(book_frame, text="По Авторам")

        publisher_frame = Search_Book_Publisher_Frame(notebook)
        publisher_frame.pack(fill=BOTH, expand=True)
        notebook.add(publisher_frame, text="По Издательсвам")

        publisher_frame = Search_Book_Genre_Frame(notebook)
        publisher_frame.pack(fill=BOTH, expand=True)
        notebook.add(publisher_frame, text="По жанру")


class Search_Publisher_Name_Frame(Frame):
    def __init__(self, parent = None):
        super().__init__(parent)
        self.pack(fill=BOTH, expand=True)
        self.__init_ui__()
    def __init_ui__(self):
        frame1 = Frame(self)
        frame1.place(relx=0, rely=0, relheight=0.1, relwidth=1)
        frame1.rowconfigure(0, weight=1)
        frame1.columnconfigure(0, weight=15)
        frame1.columnconfigure(1, weight=1)
        frame2 = Frame(self)
        frame2.place(relx=0, rely=0.1, relheight=0.9, relwidth=1)
        search_entry = ttk.Entry(frame1)
        search_entry.grid(row=0, column=0, padx=6, sticky=EW)
        search_treeview = ttk.Treeview(frame2, columns=("1", "2", "3", "4"), show='headings', height=8, selectmode="browse")

        def sort(col, reverse):
            l = [(search_treeview.set(k, col), k) for k in search_treeview.get_children("")]
            l.sort(reverse=reverse)

            for index,  (_, k) in enumerate(l):
                search_treeview.move(k, "", index)

            search_treeview.heading(col, command=lambda: sort(col, not reverse))

        search_treeview.heading("1", text="Название", command=lambda: sort(0, False))
        search_treeview.heading("2", text="Город", command=lambda: sort(1, False))
        search_treeview.heading("3", text="Электронная Почта", command=lambda: sort(2, False))
        search_treeview.heading("4", text="Адрес", command=lambda: sort(3, False))
        search_treeview.pack(fill=BOTH, expand=True)

        def add_data():
            for item in search_treeview.get_children():
                search_treeview.delete(item)
            str = search_entry.get()
            data = Database.search_publishers_by_name(str)

            if (data != None):
                for i in data:
                    search_treeview.insert(parent='', index=END, values=i)



        search_button = ttk.Button(frame1, text="Поиск", command=add_data)
        search_button.grid(row=0, column=1, sticky=EW, padx=6)


class Search_Publisher_City_Frame(Frame):
    def __init__(self, parent = None):
        super().__init__(parent)
        self.pack(fill=BOTH, expand=True)
        self.__init_ui__()
    def __init_ui__(self):
        frame1 = Frame(self)
        frame1.place(relx=0, rely=0, relheight=0.1, relwidth=1)
        frame1.rowconfigure(0, weight=1)
        frame1.columnconfigure(0, weight=15)
        frame1.columnconfigure(1, weight=1)
        frame2 = Frame(self)
        frame2.place(relx=0, rely=0.1, relheight=0.9, relwidth=1)
        search_entry = ttk.Entry(frame1)
        search_entry.grid(row=0, column=0, padx=6, sticky=EW)
        search_treeview = ttk.Treeview(frame2, columns=("1", "2", "3", "4"), show='headings', height=8, selectmode="browse")

        def sort(col, reverse):
            l = [(search_treeview.set(k, col), k) for k in search_treeview.get_children("")]
            l.sort(reverse=reverse)

            for index,  (_, k) in enumerate(l):
                search_treeview.move(k, "", index)

            search_treeview.heading(col, command=lambda: sort(col, not reverse))

        search_treeview.heading("1", text="Название", command=lambda: sort(0, False))
        search_treeview.heading("2", text="Город", command=lambda: sort(1, False))
        search_treeview.heading("3", text="Электронная Почта", command=lambda: sort(2, False))
        search_treeview.heading("4", text="Адрес", command=lambda: sort(3, False))
        search_treeview.pack(fill=BOTH, expand=True)

        def add_data():
            for item in search_treeview.get_children():
                search_treeview.delete(item)
            str = search_entry.get()
            data = Database.search_publishers_by_city(str)

            if (data != None):
                for i in data:
                    search_treeview.insert(parent='', index=END, values=i)

        search_button = ttk.Button(frame1, text="Поиск", command=add_data)
        search_button.grid(row=0, column=1, sticky=EW, padx=6)



class Search_Publisher_Frame(Frame):
    def __init__(self, parent = None):
        super().__init__(parent)
        self.pack(fill=BOTH, expand=True)
        self.__init_ui__()
    
    def __init_ui__(self):
        notebook = ttk.Notebook(self)
        notebook.pack(fill=BOTH, expand=True)
        
        publisher_frame = Search_Publisher_Name_Frame(notebook)
        publisher_frame.pack(fill=BOTH, expand=True)
        notebook.add(publisher_frame, text="По Названию")

        publisher_frame = Search_Publisher_City_Frame(notebook)
        publisher_frame.pack(fill=BOTH, expand=True)
        notebook.add(publisher_frame, text="По Городу")
    
        
class Search_Author_Frame(Frame):
    def __init__(self, parent = None):
        super().__init__(parent)
        self.pack(fill=BOTH, expand=True)
        self.__init_ui__()
    def __init_ui__(self):
        frame1 = Frame(self)
        frame1.place(relx=0, rely=0, relheight=0.1, relwidth=1)
        frame1.rowconfigure(0, weight=1)
        frame1.columnconfigure(0, weight=15)
        frame1.columnconfigure(1, weight=1)
        frame2 = Frame(self)
        frame2.place(relx=0, rely=0.1, relheight=0.9, relwidth=1)
        search_entry = ttk.Entry(frame1)
        search_entry.grid(row=0, column=0, padx=6, sticky=EW)
        search_treeview = ttk.Treeview(frame2, columns=("1", "2", "3", "4"), show='headings', height=8, selectmode="browse")

        def sort(col, reverse):
            l = [(search_treeview.set(k, col), k) for k in search_treeview.get_children("")]
            l.sort(reverse=reverse)

            for index,  (_, k) in enumerate(l):
                search_treeview.move(k, "", index)

            search_treeview.heading(col, command=lambda: sort(col, not reverse))

        search_treeview.heading("1", text="Имя", command=lambda: sort(0, False))
        search_treeview.heading("2", text="Фамилия", command=lambda: sort(1, False))
        search_treeview.heading("3", text="Отчество", command=lambda: sort(2, False))
        search_treeview.heading("4", text="Рейтинг", command=lambda: sort(2, False))
        search_treeview.pack(fill=BOTH, expand=True)

        def add_data():
            for item in search_treeview.get_children():
                search_treeview.delete(item)
            str = search_entry.get()
            data = Database.search_authors_by_author_nsp(str)

            if (data != None):
                for i in data:
                    search_treeview.insert(parent='', index=END, values=i)



        search_button = ttk.Button(frame1, text="Поиск", command=add_data)
        search_button.grid(row=0, column=1, sticky=EW, padx=6)


class Search_Frame(Frame):
    def __init__(self, parent = None):
        super().__init__(parent)
        self.pack(fill=BOTH, expand=True)
        self.__init_ui__()
    
    def __init_ui__(self):
        notebook = ttk.Notebook(self)
        notebook.pack(fill=BOTH, expand=True)

        author_frame = Search_Author_Frame(notebook)
        author_frame.pack(fill=BOTH, expand=True)
        notebook.add(author_frame, text="Авторы")

        book_frame = Search_Book_Frame(notebook)
        book_frame.pack(fill=BOTH, expand=True)
        notebook.add(book_frame, text="Книги")

        publisher_frame = Search_Publisher_Frame(notebook)
        publisher_frame.pack(fill=BOTH, expand=True)
        notebook.add(publisher_frame, text="Издательства")

root = Application()
root.mainloop()


