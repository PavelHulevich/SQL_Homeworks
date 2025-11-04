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
            ('Черный', 'Петр', '1987-05-06');
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
    order by birthday;               -- сортировка пользователей по дате рождения

select first_name, last_name, year(users.birthday) as Год_рождения from users
    where year((users.birthday)) > 1980
    order by birthday;               -- имена, фамилии и год рождения тех, кто родился после 1980 г.

select citys.city_name from citys;   -- вывод только названий городов из таблицы

select citys.city_name from citys
    order by city_name desc ;        -- вывод только названий городов с сортировкой в обратном порядке.

select * from citys                  -- вывод названий городов у которых id больше 2
    where city_id > 2;

select users.last_name, count(users.last_name) as 'Сколько одинаковых имен' from users
    group by users.last_name
    having count(last_name) > 1
    order by count(last_name) desc ; -- вывод повторяющихся имен с указанием количества повторов с сортировкой на уменьшение повторов.

select year(users.birthday) from users
    group by year(users.birthday);    -- все годы рождения пользователей из таблицы users

select year(users.birthday), count(users.birthday) from users
    group by year(users.birthday);         -- количество пользователей определенного года рождения

select year(users.birthday) as 'Годы в которых есть Петры', count(users.birthday) as 'Петры в этом году' from users
    where last_name in ('Петр')
    group by year(users.birthday);           -- Выводим с именем Петр и указанием года рождения и кол-ва Петров в этом году

select users.first_name, users.last_name, (year(curdate()) - year(users.birthday)) as 'Возраст' from users
    order by (year(curdate()) - year(users.birthday)); -- Вычисление возраста с сортировкой по возрасту.

select users.last_name, count(last_name), round(year(curdate()) - avg(year(users.birthday)),0) as 'Средний возраст' from users
group by users.last_name
having count(last_name) > 1;                -- Выводит количество и средний возраст всех юзеров с одинаковым именем

# ________________________ДОМАШНЯЯ РАБОТА №4 ___________________________

SELECT *
    FROM users
    WHERE YEAR(users.birthday) LIKE '%80';  -- Выводит пользователей у которых год рождения 1980 через LIKE

SELECT *,
    CASE WHEN YEAR(users.birthday) < '1980' THEN 'Меньше 1980'
         WHEN YEAR(users.birthday) BETWEEN '1980' AND '1982' THEN 'От 1980 до 1982'
         WHEN YEAR(users.birthday) > 1982 THEN 'Больше 1982'
    END AS year_period
    FROM users
    ORDER BY birthday;                      -- Выводит в какой диапазон выпадает год рождения через CASE

SELECT users.first_name, users.last_name, YEAR(curdate()) - YEAR(users.birthday) AS Возраст,
    CASE WHEN YEAR(curdate()) - YEAR(users.birthday) >= 40 THEN '40 или более лет'
         ELSE 'Менее 40 лет'
    END 'Есть ли 40 лет'
    FROM users
    ORDER BY users.birthday DESC ;          -- Сравнение дат через case








