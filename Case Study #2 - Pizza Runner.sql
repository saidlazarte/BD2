-- Crear base de datos
DROP DATABASE IF EXISTS pizza_runner;
CREATE DATABASE pizza_runner;
USE pizza_runner;

-- Tabla runners
DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INT,
  registration_date DATE
);

INSERT INTO runners (runner_id, registration_date) VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');

-- Tabla customer_orders
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS customer_orders;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE customer_orders (
  order_id INT,
  customer_id INT,
  pizza_id INT,
  exclusions VARCHAR(255),
  extras VARCHAR(255),
  order_time DATETIME
);

INSERT INTO customer_orders (order_id, customer_id, pizza_id, exclusions, extras, order_time) VALUES
  (1, 101, 1, '', '', '2020-01-01 18:05:02'),
  (2, 101, 1, '', '', '2020-01-01 19:00:52'),
  (3, 102, 1, '', '', '2020-01-02 23:51:23'),
  (3, 102, 2, '', NULL, '2020-01-02 23:51:23'),
  (4, 103, 1, '4', '', '2020-01-04 13:23:46'),
  (4, 103, 1, '4', '', '2020-01-04 13:23:46'),
  (4, 103, 2, '4', '', '2020-01-04 13:23:46'),
  (5, 104, 1, NULL, '1', '2020-01-08 21:00:29'),
  (6, 101, 2, NULL, NULL, '2020-01-08 21:03:13'),
  (7, 105, 2, NULL, '1', '2020-01-08 21:20:29'),
  (8, 102, 1, NULL, NULL, '2020-01-09 23:54:33'),
  (9, 103, 1, '4', '1, 5', '2020-01-10 11:22:59'),
  (10, 104, 1, NULL, NULL, '2020-01-11 18:34:49'),
  (10, 104, 1, '2, 6', '1, 4', '2020-01-11 18:34:49');


-- Tabla runner_orders
DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INT,
  runner_id INT,
  pickup_time VARCHAR(19),
  distance VARCHAR(20),
  duration VARCHAR(20),
  cancellation VARCHAR(50)
);

INSERT INTO runner_orders (order_id, runner_id, pickup_time, distance, duration, cancellation) VALUES
  (1, 1, '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  (2, 1, '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  (3, 1, '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  (4, 2, '2020-01-04 13:53:03', '23.4', '40', NULL),
  (5, 3, '2020-01-08 21:10:57', '10', '15', NULL),
  (6, 3, NULL, NULL, NULL, 'Restaurant Cancellation'),
  (7, 2, '2020-01-08 21:30:45', '25km', '25mins', NULL),
  (8, 2, '2020-01-10 00:15:02', '23.4 km', '15 minute', NULL),
  (9, 2, NULL, NULL, NULL, 'Customer Cancellation'),
  (10, 1, '2020-01-11 18:50:20', '10km', '10minutes', NULL);

-- Tabla pizza_names
DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INT,
  pizza_name VARCHAR(100)
);

INSERT INTO pizza_names (pizza_id, pizza_name) VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');

-- Tabla pizza_recipes
DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INT,
  toppings VARCHAR(255)
);

INSERT INTO pizza_recipes (pizza_id, toppings) VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');

-- Tabla pizza_toppings
DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INT,
  topping_name VARCHAR(100)
);

INSERT INTO pizza_toppings (topping_id, topping_name) VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
-- A. Métricas de pizza
-- 1.¿Cuántas pizzas se pidieron?
SELECT COUNT(*) AS total_pizzas
FROM customer_orders;
-- 2.¿Cuántos pedidos de clientes únicos se realizaron?
SELECT COUNT(DISTINCT order_id) AS pedidos_unicos
FROM customer_orders;
-- 3.¿Cuántos pedidos entregados con éxito fueron realizados por cada corredor?
SELECT runner_id, COUNT(DISTINCT order_id) AS pedidos_exitosos
FROM runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id;
-- 4. ¿Cuántas pizzas de cada tipo se entregaron?
SELECT p.pizza_name, COUNT(co.order_id) AS pizzas_entregadas
FROM customer_orders co
JOIN pizza_names p ON co.pizza_id = p.pizza_id
JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL
GROUP BY p.pizza_name;
-- 5.¿Cuántos vegetarianos y carnívoros pidió cada cliente?
SELECT co.customer_id,
       SUM(CASE WHEN pn.pizza_name = 'Vegetarian' THEN 1 ELSE 0 END) AS vegetarianas,
       SUM(CASE WHEN pn.pizza_name = 'Meatlovers' THEN 1 ELSE 0 END) AS carnivoras
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL
GROUP BY co.customer_id;
-- 6.¿Cuál fue el número máximo de pizzas entregadas en un solo pedido?
SELECT MAX(pizza_count) AS max_pizzas_por_pedido
FROM (
    SELECT order_id, COUNT(*) AS pizza_count
    FROM customer_orders
    GROUP BY order_id
) AS subquery;
-- 7.Para cada cliente, ¿cuántas pizzas entregadas tuvieron al menos 1 cambio y cuántas no tuvieron cambios?
SELECT co.customer_id,
       SUM(CASE WHEN co.exclusions IS NOT NULL OR co.extras IS NOT NULL THEN 1 ELSE 0 END) AS con_cambios,
       SUM(CASE WHEN co.exclusions IS NULL AND co.extras IS NULL THEN 1 ELSE 0 END) AS sin_cambios
FROM customer_orders co
JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL
GROUP BY co.customer_id;
-- 8.¿Cuántas pizzas se entregaron que tenían exclusiones y extras?
SELECT COUNT(DISTINCT co.order_id) AS pedidos_con_exclusiones_y_extras
FROM customer_orders co
JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL
  AND (co.exclusions IS NOT NULL OR co.extras IS NOT NULL);
-- 9.¿Cuál fue el volumen total de pizzas pedidas durante cada hora del día?
SELECT HOUR(order_time) AS hora, COUNT(*) AS volumen_pedidos
FROM customer_orders
GROUP BY HOUR(order_time)
ORDER BY hora;
-- 10.¿Cuál fue el volumen de pedidos para cada día de la semana?
SELECT DAYOFWEEK(order_time) AS dia_semana, COUNT(*) AS volumen_pedidos
FROM customer_orders
GROUP BY dia_semana
ORDER BY dia_semana;
-- B. Runner y la experiencia del cliente
-- 1.¿Cuántos corredores se inscribieron para cada período de 1 semana?
SELECT YEARWEEK(registration_date, 1) AS semana, COUNT(*) AS corredores_inscritos
FROM runners
GROUP BY semana
ORDER BY semana;
-- 2.¿Cuál fue el tiempo promedio en minutos que tardó cada corredor en llegar a la sede de Pizza Runner para recoger el pedido?
SELECT ro.runner_id,
       AVG(TIMESTAMPDIFF(MINUTE, co.order_time, ro.pickup_time)) AS tiempo_promedio_minutos
FROM runner_orders ro
JOIN customer_orders co ON ro.order_id = co.order_id
WHERE ro.cancellation IS NULL
GROUP BY ro.runner_id;
-- 3.¿Existe alguna relación entre la cantidad de pizzas y el tiempo que tarda en prepararse el pedido?
--
-- 4.¿Cuál fue la distancia promedio recorrida por cada cliente?
SELECT co.customer_id,
       AVG(CAST(SUBSTRING_INDEX(ro.distance, 'km', 1) AS DECIMAL(5,2))) AS distancia_promedio_km
FROM customer_orders co
JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL
GROUP BY co.customer_id;
-- 5.¿Cuál fue la diferencia entre los tiempos de entrega más largos y más cortos para todos los pedidos?
SELECT MAX(TIMESTAMPDIFF(MINUTE, co.order_time, ro.pickup_time)) - MIN(TIMESTAMPDIFF(MINUTE, co.order_time, ro.pickup_time)) AS diferencia_tiempos_entrega
FROM runner_orders ro
JOIN customer_orders co ON ro.order_id = co.order_id
WHERE ro.cancellation IS NULL;
-- 6.¿Cuál fue la velocidad promedio de cada corredor en cada entrega?
SELECT ro.runner_id,
       AVG(CAST(SUBSTRING_INDEX(ro.distance, 'km', 1) AS DECIMAL(5,2)) / (TIMESTAMPDIFF(MINUTE, co.order_time, ro.pickup_time) / 60)) AS velocidad_promedio_km_h
FROM runner_orders ro
JOIN customer_orders co ON ro.order_id = co.order_id
WHERE ro.cancellation IS NULL
GROUP BY ro.runner_id;
-- 7.¿Cuál es el porcentaje de entrega exitosa de cada corredor?
SELECT ro.runner_id,
       (COUNT(CASE WHEN ro.cancellation IS NULL THEN 1 END) / COUNT(*)) * 100 AS porcentaje_entrega_exitosa
FROM runner_orders ro
GROUP BY ro.runner_id;
-- C. Optimización de Ingredientes
-- 1. ¿Cuáles son los ingredientes estándar de cada pizza?
SELECT pn.pizza_name,
       GROUP_CONCAT(pt.topping_name ORDER BY pt.topping_name SEPARATOR ', ') AS ingredientes
FROM pizza_recipes pr
JOIN pizza_names pn ON pr.pizza_id = pn.pizza_id
JOIN pizza_toppings pt ON FIND_IN_SET(pt.topping_id, pr.toppings) > 0
GROUP BY pn.pizza_name;
-- 2. ¿Cuál fue el extra añadido más común?
SELECT extras, COUNT(*) AS cantidad
FROM customer_orders
WHERE extras IS NOT NULL AND extras != ''
GROUP BY extras
ORDER BY cantidad DESC
LIMIT 1;
-- 3. ¿Cuál fue la exclusión más común?
SELECT exclusions, COUNT(*) AS cantidad
FROM customer_orders
WHERE exclusions IS NOT NULL AND exclusions != ''
GROUP BY exclusions
ORDER BY cantidad DESC
LIMIT 1;
-- 4. Generar un elemento de pedido para cada registro de la tabla customer_orders
SELECT pn.pizza_name,
       CONCAT_WS(' - Exclude ', pn.pizza_name, REPLACE(co.exclusions, ',', ' - Exclude ')) AS pedido
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
WHERE co.exclusions IS NOT NULL AND co.exclusions != '';
-- 5. Generar una lista de ingredientes separados por comas y ordenada alfabéticamente para cada pedido de pizza
SELECT
  co.order_id,
  co.customer_id,
  pn.pizza_name,
  pt.topping_name
FROM customer_orders co
JOIN pizza_recipes pr ON co.pizza_id = pr.pizza_id
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
JOIN pizza_toppings pt ON FIND_IN_SET(pt.topping_id, pr.toppings)
WHERE co.order_id IN (
  SELECT order_id FROM runner_orders WHERE cancellation IS NULL
)
ORDER BY co.order_id, pt.topping_name;
-- 6. ¿Cuál es la cantidad total de cada ingrediente utilizado en todas las pizzas entregadas ordenadas por frecuencia de uso primero?
SELECT pt.topping_name, COUNT(*) AS cantidad
FROM customer_orders co
JOIN pizza_recipes pr ON co.pizza_id = pr.pizza_id
JOIN pizza_toppings pt ON FIND_IN_SET(pt.topping_id, pr.toppings) > 0
WHERE co.order_id IN (SELECT order_id FROM runner_orders WHERE cancellation IS NULL)
GROUP BY pt.topping_name
ORDER BY cantidad DESC;
-- D. Precios y Calificaciones
-- 1. ¿Cuánto dinero ganó Pizza Runner hasta ahora si no hay cargos por cambios?
SELECT SUM(
  CASE pn.pizza_name
    WHEN 'Meatlovers' THEN 12
    WHEN 'Vegetarian' THEN 10
    ELSE 0
  END
) AS total_ganado
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
WHERE co.order_id IN (
  SELECT order_id FROM runner_orders WHERE cancellation IS NULL
);
-- 2. ¿Qué pasa si hay un cargo adicional de $1 por cualquier pizza extra? Agregar queso cuesta $1 extra.
SELECT SUM(CASE WHEN pn.pizza_name = 'Meatlovers' THEN 12
                WHEN pn.pizza_name = 'Vegetarian' THEN 10
                ELSE 0 END +
                CASE WHEN co.extras IS NOT NULL AND co.extras != '' THEN 1 ELSE 0 END +
                CASE WHEN co.exclusions LIKE '%4%' THEN 1 ELSE 0 END) AS ingresos
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id;
-- 3. Diseño de una tabla adicional para calificaciones de corredores
CREATE TABLE runner_ratings (
  order_id INT,
  runner_id INT,
  rating INT
);
INSERT INTO runner_ratings (order_id, runner_id, rating) VALUES
  (1, 1, 5),
  (2, 1, 4),
  (3, 1, 4),
  (4, 2, 3),
  (5, 3, 5),
  (7, 2, 4),
  (8, 2, 4),
  (10, 1, 5);
INSERT INTO runner_ratings (order_id, runner_id, rating) VALUES
(1, 1, 5),
(2, 1, 4),
(3, 2, 3),
(4, 2, 4),
(5, 3, 5),
(6, 3, 2),
(7, 2, 4),
(8, 2, 5),
(9, 2, 3),
(10, 1, 4);
-- 4. Unir toda la información para formar una tabla con entregas exitosas
SELECT
  co.customer_id,
  co.order_id,
  ro.runner_id,
  rr.rating,
  co.order_time,
  ro.pickup_time,
  TIMESTAMPDIFF(MINUTE, co.order_time, ro.pickup_time) AS tiempo_espera,
  ro.duration AS duracion_entrega,
  ro.distance,
  COUNT(*) AS total_pizzas
FROM customer_orders co
JOIN runner_orders ro ON co.order_id = ro.order_id
JOIN runner_ratings rr ON co.order_id = rr.order_id AND ro.runner_id = rr.runner_id
WHERE ro.cancellation IS NULL
GROUP BY co.customer_id, co.order_id, ro.runner_id, rr.rating, co.order_time, ro.pickup_time, ro.duration, ro.distance
ORDER BY co.order_id;
-- 5. ¿Cuánto dinero le queda a Pizza Runner después de estas entregas?
SELECT
  SUM(CASE pn.pizza_name
    WHEN 'Meatlovers' THEN 12
    WHEN 'Vegetarian' THEN 10
    ELSE 0
  END) AS ingresos_totales,
  SUM(
    CAST(REPLACE(REPLACE(ro.distance, 'km', ''), ' ', '') AS DECIMAL(5,2)) * 0.30
  ) AS pago_repartidores,
  SUM(CASE pn.pizza_name
    WHEN 'Meatlovers' THEN 12
    WHEN 'Vegetarian' THEN 10
    ELSE 0
  END) -
  SUM(
    CAST(REPLACE(REPLACE(ro.distance, 'km', ''), ' ', '') AS DECIMAL(5,2)) * 0.30
  ) AS ganancia_final
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL;
-- E. Preguntas adicionales
-- Si Danny quiere ampliar su gama de pizzas, ¿cómo afectaría esto al diseño de datos existente?
INSERT INTO pizza_names (pizza_id, pizza_name)
VALUES (3, 'Supreme');

INSERT INTO pizza_recipes (pizza_id, toppings)
VALUES (
  3,
  (
    SELECT GROUP_CONCAT(topping_id ORDER BY topping_id SEPARATOR ',')
    FROM pizza_toppings
  )
);