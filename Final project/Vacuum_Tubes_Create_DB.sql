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

# create table tube_size
# (
#     tube_size_id            int auto_increment primary key,
#     tube_size_name          ENUM('1375', '13100', '16100') NOT NULL    -- размер пробирки (13100, 1375, 16100)
# );

create table production  -- запланированное производство однотипных пробирок от разных производителей
(
    production_id           int auto_increment PRIMARY KEY,
    production_tube_size    ENUM('1375', '13100', '16100') NOT NULL,
    production_tube_type    CHAR(3) NOT NULL ,
    production_tube_volume  DECIMAL(4,1) NOT NULL
        CHECK (production.production_tube_volume >= 1 and production.production_tube_volume <= 10),
    production_status       ENUM ('В ожидании', 'В производстве') DEFAULT 'В ожидании',
    production_change_date  datetime default null,
    production_quantity     int default 0
);

create table Orders     --  заказы на пробирку от определенных покупателей
(
    order_Id        INT auto_increment PRIMARY KEY,             -- id заказа на производство пробирки
    tube_size       ENUM('1375', '13100', '16100') NOT NULL,    -- размер пробирки (13100, 1375, 16100)
    tube_type       CHAR(3) NOT NULL,       					-- вид наполнителя в пробрке (ZK, 9NC, 4NC, K3E, K2E, ZKR)
    nc_percent      ENUM('3,2', '3,8') DEFAULT NULL,		    -- концентрация наполнителя если это 9NC или 4NC (Null; 3,2; 3,8)
    tube_volume     DECIMAL(4,1) NOT NULL
        CHECK (Orders.tube_volume >= 1 and Orders.tube_volume <= 10), 	    -- набираемый объем крови в мл. (1 - 10)
    quantity        INT DEFAULT 0,								-- размер заказа в штуках.
    order_status    ENUM('В ожидании', 'В производстве') 		-- статус заказа
        DEFAULT 'В ожидании',
    order_date      DATE,										-- дата подачи заказа
    dl_date         DATE,										-- последняя дата для выполнения заказа
    order_production        int default null,                   -- id партии однотипных пробирок для производства
    foreign key (order_production) references production(production_id)
);
create table order_customer
(
    order_customer_order int not null,
    order_customer_customer int not null,
    primary key (order_customer_order, order_customer_customer),
    foreign key (order_customer_order) references orders(order_id),
    foreign key (order_customer_customer) references customer(customer_id)
);

insert customer_city(customer_city.customer_city_name)
    values ('Минск'), ('Витебск'), ('Гомель'),
           ('Брест'), ('Гродно'), ('Могилев');

INSERT customer(customer.customer_name, customer.customer_city)
    values ('Медтехника', 1), ('Медтехника', 2), ('Санстанция', 1),

           ('Горбольница №1', 3), ('Ветклиника', 4), ('Областная больница', 2);

INSERT ORDERS(Orders.tube_size, Orders.tube_type, Orders.nc_percent, Orders.tube_volume, Orders.quantity, Orders.order_date, Orders.dl_date)
	VALUES ('1375', 'ZKR', NULL, 3.0, 10000, '2025-10-25', '2025-11-20'),
		    ('1375', 'K2E', NULL, 2.0, 30000, '2025-10-25', '2025-11-20'),
           ('1375', 'ZKR', NULL, 3.0, 50000, '2025-10-28', '2025-11-28'),

           ('1375', 'K2E', NULL, 2.0, 30000, '2025-10-25', '2025-11-20'),
           ('13100', 'ZKR', NULL, 5.0, 100000, '2025-10-29', '2025-11-29'),
           ('13100', 'ZKR', NULL, 5.0, 40000, '2025-10-30', '2025-11-30');

insert order_customer
    values (1, 2),
           (2, 3),
           (3, 2),
           (4, 3),
           (5, 2),
           (6, 3);

SELECT * FROM Orders


/*
Необходимо сумму всех orders.quantity для одинаковых orders.tube_size, order.tube_type, order.tube_volume записать
в таблицу production в поле production_quantity. При этом в ту же самую запись в production необходимо вписать размер
пробирки из orders.tube_size, тип пробирки из order.tube_type и объем пробирки из order.tube_volume.
 А в каждый orders.order_production вписать номер того production.production_id, в сумму которого вошел этот заказ

 */