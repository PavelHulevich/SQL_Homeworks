create schema if not exists citys_users;
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
 alter table users add birthday date
		check (birthday >= '1900-01-01' and birthday < '2025-10-25');

select * from users;

 insert users(first_name, last_name, birthday)
	values  ('Иванов', 'Петр', '1980-05-06'),
			('Сидоров', 'Иван', '1982-01-11'),
			('Петров', 'Сидор', '1975-11-06'),
			('Ковалев', 'Вася', '1986-05-06'),
            ('Васин', 'Виталий', '1980-05-06'),
            ('Виталин', 'Додик', '1980-05-06'),
            ('Коржов', 'Бублик', '1980-05-06'),
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
    where city_name = 'Гадюкино'

