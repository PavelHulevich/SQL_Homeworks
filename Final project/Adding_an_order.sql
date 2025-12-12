-- Обновить существующую запись production, прибавив к ней количество заказов с такими характеристиками
UPDATE production p
    JOIN (
        SELECT
            o.tube_size,
            o.tube_type,
            o.tube_volume,
            SUM(o.quantity) AS total_quantity
        FROM Orders o
        WHERE o.order_production IS NULL -- или другой критерий, чтобы брать только новые заказы, ещё не связанного производства
        GROUP BY o.tube_size, o.tube_type, o.tube_volume
    ) new_orders
    ON p.production_tube_size = new_orders.tube_size
        AND p.production_tube_type = new_orders.tube_type
        AND p.production_tube_volume = new_orders.tube_volume
SET p.production_quantity = p.production_quantity + new_orders.total_quantity,
    p.production_change_date = NOW();

-- Обновить заказы, чтобы они ссылались на уже существующую запись в production
UPDATE Orders o
    JOIN production p
    ON o.tube_size = p.production_tube_size
        AND o.tube_type = p.production_tube_type
        AND o.tube_volume = p.production_tube_volume
SET o.order_production = p.production_id,
    o.order_status = 'В производстве'
WHERE o.order_production IS NULL; -- или другой критерий, если нужно обновлять только новые заказы

-- Добавляем новую пробирку в производство, в котором еще не было такой пробирки
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
