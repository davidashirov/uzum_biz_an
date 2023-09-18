-- Выбрать все
select * from sales


-- 2.1 Найти регионы с покупкой более чем одним типом товаров
SELECT region
FROM sales
GROUP BY region
HAVING COUNT(DISTINCT ItemName) > 1;


-- 2.2 Найти среднюю стоимость 2х наиболее часто покупаемых типов товаров
select avg(avgsales) as avg_price
from (
	SELECT itemname, AVG(netsales/qty)  AS avgsales
	FROM sales
	WHERE itemname in (
		SELECT itemname
		FROM sales
		GROUP BY itemname
		ORDER BY COUNT(*) DESC
		LIMIT 2
	)
	GROUP BY itemname
) as t


-- 2.3 Рассчитать среднее время (кол-во дней) между покупками в каждом регионе
-- Вспомогательный запрос
SELECT region, actiondate,
    LAG(actiondate) OVER (PARTITION BY region ORDER BY actiondate) AS prev_purchase_date,
    date(actiondate) - date(LAG(actiondate) OVER (PARTITION BY region ORDER BY actiondate)) AS time_between_purchases
FROM sales

-- Весь запрос
SELECT region, AVG(time_between_purchases) AS avg_time_between_purchases
FROM (
    SELECT region, actiondate,
           LAG(actiondate) OVER (PARTITION BY region ORDER BY actiondate) AS prev_purchase_date,
           date(actiondate) - date(LAG(actiondate) OVER (PARTITION BY region ORDER BY actiondate)) AS time_between_purchases
    FROM sales
) AS subquery
GROUP BY region;



-- 2.4 Посчитать процент  GMV (оборот) кофе japan от всех покупках в каждом регионе за каждый месяц
SELECT
    region,
    EXTRACT(YEAR FROM actiondate) AS year,
    EXTRACT(MONTH FROM actiondate) AS month,
    SUM(CASE WHEN itemname = 'Coffee Japan' THEN netsales ELSE 0 END) /
    SUM(netsales) * 100 AS percentage_netsales
FROM sales
GROUP BY region, year, month
ORDER BY region, year, month;


-- 2.5 Отсортировать по дате покупок и для первых 5 строчек посчитать скользящее среднее
-- NetSales в размером окна 3 - т.е. средней из текущей, предыдущей и следующей строчек
SELECT
    actiondate,
    netsales,
    AVG(netsales) OVER (
        ORDER BY actiondate
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) AS rolling_average
FROM (
    SELECT
        actiondate,
        netsales
    FROM sales
    ORDER BY actiondate
    LIMIT 5
) AS subquery;

-- Только вспомогательный запрос
select
	region,
	actiondate,
    netsales
FROM sales
ORDER BY actiondate
LIMIT 5;


-- 2.6 За каждый день вывести канал привлечения с максимальным GMV, и собственно сам GMV этого канала
WITH DailyMaxGMV AS (
    SELECT
        DATE(actiondate) AS date,
        medium,
        SUM(netsales) AS daily_gmv,
        RANK() OVER (PARTITION BY DATE(actiondate) ORDER BY SUM(netsales) DESC) AS gmv_rank
    FROM sales
    GROUP BY DATE(actiondate), medium
)
SELECT
    date,
    medium AS top_medium,
    daily_gmv AS top_gmv
FROM DailyMaxGMV
WHERE gmv_rank = 1;


-- 2.7 Найти наименее маржинальный канал привлечения (для которого минимально отношение прибыли к выручке)
SELECT medium, SUM(profit) / SUM(netsales) AS margin
FROM sales
GROUP BY medium
ORDER BY margin ASC
LIMIT 1
