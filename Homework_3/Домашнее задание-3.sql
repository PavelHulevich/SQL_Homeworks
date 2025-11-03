drop schema if exists citys_users;            --  добавлена команда удаления БД
create schema citys_users;                    -- добавлена команда создания БД
use citys_users;

drop table if exists users;
drop table if exists citys;

 create table citys (
 city_id int auto_increment primary key,
 city_name varchar(20) unique not null
 );

 create table users ( 
 users_id int auto_increment primary key,
 first_name varchar (15),
 last_name varchar (20),
 user_city int,
 foreign key (user_city) references citys(city_id)
 );
 alter table users add birthday date default '1900-01-01'                -- добавлен default
		check (birthday >= '1900-01-01' and birthday < '2025-10-25');

# check (birthday >= '1900-01-01' and birthday <= curdate());
# При сравнении с текущей датой появляется ошибка
# [HY000][3814] An expression of a check constraint 'users_chk_1' contains disallowed function: curdate.

# select * from users;

 insert users(first_name, last_name, birthday)
	values  ('Иванов', 'Петр', '1980-05-06'),
			('Сидоров', 'Иван', '1982-01-11'),
			('Петров', 'Сидор', '1975-11-06'),
			('Ковалев', 'Вася', '1986-05-06'),
            ('Васин', 'Виталий', '1980-05-06'),
            ('Виталин', 'Вася', '1980-05-06'),
            ('Коржов', 'Иван', '1980-05-06'),
            ('Кефиров', 'Коржик', '1980-05-06'),
            ('Белый', 'Петр', '1987-05-06'),
            ('Черный', 'Петр', '1988-05-06');
insert citys (city_name)
	values ('Рига'), ('Осло'), ('Мозырь'), ('Гадюкино'), ('Брест');
    
update users 
	set first_name = 'Мурзиков'
    where last_name = 'Додик';
    
update citys
	set city_name = 'Кобрино'
    where city_name = 'Гадюкино';

# ________________________ДОМАШНЯЯ РАБОТА №3 ___________________________

select * from users
    order by birthday;

select citys.city_name from citys;   -- вывод только названий городов из таблицы

select * from citys                  -- вывод названий городов у которых id больше 2
    where city_id > 2;

select users.last_name, count(users.last_name) as 'Сколько одинаковых имен' from users
    group by users.last_name
    having count(last_name) > 1
    order by count(last_name) desc ; -- вывод повторяющихся имен с указанием количества повторов.
