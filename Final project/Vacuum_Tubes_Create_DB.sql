DROP SCHEMA IF EXISTS Vacuum_Tubes;
CREATE SCHEMA Vacuum_Tubes;
USE Vacuum_Tubes;

create table production  -- запланированное производство однотипных пробирок от разных производителей
(
    production_id         int auto_increment PRIMARY KEY,
    production_tube_size ENUM('1375', '13100', '16100') NOT NULL,
    production_tube_type CHAR(3) NOT NULL ,
    production_tube_volume DECIMAL(4,1) NOT NULL
        CHECK (production_tube_volume >= 1 and production_tube_volume <= 10),
    production_status     ENUM ('В ожидании', 'В производстве') DEFAULT 'В ожидании',
    production_change_date datetime default null,
    production_quantity int default 0
);

create table Orders     --  заказы на пробирку
(
    order_Id INT auto_increment PRIMARY KEY,
    tube_size ENUM('1375', '13100', '16100') NOT NULL,    	  -- размер пробирки (13100, 1375, 16100)
    tube_type CHAR(3) NOT NULL ,       					  -- вид наполнителя в пробрке (ZK, 9NC, 4NC, K3E, K2E, ZKR)
    nc_percent ENUM('3,2', '3,8') DEFAULT NULL,				  -- концентрация наполнителя если это 9NC или 4NC (Null; 3,2; 3,8)
    tube_volume DECIMAL(4,1) NOT NULL
        CHECK (tube_volume >= 1 and tube_volume <= 10), 	  -- набираемый объем (1 - 10)
    quantity INT DEFAULT 0,										  -- размер заказа в штуках.
    order_status ENUM('В ожидании', 'В производстве') 		  -- статус заказа
        DEFAULT 'В ожидании',
    order_date DATE,										  -- дата подачи заказа
    dl_date DATE,										  -- последняя дата для выполнения заказа
    customer VARCHAR(50),                                 -- Наименование заказчика
    customer_city VARCHAR(20),			                  -- Город заказчика
    order_production int default null,                    -- Ссылка на партию однотипных пробирок для производства
    foreign key (order_production) references production(production_id)
);

INSERT ORDERS(tube_size, tube_type, nc_percent, tube_volume, quantity, order_date, dl_date, customer, customer_city)
	VALUES ('1375', 'ZKR', NULL, 3.0, 10000, '2025-10-25', '2025-11-20', '7-я поликлиника', 'Гомель'),
		    ('1375', 'K2E', NULL, 2.0, 30000, '2025-10-25', '2025-11-20', 'Ветклиника', 'Минск'),
           ('1375', 'ZKR', NULL, 3.0, 50000, '2025-10-28', '2025-11-28', '9-я поликлиника', 'Гродно'),
           ('1375', 'K2E', NULL, 2.0, 30000, '2025-10-25', '2025-11-20', 'Ветклиника', 'Минск'),
           ('13100', 'ZKR', NULL, 5.0, 100000, '2025-10-29', '2025-11-29', 'ОАО Айболит', 'Витебск'),
           ('13100', 'ZKR', NULL, 5.0, 40000, '2025-10-30', '2025-11-30', 'Медтехника', 'Могилев');

SELECT * FROM Orders


/*
Необходимо сумму всех orders.quantity для одинаковых orders.tube_size, order.tube_type, order.tube_volume записать
в таблицу production в поле production_quantity. При этом в ту же самую запись в production необходимо вписать размер
пробирки из orders.tube_size, тип пробирки из order.tube_type и объем пробирки из order.tube_volume.
 А в каждый orders.order_production вписать номер того production.production_id, в сумму которого вошел этот заказ

 */