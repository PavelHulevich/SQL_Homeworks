drop schema if exists final_exam_Hulevich;
create schema final_exam_Hulevich;
use final_exam_Hulevich;

drop table if exists jobs, employees, departments;

create table jobs
(
    id varchar(10) primary key,
    job_title varchar(45),
    min_salary decimal(6),
    max_salary decimal(6)
);

create table departments
(
    id int auto_increment primary key,
    department_name varchar(45),
    manager_id int
);

create table employees
(
    id int auto_increment primary key,
    first_name varchar(20),
    last_name varchar(25),
    hire_date date,
    job_id varchar(45),
    salary decimal(8, 2),
    department_id int,
    manager_id int,
    jobs_id varchar(10),
    foreign key (jobs_id) references jobs(id),
    foreign key (department_id) references departments(id)
);

insert jobs values
    ('AD_PRES',	'President',	20080,	40000),
    ('FI_ACCOUNT',	'Accountant',	4200,	9000),
    ('HR_REP',	'Human Resources Representative',	4000,	9000),
    ('IT_PROG',	'Programmer',	4000,	10000),
    ('MK_MAN',	'Marketing Manager',	9000,	15000);

insert departments values
    (60,	'IT',	103),
    (70,	'Public Relations',	204),
    (80,	'Sales',	145),
    (90,	'Executive',	100),
    (100,	'Finance',	108),
    (110,	'Accounting',	205);

insert employees (id, first_name, last_name, hire_date, job_id, salary, department_id, manager_id) values
    (100,	'Steven',	'King',	'2013-06-17',	'AD_PRES',	24000.00,	90,	null),
    (101,	'Neena',	'Yang',	'2015-09-21',	'AD_PRES',	17000.00,	90,	100 ),
    (102,	'Lex',	'Garcia',	'2011-01-13',	'AD_PRES',	17000.00,	90,	100) ,
    (103,	'Alexander',	'James',	'2016-01-03',	'IT_PROG',	9000.00,	60,	102 ),
    (104,	'Bruce',	'Miller',	'2017-05-21',	'IT_PROG',	6000.00,	60,	103) ,
    (105,	'David',	'Williams',	'2016-06-25',	'IT_PROG',	4800.00,	60,	103) ,
    (106,	'Valli',	'Jackson',	'2016-02-05',	'IT_PROG',	4800.00,	60,	103) ,
    (107, 'Diana',	'Nguyen',	'2017-02-07',	'IT_PROG',	4200.00,	60,	103) ,
    (108,	'Nancy',	'Gruenberg',	'2012-08-17',	'FI_ACCOUNT',	12008.00,	100,	null) ,
    (109,	'Daniel',	'Faviet',	'2012-08-16',	'FI_ACCOUNT',	9000.00,	100,	108) ,
    (110,	'John',	'Chen',	'2015-09-28',	'FI_ACCOUNT',	8200.00,	100,	108) ,
    (111,	'Ismael',	'Sciarra',	'2015-09-30',	'FI_ACCOUNT',	7700.00,	100,	108) ,
    (112,	'Jose Manuel',	'Urman',	'2016-03-07',	'FI_ACCOUNT',	7800.00,	100, 108 ),
    (113,	'Luis',	'Popp',	'2017-12-07',	'FI_ACCOUNT',	6900.00,	100, 108) ,
    (145,	'John',	'Singh',	'2014-10-01',	'MK_MAN',	14000,	80,	100) ,
    (200,	'Jennifer',	'Whalen',	'2013-09-17',	'AD_PRES',	4400,	110, 101) ,
    (201,	'Michael',	'Martinez',	'2014-02-17',	'MK_MAN',	13000,	110,	100) ,
    (202,	'Pat',	'Davis',	'2015-08-17',	'MK_MAN',	6000,	110,	201) ,
    (203,	'Susan',	'Jacobs',	'2012-06-07',	'HR_REP',	6500,	110,	101) ,
    (204,	'Hermann',	'Brown',	'2012-06-07',	'HR_REP',	10000,	80,	101) ,
    (205,	'Shelley',	'Higgins',	'2012-06-07',	'AD_PRES',	12008,	110,	101 ),
    (206,	'William',	'Gietz',	'2012-06-07',	'AD_PRES',	8300,	110,	205 );

-- 1.	Таблица Employees. Получить список всех сотрудников из 60го отдела (department_id) с зарплатой(salary), большей 4000
select *
    from employees
    where department_id = 60 and salary > 4000;

-- 2.	Таблица Employees. Получить список всех сотрудников, у которых в имени содержатся минимум 2 буквы 'n'
select *
    from employees
    where (first_name like '%n%n%') -- можно добавить or (last_name like '%n%n%') для учета фамилии.
--        (concat(first_name, last_name) like '%n%n%')   либо такой вариант. Где считаются n в имени и фамилии
                                    ;
-- 3.	Таблица Employees. Получить список всех ID менеджеров
select id
    from employees
    where manager_id is null;

-- 4.	Таблица Employees. Получить список работников с их позициями в формате: Donald(sh_clerk)
select  concat(first_name, '(', job_id, ')')
    from employees;

-- 5.	Таблица Departments. Получить первое слово из имени департамента для тех у кого в названии больше одного слова
select substring_index(department_name, ' ', 1)
    from departments
    where department_name like '% %';

-- 6.	Таблица Employees. Получить список всех сотрудников, которые работают в компании больше 10 лет
select *
    from employees
    where TIMESTAMPDIFF(year, hire_date, curdate()) > 10;

-- 7.	Таблица Employees. Получить список всех сотрудников, которые пришли на работу в августе 2012го года.
select *
    from employees
    where substring(hire_date, 1, 7) = '2012-08';

-- 8.	Таблица Employees. Сколько сотрудников имена которых начинается с одной и той же буквы? Сортировать по количеству. Показывать только те где количество больше 1
select left(first_name, 1) 'Первая буква имени', count(first_name) 'Сколько имен с такой первой буквой'
    from employees
    group by left(first_name, 1)
    having count(first_name) > 1
    order by count(first_name);

-- 9.	Таблица Employees. Сколько сотрудников которые работают в одном и тоже отделе и получают одинаковую зарплату?
select department_id 'Отдел', salary 'Зарплата', count(*) 'Сколько сотрудников'
    from employees
    group by department_id, salary
    having count(*) > 1;

-- 10.	Таблица Employees, Departaments. Получить список department_id, department_name и округленную среднюю зарплату работников в каждом департаменте.
select d.id, d.department_name, round(avg(e.salary)) 'Средняя зарплата по отделу'
    from departments d
    join employees e on d.id = e.department_id
    group by d.id, d.department_name;

-- 11.	Таблица Employees, Departaments. Показать все департаменты, в которых нет ни одного сотрудника
select d.id, d.department_name
    from departments as d
    left join employees e on d.id = e.department_id
    where e.department_id is null;

-- 12.	Таблица Employees, Jobs, Departaments. Показать сотрудников в формате: First_name, Job_title, Department_name.
select e.first_name, j.job_title, d.department_name
    from employees e
    join jobs j on e.job_id = j.id
    join departments d on d.id = e.department_id;

-- 13.	Таблица Employees. Показать всех менеджеров, которые имеют в подчинении больше 3х сотрудников
select e1.manager_id, e2.first_name, count(e1.manager_id) 'Сотрудников в подчинении'
    from employees e1
    join employees e2 on e1.manager_id = e2.id
    group by manager_id
    having count(*) > 3;

-- 14.	Таблица Employees. Получить список сотрудников, у которых менеджер получает зарплату больше 15000.
select e1.first_name 'Имя сотрудника', e1.last_name 'Фамилия сотрудника', e2.last_name 'Имя менеджера', e2.salary 'Зарплата менеджера'
    from employees e1
    join employees e2 on e1.manager_id = e2.id
    where e2.salary > 15000;

-- 15.	Таблица Employees. Получить список сотрудников с самым длинным именем.
select  first_name
    from employees
    where length(first_name) = (select max(length(first_name)) from employees);




