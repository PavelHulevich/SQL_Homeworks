-- Обновить существующую запись production, прибавив к ней количество заказов с такими характеристиками,
-- если такая пробирка из заказов (в таблице orders) уже есть в плане производства (в таблице production).

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
    ON p.production_tube_size = new_orders.tube_size            -- находим такие же пробирки уже добавленные в план производства (в таблицу production)
        AND p.production_tube_type = new_orders.tube_type       --
        AND p.production_tube_volume = new_orders.tube_volume
SET p.production_quantity = p.production_quantity + new_orders.total_quantity, -- если такие найдутся то увеличиваем количество в производстве на величину нового заказа
    p.production_change_date = NOW();       -- меняем дату последнего изменения плана производства этого типа пробирки на текущую

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
-- Теперь добавляем новую пробирку в производство, в котором еще не было такой пробирки. Создаем новую строку производства.
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


SELECT NOW()
