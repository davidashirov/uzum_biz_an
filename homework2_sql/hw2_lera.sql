select * from events

select * from orders

-- 2.1 (2 балла) Сделать сешшионизацию по таблице events, с разрывом сессии через 30 минут или после смены канала привлечения.
SELECT
    Medium,
    Datetime,
    SUM(Medium != neighbor(Medium,-1) OR runningDifference(Datetime) > 30*60) OVER (ORDER BY Datetime) as session_id
FROM events
ORDER BY Datetime


-- 2.2 (1 балл) Посчитать месячный ретеншн в таблице orders по когортам с помощью функции retention
SELECT
	Client_id,
	retention(toMonth(ActionDate)=6, toMonth(ActionDate)=7, toMonth(ActionDate)=8)
FROM
	orders
GROUP BY Client_id


-- 2.3 (1 балл) Посчитать месячный ретенш в таблице orders по когортам не используя функцию retention.
SELECT
	Client_id,
	groupUniqArray(toMonth(ActionDate))
FROM
	orders
GROUP BY Client_id


-- 2.4 (2 балла) Сделать массив из повторенных 5 раз цифр 1, затем 5 цифр 2 и тд до 5 цифр: -- 10(1,1,1,1,2,2,2,2, …., 10,10,10,10,10), 
-- не перечисляя все 50 цифр, а воспользовавшись функциями arrayResize и arrayFlatten.
SELECT arrayFlatten(arrayMap(x -> arrayResize([x], 5, x), range(1, 11))) as arr


-- 2.5 (1 балл) Для массива из прошлой задачи вывести каждый третий элемент.
SELECT arrayMap(x -> arr[x], range(3, length(arr), 3))
FROM (
	SELECT arrayFlatten(arrayMap(x -> arrayResize([x], 5, x), range(1, 11))) as arr
)


-- 2.6 (2 балла) Задача из прошлого ДЗ, но теперь ее нужно решить проще с помощью функций clickhouse: 
-- за каждый день вывести канал привлечения с максимальным GMV, и собственно сам GMV этого канала (таблица orders)
SELECT
	ActionDate,
	argMax(Medium, gmv) as medium,
	MAX(gmv) as max_nets
FROM
	(SELECT	
		*, 
		SUM(NetSales) over (partition by ActionDate, Medium) as gmv
	FROM orders orders)
GROUP BY ActionDate
ORDER BY ActionDate asc


-- 2.7 (1 балл) Найти клиентов (последовательность шагов), которые купили coffe Columbia, 
-- и затем в течении 3 дней купили также и coffe brasil (таблица orders)
SELECT * 
FROM (
	SELECT * 
	FROM orders 
	ORDER BY Client_id, ActionDate
	)
WHERE (ItemName = 'Coffee Brasil') AND (neighbor(ItemName, -1) = 'Coffee Columbia') AND (neighbor(Client_id, -1) = Client_id) AND (ActionDate - neighbor(ActionDate, -1) <=3)

