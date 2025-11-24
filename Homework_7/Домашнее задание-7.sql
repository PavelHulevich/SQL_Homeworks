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

alter table citys add city_population int;
alter table citys add city_district int;

insert citys (city_name,citys.city_population, citys.city_district)
values ('Рига', 545862, 7), ('Осло', 471256, 5), ('Мозырь', 95462, 4),
       ('Гадюкино', 1845, 1), ('Брест', 325426, 4),
       ('Ми-ми-минск', 2458632, 7), ('Мур-мур-мурманск',589632, 5 );


# check (birthday >= '1900-01-01' and birthday <= curdate());
# При сравнении с текущей датой появляется ошибка
# [HY000][3814] An expression of a check constraint 'users_chk_1' contains disallowed function: curdate.

# select * from users;

 alter table users add birthday date default '1900-01-01'                -- добавлен default
		check (birthday >= '1900-01-01' and birthday < sysdate());
insert users(first_name, last_name, birthday, user_city)
	values  ('Иванов', 'Петр', '1980-05-06',1),
			('Сидоров', 'Иван', '1982-01-11',3),
			('Петров', 'Сидор', '1975-11-06',3),
			('Ковалев', 'Вася', '1986-05-06',3),
            ('Васин', 'Виталий', '1980-05-06',1),
            ('Виталин', 'Вася', '1980-05-06',1),
            ('Коржов', 'Иван', '1979-05-06',1),
            ('Кефиров', 'Коржик', '1980-05-06',NULL),
            ('Белый', 'Петр', '1987-05-06',NULL),
            ('Желтый', '', '1985-05-06',4),
            ('Зеленый', null, '1989-05-06',4),
            (null, 'Джек', '1988-05-06',4),
            ('Черный', 'Петр', '1987-05-06',1),
            ('Лысый', 'Иван', '1980-01-06',1),
            (null, 'Иван', '1980-09-06',5);

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

SELECT *
    FROM users
    WHERE last_name = '' OR last_name IS NULL; -- пользователи с пустым именем или null (не указано имя)

SELECT last_name, COUNT(last_name) AS 'Сколько таких имен'
    FROM users
    WHERE year(users.birthday) >= '1980' AND
        CASE  WHEN last_name LIKE 'В%' THEN 1
              WHEN last_name LIKE 'И%' THEN 1
              ELSE 0
        END
    GROUP BY last_name;    -- Выводит только имена начинающиеся на В и И с годом рождения от 1980 включительно

# ________________________ДОМАШНЯЯ РАБОТА №5 ___________________________

SELECT *                                        -- Внутреннее соединение (INNER JOIN)
    FROM users AS u                             -- Выбираются только те строки из первой и второй таблиц
        INNER JOIN  citys AS c                  -- в которых есть совпадающие поля (ключи)
        ON u.user_city = c.city_id;

SELECT *                                        -- Левое внешнее соединение (LEFT OUTER JOIN)
    FROM users AS u                             -- Выбираются все строки из левой таблицы и строки из правой таблицы
        LEFT JOIN citys AS c                    -- на которые указывает ключ из левой таблицы
            ON u.user_city = c.city_id;

SELECT *                                        -- Правое внешнее соединение (RIGHT OUTER JOIN)
    FROM users AS u                             -- Выбираются все строки из правой таблицы и строки из левой таблицы
        RIGHT JOIN citys AS c                   -- которые указывают на ключ из выбранной строки правой таблицы
            ON u.user_city = c.city_id;

SELECT *                                        -- Полное внешнее соединение (FULL OUTER JOIN)
    FROM users AS u                             -- в MySQL реализуется только объединением левого и правого соединений
        LEFT JOIN citys AS c
            ON u.user_city = c.city_id
UNION
SELECT *
    FROM users AS u
        RIGHT JOIN citys AS c
            ON u.user_city = c.city_id;

SELECT *                                        -- Перекрёстное соединение (CROSS JOIN)
    FROM users AS u                             -- каждой строке первой таблицы подставляется каждая из строк второй таблицы
        CROSS JOIN citys AS c;

SELECT users.first_name, users.last_name,       --  Соединение двух таблиц при без использования JOIN, при помощи WHERE
       citys.city_name                          -- выводятся имена пользователей и их города.
    FROM users,
         citys
    WHERE user_city = city_id;

SELECT citys.city_name, COUNT(city_name) AS 'Сколько из этого города'
    FROM users, citys                   --  Соединение двух таблиц без использования JOIN, при помощи WHERE
    WHERE user_city = city_id           -- выводятся названия городов и количество пользователей из этого города,
    GROUP BY city_name                  -- при условии, если в этом городе более одного пользователя.
    HAVING COUNT(city_name) > 1         -- с сортировкой по названию города.
    ORDER BY city_name;

SELECT citys.city_name 'Название города', COUNT(citys.city_name) AS 'Пользователей в этом городе родившихся начиная с 1981'
    FROM users                                       -- Соединение двух таблиц с использованием JOIN.
        INNER JOIN citys                             -- выводятся названия городов и количество пользователей из этого города,
        ON users.user_city = citys.city_id   -- после чего выбираются пользователи рожденные начиная с 1981 года
    WHERE YEAR(users.birthday) > 1980
    GROUP BY city_name
    ORDER BY city_name;

SELECT *                                    -- Выводит все строки из таблицы пользователей для которых нет ключа
    FROM users                              -- указывающего на город.
    WHERE user_city IS NULL;

SELECT LENGTH(CONCAT('Ton', ' ', 'Smith')), CONCAT('Ton', ' ', 'Smith');

SELECT TRIM(' Tom Smith   ');

# ________________________ДОМАШНЯЯ РАБОТА №7 ___________________________

-- Выводит названия городов с припиской "г. "
SELECT CONCAT_WS(' ', 'г.', citys.city_name) AS 'Название города'
    FROM citys;

-- Выводит названия городов в верхнем регистре
SELECT
    UPPER(citys.city_name)
    FROM citys;

-- Выводит название города, длину названия в байтах и длину названия в символах
SELECT citys.city_name AS 'Название города', LENGTH(city_name) AS 'Длина названия в байтах',
       CHAR_LENGTH(city_name) AS 'Длина названия в символах'
    FROM citys;

-- Выводит названия городов и позицию первого вхождения символа "-"
SELECT city_name AS 'Название города',LOCATE('-', citys.city_name) AS 'Позиция первого тире'
    FROM citys;

-- Меняет название городов в которых были уменьшительные приставки
SELECT citys.city_name AS 'Название было',
       CONCAT
              (UPPER                                         -- 3. переводим ее в верхний регистр.
              (LEFT                                          -- 2. берем первый символ от оставшейся строки
              (SUBSTRING_INDEX(citys.city_name, '-', -1)     -- 1. вырезаем все что справа от последнего дефиса
              ,1)),
              SUBSTRING(SUBSTRING_INDEX(citys.city_name, '-', -1),2)) -- 4. соединяем полученную строку с остатком названия
       AS 'Без уменьшительных приставок'
    FROM citys;

-- Выводит название города и среднее население одного района в городе с округлением до целого человека
SELECT citys.city_name AS 'Город',
       FLOOR(city_population / citys.city_district) AS 'Среднее население одного района'
    FROM citys;

-- Выводит среднее население одного района всех городов с округлением до целого человека
SELECT FLOOR(AVG(city_population / citys.city_district)) AS 'Среднее население одного района всех городов'
    FROM citys;

-- Выводит суммарное население всех городов
SELECT SUM(citys.city_population) 'Суммарное население всех городов'
    FROM citys;

-- Выводит среднее население всех городов округленное до целого человека
SELECT FLOOR(AVG(citys.city_population)) AS 'Среднее население всех городов округленное до целого человека'
    FROM citys;

-- Выводит среднее население всех городов начинающихся на "М", округленное до целого человека
SELECT FLOOR(AVG(citys.city_population)) AS 'Среднее население всех городов начинающихся на "М", округленное до целого человека'
    FROM citys
    WHERE LEFT(city_name,1) = 'М';

-- Выводит на экран текущую дату и время
SELECT CURDATE() 'Текущая дата', CURTIME() 'Текущее время';

-- Номер дня с начала года способ с сечением строк
SELECT DATEDIFF(CURDATE(),
        CONCAT(
        LEFT(CURDATE(), 4),
        '-01-01'))+1
        AS 'Номер дня в этом году';

-- Номер дня с начала года способ с функцией YEAR
SELECT DATEDIFF(CURDATE(),
        CONCAT(
        YEAR(CURDATE()),
        '-01-01'))+1
        AS 'Номер дня в этом году'









