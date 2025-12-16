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

create table customer_city    -- Города заказчиков
(
    customer_city_id             int auto_increment primary key,
    customer_city_name           varchar(20) -- наименование города заказчика
);

create table customer    -- Организации заказчиков
(
    customer_id             int auto_increment primary key,
    customer_name           varchar(50),     -- наименование организации заказчика
    customer_city           int default null,-- id города заказчика
    foreign key (customer_city) references customer_city(customer_city_id)
);

create table tube_size
(
    tube_size_id            int auto_increment primary key,
    tube_size_name          ENUM('1375', '13100', '16100') NOT NULL    -- размер пробирки (13100, 1375, 16100)
);

create table tube_type
(
    tube_type_id            int auto_increment primary key,
    tube_type_name          enum('ZK', 'ZKR', 'K2E', 'K3E', '9NC', '4NC') not null -- тип реагента в пробирке
);

create table production  -- запланированное производство однотипных пробирок от разных производителей
(
    production_id           int auto_increment PRIMARY KEY,
    production_tube_size    int NOT NULL,                               -- размер пробирки (13100, 1375, 16100)
    production_tube_type    int NOT NULL ,
    production_tube_volume  DECIMAL(2,1) NOT NULL
        CHECK (production_tube_volume >= 1 and production_tube_volume <= 10),
    production_status       ENUM ('В ожидании', 'В производстве') DEFAULT 'В ожидании',
    production_change_date  datetime default null,
    production_quantity     int default 0,
    foreign key (production_tube_size) references tube_size(tube_size_id),
    foreign key (production_tube_type) references tube_type(tube_type_id)

);

create table Orders     --  заказы на пробирку от определенных покупателей
(
    order_Id        INT auto_increment PRIMARY KEY,             -- id заказа на производство пробирки
    tube_size       int NOT NULL,                               -- размер пробирки (13100, 1375, 16100)
    tube_type       int NOT NULL,       					-- вид наполнителя в пробрке (ZK, 9NC, 4NC, K3E, K2E, ZKR)
    nc_percent      ENUM('3,2', '3,8') DEFAULT NULL,		    -- концентрация наполнителя если это 9NC или 4NC (Null; 3,2; 3,8)
    tube_volume     DECIMAL(2,1) NOT NULL
        CHECK (tube_volume >= 1 and tube_volume <= 10), 	    -- набираемый объем крови в мл. (1 - 10)
    quantity        INT DEFAULT 0,								-- размер заказа в штуках.
    order_status    ENUM('В ожидании', 'В производстве') 		-- статус заказа
        DEFAULT 'В ожидании',
    order_date      DATE,										-- дата подачи заказа
    dl_date         DATE,										-- последняя дата для выполнения заказа
    order_production        int default null,                   -- id партии однотипных пробирок для производства
    foreign key (order_production) references production(production_id),
    foreign key (tube_size) references tube_size(tube_size_id),
    foreign key (tube_type) references tube_type(tube_type_id)
);
create table order_customer
(
    order_customer_order int not null,
    order_customer_customer int not null,
    primary key (order_customer_order, order_customer_customer),
    foreign key (order_customer_order) references orders(order_id),
    foreign key (order_customer_customer) references customer(customer_id)
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

INSERT customer(customer_name, customer_city)
    values ('Медтехника', 1), ('Медтехника', 2), ('Санстанция', 1),

           ('Горбольница №1', 3), ('Ветклиника', 4), ('Областная больница', 2);

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
           (3, 2),
           (4, 3),
           (5, 2),
           (6, 3);

SELECT * FROM Orders o
    join tube_size ts on o.tube_size = ts.tube_size_id


/*
Необходимо сумму всех orders.quantity для одинаковых orders.tube_size, order.tube_type, order.tube_volume записать
в таблицу production в поле production_quantity. При этом в ту же самую запись в production необходимо вписать размер
пробирки из orders.tube_size, тип пробирки из order.tube_type и объем пробирки из order.tube_volume.
 А в каждый orders.order_production вписать номер того production.production_id, в сумму которого вошел этот заказ.
После того как заказ добавлен в производство, статус заказа order_status из "В ожидании" меняется на "В производстве"

 */