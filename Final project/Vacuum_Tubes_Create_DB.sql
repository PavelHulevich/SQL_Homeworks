/*
БД заказов на производство вакуумных пробирок для забора крови.
Каждая пробирка имеет следующие параметры:
Размер. Возможные варианты: 1375, 13100, 16100
Тип наполнителя (регент) закодированный символами: ZK, ZKR, K2E, K3E, 9NC, 4NC
Объем забираемой крови (вакуум): значения от 1 мл до 10 мл с шагом 0,1 мл.
Заказа от определенных покупателей заносятся в таблицу  Orders
После чего с помощью скрипта однотипные по параметрам пробирки объединяются в партии заполняя таблицу Production

*/
DROP SCHEMA IF EXISTS Vacuum_Tubes;
CREATE SCHEMA Vacuum_Tubes;
USE Vacuum_Tubes;

create table customer_city   -- Названия городов заказчиков. Один ко многим с таблицей customer
(
    customer_city_id        int auto_increment primary key,
    customer_city_name      varchar(20) -- наименование города заказчика
);

create table customer_name   -- Названия организаций заказчиков. Один ко многим с таблицей customer
(
    customer_name_id        int auto_increment primary key,
    customer_name_name      varchar(50)     -- наименование организации заказчика
);

create table customer       -- Таблица связей наименований заказчиков и их городов.
(                           -- Многие к одному с таблицами customer_city и customer_name
    id int auto_increment primary key,
    city int not null,      -- Ссылается на customer_city_id в customer_city
    name int not null,      -- Ссылается на customer_name_id в customer_name
    foreign key (city) references customer_city(customer_city_id),
    foreign key (name) references customer_name(customer_name_id)
);

create table tube_size  -- Размер пробирки. Один ко многим с production_tube_size в таблице production
(                        -- и с tube_size в таблице orders
    tube_size_id            int auto_increment primary key,
    tube_size_name          ENUM('1375', '13100', '16100') NOT NULL    -- размер пробирки (13100, 1375, 16100)
);

create table tube_type  -- Тип наполнителя в пробирке (реагент). Один ко многим с production_tube_type в таблице production
(                        -- и с tube_type в таблице orders
    tube_type_id            int auto_increment primary key,
    tube_type_name          enum('ZK', 'ZKR', 'K2E', 'K3E', '9NC', '4NC') not null -- тип реагента в пробирке
);

create table production  -- запланированное производство однотипных пробирок от разных производителей
(
    production_id           int auto_increment PRIMARY KEY,
    production_tube_size    int NOT NULL, -- размер пробирки. Многие к одному с tube_size_id в tube_size
    production_tube_type    int NOT NULL, -- тип пробирки. Многие к одному с tube_type_id в tube_type
    production_tube_volume  DECIMAL(3,1) NOT NULL -- Объем забираемой крови
        CHECK (production_tube_volume >= 1 and production_tube_volume <= 10),
    production_status       ENUM ('В ожидании', 'В производстве') DEFAULT 'В ожидании',
    production_change_date  datetime default null, -- Дата и время добавления или последнего изменения плана производства.
    production_quantity     int default 0, -- Запланированное количество для производства данного типа пробирки.
    foreign key (production_tube_size) references tube_size(tube_size_id),
    foreign key (production_tube_type) references tube_type(tube_type_id)

);

create table Orders     --  заказы на пробирку от определенных покупателей
(
    order_Id        INT auto_increment PRIMARY KEY,             -- id заказа на производство пробирки
    tube_size       int NOT NULL,                               -- размер пробирки (13100, 1375, 16100)
    tube_type       int NOT NULL,       					    -- вид наполнителя в пробрке (ZK, 9NC, 4NC, K3E, K2E, ZKR)
    nc_percent      ENUM('3,2', '3,8') DEFAULT NULL,		    -- концентрация наполнителя если это 9NC или 4NC (Null; 3,2; 3,8)
    tube_volume     DECIMAL(3,1) NOT NULL                       -- набираемый объем крови в мл. (1 - 10)
        CHECK (tube_volume >= 1 and tube_volume <= 10),
    quantity        INT DEFAULT 0,								-- размер заказа в штуках.
    order_status    ENUM('В ожидании', 'В производстве') 		-- статус заказа
        DEFAULT 'В ожидании',
    order_date      DATE,										-- дата подачи заказа
    dl_date         DATE,										-- последняя дата для выполнения заказа
    order_production        int default null,                   -- id партии однотипных пробирок для производства
                                                                -- указывается скриптом после внесения заказа в план производства.
    foreign key (order_production) references production(production_id),
    foreign key (tube_size) references tube_size(tube_size_id),
    foreign key (tube_type) references tube_type(tube_type_id)
);
create table order_customer                                     -- таблица связей заказов с заказчиками
(
    order_customer_order int not null,
    order_customer_customer int not null,
    foreign key (order_customer_order) references orders(order_id),
    foreign key (order_customer_customer) references customer(id)
);
-- Заполняем возможные размеры пробирки
insert tube_size(tube_size_name)
    values ('1375'), ('13100'), ('16100');

insert tube_type(tube_type_name)
    values  ('ZK'), ('ZKR'), ('K2E'),
            ('K3E'), ('9NC'), ('4NC');

insert customer_city(customer_city_name)
    values ('Минск'), ('Витебск'), ('Гомель'),
           ('Брест'), ('Гродно'), ('Могилев');

INSERT customer_name(customer_name_name)
    values ('Медтехника'), ('ЦРБ'), ('Санстанция'),
           ('Горбольница №1'), ('Ветклиника'), ('Областная больница');

insert customer(name, city)
    values (1, 1), (1, 2), (4, 3), (6, 3);

INSERT ORDERS(tube_size, tube_type, nc_percent, tube_volume, quantity, order_date, dl_date)
	VALUES (1, 2, NULL, 3.0, 10000, '2025-10-25', '2025-11-20'),
		    (1, 3, NULL, 2.0, 30000, '2025-10-25', '2025-11-20'),
           (1, 2, NULL, 3.0, 50000, '2025-10-28', '2025-11-28'),

           (1, 3, NULL, 2.0, 30000, '2025-10-25', '2025-11-20'),
           (2, 2, NULL, 5.0, 100000, '2025-10-29', '2025-11-29'),
           (2, 2, NULL, 5.0, 40000, '2025-10-30', '2025-11-30');

insert order_customer
    values (1, 2),
           (2, 3),
           (3, 1),
           (4, 3),
           (5, 2),
           (6, 4);

create or replace view Order_customer_list as    -- показывает все заказы
    select concat(ts.tube_size_name, '/', tt.tube_type_name, '-', o.tube_volume) as "Наименование пробирки",
           concat(o.quantity, 'шт.') as "Количество",
           order_date 'Дата заказа',  concat(cn.customer_name_name, '. ', cc.customer_city_name) as "Заказчик"
        from order_customer oc
        join customer c on oc.order_customer_customer = c.id
        join customer_city cc on c.city = cc.customer_city_id
        join customer_name cn on c.name = cn.customer_name_id
        join orders o on oc.order_customer_order = o.order_Id
        join tube_size ts on o.tube_size = ts.tube_size_id
        join tube_type tt on o.tube_type = tt.tube_type_id;

select * from Order_customer_list;

select * from Order_customer_list  -- Показывает все заказы для пробирки 1375/ZKR-3.0
    where `Наименование пробирки` = '1375/ZKR-3.0';

select * from Order_customer_list  -- Показывает все заказы сделанные Медтехникой Витебска
    where `Заказчик` = 'Медтехника. Витебск';





/*
Необходимо сумму всех orders.quantity для одинаковых orders.tube_size, order.tube_type, order.tube_volume записать
в таблицу production в поле production_quantity. При этом в ту же самую запись в production необходимо вписать размер
пробирки из orders.tube_size, тип пробирки из order.tube_type и объем пробирки из order.tube_volume.
 А в каждый orders.order_production вписать номер того production.production_id, в сумму которого вошел этот заказ.
После того как заказ добавлен в производство, статус заказа order_status из "В ожидании" меняется на "В производстве"

 */