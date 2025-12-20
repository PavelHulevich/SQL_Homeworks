/*
БД заказов на производство вакуумных пробирок для забора крови.
Каждая пробирка имеет следующие параметры:
Размер. Возможные варианты: 1375, 13100, 16100
Тип наполнителя (регент) закодированный символами: ZK, ZKR, K2E, K3E, 9NC, 4NC
Объем забираемой крови (вакуум): значения от 1 мл до 10 мл с шагом 0,1 мл.
Заказа от определенных покупателей заносятся в таблицу  Orders
После чего с помощью скрипта однотипные по параметрам пробирки объединяются в партии заполняя таблицу Production
*/

drop schema if exists final_project_hulevich_vacuum_tubes;
create schema final_project_hulevich_vacuum_tubes;
use final_project_hulevich_vacuum_tubes;

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

-- Триггер Before Insert для таблицы c городами. Гарантированно делает первую букву названия прописной, остальные строчные
delimiter //
create trigger before_insert_customer_city
    before insert on customer_city
    for each row                                        -- для каждой строки вводимой в citys
begin
    if NEW.customer_city_name is not null and length(NEW.customer_city_name) > 0 then  -- если вводимое название не нулевое и не null
        set NEW.customer_city_name = concat(                 -- то из вводимого имени формируем имя нужного вида.
                UPPER(LEFT(NEW.customer_city_name, 1)),      -- Первую букву делаем прописной.
                LOWER(substring(NEW.customer_city_name, 2))  -- Остальные начиная со второй делаем строчными
                            );
    end if;
end;
delimiter ;

-- Заполняем возможные размеры пробирки
insert tube_size(tube_size_name)
    values ('1375'), ('13100'), ('16100');

insert tube_type(tube_type_name)
    values  ('ZK'), ('ZKR'), ('K2E'),
            ('K3E'), ('9NC'), ('4NC');

insert customer_city(customer_city_name)
    values ('Минск'), ('Витебск'), ('Гомель'),
           ('Брест'), ('Гродно'), ('мОгилев');

INSERT customer_name(customer_name_name)
    values ('Медтехника'), ('ЦРБ'), ('Санстанция'),
           ('Горбольница №1'), ('Ветклиника'), ('Областная больница');

insert customer(name, city)
    values (1, 1), (1, 2), (4, 3), (6, 3),
           (5, 6), (2, 5), (2, 3), (3, 3);

INSERT ORDERS(tube_size, tube_type, nc_percent, tube_volume, quantity, order_date, dl_date)
	VALUES (1, 2, NULL, 3.0, 10000, '2025-10-25', '2025-11-20'),
		    (1, 3, NULL, 2.0, 30000, '2025-10-25', '2025-11-20'),
           (1, 2, NULL, 3.0, 50000, '2025-10-28', '2025-11-28'),
           (1, 3, NULL, 2.0, 30000, '2025-10-25', '2025-11-20'),
           (2, 2, NULL, 5.0, 100000, '2025-10-29', '2025-11-29'),
           (2, 2, NULL, 5.0, 40000, '2025-10-30', '2025-11-30'),

           (2, 4, NULL, 4.0, 150000, '2025-10-25', '2025-11-20'),
           (3, 1, NULL, 8.0, 300000, '2025-10-25', '2025-11-20'),
           (1, 2, NULL, 3.0, 25000, '2025-10-28', '2025-11-28'),
           (3, 5, NULL, 8.0, 30000, '2025-10-25', '2025-11-20'),
           (2, 4, NULL, 6.0, 120000, '2025-10-29', '2025-11-29'),
           (1, 1, NULL, 1.0, 12000, '2025-10-30', '2025-11-30');

# INSERT ORDERS(tube_size, tube_type, nc_percent, tube_volume, quantity, order_date, dl_date)
# VALUES (1, 2, NULL, 3.0, 10000, '2025-10-25', '2025-11-20');

insert order_customer
    values (1, 2),
           (2, 3),
           (3, 1),
           (4, 3),
           (5, 2),
           (6, 4),
           (7, 5),
           (8, 5),
           (9, 6),
           (10, 7),
           (11, 8),
           (12, 7);

/*
Необходимо сумму всех orders.quantity для одинаковых orders.tube_size, order.tube_type, order.tube_volume записать
в таблицу production в поле production_quantity. При этом в ту же самую запись в production необходимо вписать размер
пробирки из orders.tube_size, тип пробирки из order.tube_type и объем пробирки из order.tube_volume.
 А в каждый orders.order_production вписать номер того production.production_id, в сумму которого вошел этот заказ.
После того как заказ добавлен в производство, статус заказа order_status из "В ожидании" меняется на "В производстве"

Если определенный тип пробирки из заказов (в таблице orders) уже есть в плане производства (в таблице production),
и в таблице заказов появились новые заказы с таким же типом пробирки,
То обновляем существующие записи в плане производства production, прибавив к ним количество из заказов с
пробирки такого же вида,
*/
START TRANSACTION;
UPDATE production p
    JOIN (
        SELECT
            o.tube_size,
            o.tube_type,
            o.tube_volume,
            SUM(o.quantity) AS total_quantity
        FROM Orders o
        WHERE o.order_production IS NULL -- берем только пробирки (из таблицы заказов) которые еще не внесены в производство (в таблицу production).
        GROUP BY o.tube_size, o.tube_type, o.tube_volume
    ) new_orders                         -- обозначаем их как временную таблицу
    ON p.production_tube_size = new_orders.tube_size        -- находим такие же пробирки уже добавленные в план производства (в таблицу production)
        AND p.production_tube_type = new_orders.tube_type       --
        AND p.production_tube_volume = new_orders.tube_volume   --
SET p.production_quantity = p.production_quantity + new_orders.total_quantity, -- если такие найдутся то увеличиваем количество в производстве на величину нового заказа
    p.production_change_date = NOW()       -- меняем дату последнего изменения плана производства этого типа пробирки на текущую
where p.production_status = 'В ожидании';

-- Обновить заказы, чтобы они ссылались на уже существующую запись в production
UPDATE Orders o
    JOIN production p
    ON o.tube_size = p.production_tube_size
        AND o.tube_type = p.production_tube_type
        AND o.tube_volume = p.production_tube_volume
SET o.order_production = p.production_id,
    o.order_status = 'В производстве'   -- меняем статус пробирки из 'В ожидании' на 'В производстве'
WHERE o.order_production IS NULL; -- берем только пробирки (из таблицы заказов) которые еще не внесены в производство (в таблицу production).

-- Все пробирки уже существующие в производстве добавлены уже увеличены на количество указанное в новых заказах.
-- Теперь добавляем новую пробирку в план производства, в котором еще не было такой пробирки. Создаем новую строку производства.
-- Общее количество увеличиваем на 200 шт. Это необходимое для арбитражного хранения изделий.
insert production(production_tube_size, production_tube_type, production_tube_volume, production_quantity, production_change_date)
select tube_size, tube_type, tube_volume, sum(quantity) + 200, NOW()
from Orders
where order_status = 'В ожидании'
group by tube_size, tube_type, tube_volume;

-- Связываем заказы с соответствующими production_id
UPDATE Orders o
    JOIN production p
    ON o.tube_size = p.production_tube_size
        AND o.tube_type = p.production_tube_type
        AND o.tube_volume = p.production_tube_volume
SET o.order_production = p.production_id,
    o.order_status = 'В производстве'
WHERE o.order_production IS NULL;;
COMMIT;


create or replace view Order_customer_list as    -- показывает все заказы
    select concat(ts.tube_size_name, '/', tt.tube_type_name, '-', o.tube_volume) as "Наименование пробирки",
           concat(o.quantity, 'шт.') as "Количество",
           order_date 'Дата заказа',  concat(cn.customer_name_name, '. ', cc.customer_city_name) as "Заказчик",
           o.order_status as "Статус заказа"
        from order_customer oc
        join customer c on oc.order_customer_customer = c.id
        join customer_city cc on c.city = cc.customer_city_id
        join customer_name cn on c.name = cn.customer_name_id
        join orders o on oc.order_customer_order = o.order_Id
        join tube_size ts on o.tube_size = ts.tube_size_id
        join tube_type tt on o.tube_type = tt.tube_type_id;

create or replace view Production_list as       -- Показывает запланированные к производству пробирки
    select concat(ts.tube_size_name, '/', tt.tube_type_name, '-', p.production_tube_volume) as "Наименование пробирки",
           concat(p.production_quantity, 'шт.') as "Количество",
           p.production_change_date 'Дата изменения партии', p.production_status 'Статус партии'
    from production p
        join tube_size ts on ts.tube_size_id = p.production_tube_size
        join tube_type tt on tt.tube_type_id = p.production_tube_type;

select * from Production_list       -- Показывает все запланированное производство
    where `Наименование пробирки` = '1375/ZKR-3.0';

select * from Order_customer_list; -- Показывает все заказы

select * from Order_customer_list  -- Показывает все заказы для пробирки 1375/ZKR-3.0
    where `Наименование пробирки` = '1375/ZKR-3.0';

select * from Order_customer_list  -- Показывает все заказы сделанные Медтехникой Витебска
    where `Заказчик` = 'Медтехника. Витебск';

