DROP SCHEMA IF EXISTS title_position;
CREATE SCHEMA title_position;
USE title_position;

DROP TABLE IF EXISTS
    gender, person, title, position_, address, email, phone, person_title, person_position;

CREATE TABLE gender
(
    id_gender int auto_increment primary key,
    gender_name varchar(20) unique
);

CREATE TABLE person
(
    id_person int auto_increment primary key,
    first_name varchar(20) not null,
    last_name varchar(40) not null,
    person_gender int,
    FOREIGN KEY (person_gender) REFERENCES gender(id_gender)
);

CREATE TABLE title
(
    id_title int auto_increment primary key,
    title_name varchar(20) unique
);

CREATE TABLE position_
(
    id_position_ int auto_increment primary key,
    position_name varchar(20) unique
);

CREATE TABLE address
(
    id_address int auto_increment primary key,
    street varchar(40) not null,
    postal_code char(6),
    city varchar(40),
    address_person int,
    FOREIGN KEY (address_person) REFERENCES person(id_person)
);

CREATE TABLE email
(
    id_email int auto_increment primary key,
    email varchar(100),
    email_person int,
    FOREIGN KEY (email_person) REFERENCES person(id_person)
);

CREATE TABLE phone
(
    id_phone int auto_increment primary key,
    phone char(13),
    phone_person int,
    FOREIGN KEY (phone_person) REFERENCES person(id_person)
);

CREATE TABLE person_title
(
    id_person_title int auto_increment primary key,
    person_title_person int,
    person_title_title int,
    FOREIGN KEY (person_title_person) REFERENCES person(id_person),
    FOREIGN KEY (person_title_title) REFERENCES title(id_title)
);

CREATE TABLE person_position
(
    id_person_position int auto_increment primary key,
    person_position_person int,
    person_position_position int,
    FOREIGN KEY (person_position_person) REFERENCES person(id_person),
    FOREIGN KEY (person_position_position) REFERENCES position_(id_position_)
);

INSERT gender(gender_name)
    VALUES ('Мужчина'), ('Женщина');

INSERT person(first_name, last_name, person_gender)
    VALUES
                         ('Esta','Schmeler',1),
                         ('Yesenia','Lemke',1),
                         ('Ruthe','Kerluke',1),
                         ('Amelie','Aufderhar',2),
                         ('Dahlia','Bechtelar',2),
                         ('Amely','Stiedemann',2),
                         ('Alanis','Ullrich',1),
                         ('Jennie','Sipes',2),
                         ('Vernon','Hoppe',2),
                         ('Hanna','Stamm',2);

INSERT address (`street`, `postal_code`, `city`, `address_person`)
    VALUES
         ('Suite 883', '20068', 'Britneytown', 9),
         ('Apt. 207', '99446', 'East Amosview', 4),
         ('Suite 584', '43659', 'Rodriguezland', 7),
         ('Apt. 999', '54235', 'Mohrmouth', 6),
         ('Suite 953', '33413', 'South Alvina', 5),
         ('Suite 977', '61322', 'Prohaskahaven', 8),
         ('Suite 997', '18772', 'New Paula', 10),
         ('Suite 518', '58309', 'Wolfchester', 3),
         ('Suite 359', '54359', 'Loweland', 2),
         ('Apt. 102', '05207', 'Larkinbury', 1);

INSERT email (email, email_person)
    VALUES
        ('bogisich.amina@example.com',8),
        ('carolanne45@example.org',9),
        ('vandervort.major@example.net',10),
        ('nprice@example.org',2),
        ('hilario94@example.org',7),
        ('howell.maddison@example.net',1),
        ('isom82@example.org',3),
        ('runolfsdottir.kristopher@example.net',4),
        ('quincy52@example.net',6),
        ('prosacco.sheila@example.com',5);

INSERT INTO phone (phone, phone_person)
    VALUES
                        ('969.140.1119x',7),
                        ('1-622-521-652',3),
                        ('683-212-8339x',6),
                        ('1-383-938-360',1),
                        ('800.115.1128x',5),
                        ('1-884-315-662',9),
                        ('1-850-780-000',2),
                        ('+75(9)3622940',8),
                        ('09377838954',4),
                        ('1-577-710-252',10);

INSERT position_ (position_name)
    VALUES
        ('начальник'),
        ('директор'),
        ('уборщик'),
        ('приемщик'),
        ('инженер'),
        ('грузчик'),
        ('космонавт'),
        ('пастух'),
        ('программист'),
        ('токарь');

INSERT title(title_name)
    VALUES
        ('доцент'),
        ('профессор'),
        ('ученик'),
        ('господин'),
        ('гражданин'),
        ('его величество'),
        ('его высочество'),
        ('младший'),
        ('старший'),
        ('высший');

INSERT person_title(person_title_person, person_title_title)
    VALUES
        (1, 2),
        (2, 4),
        (3, 6),
        (4, 8),
        (5, 4),
        (6, 2),
        (7, 7),
        (8, 4),
        (9, 2),
        (10, 5);

INSERT person_position(person_position_person, person_position_position)
VALUES
    (1, 2),
    (2, 4),
    (3, 6),
    (4, 8),
    (5, 4),
    (6, 2),
    (7, 7),
    (8, 4),
    (9, 2),
    (10, 5);

SELECT title.title_name AS TITLE, person.first_name AS FIRST_NAME, person.last_name AS LAST_NAME, gender.gender_name AS GENDER,
       position_.position_name AS POSITION, phone.phone AS PHONE, email.email AS EMAIL,
       CONCAT_WS(' ', address.postal_code, address.street, address.city) AS ADDRESS

    FROM person
        INNER JOIN phone
            ON person.id_person = phone.phone_person
        INNER JOIN email
            ON person.id_person = email.email_person
        INNER JOIN gender
            ON person.person_gender = gender.id_gender
        INNER JOIN address
            ON person.id_person = address.address_person
        INNER JOIN person_title
            ON person.id_person = person_title.person_title_person
        INNER JOIN title
            ON person_title.person_title_title = title.id_title
        INNER JOIN person_position
            ON person.id_person = person_position.person_position_person
        INNER JOIN position_
            ON person_position.person_position_position = position_.id_position_





