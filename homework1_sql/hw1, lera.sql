select * from sales

-- 2.1
select region
from sales
group by region
HAVING count(DISTINCT itemname) > 1;


-- 2.2 Найти среднюю стоимость 2х наиболее часто покупаемых типов товаров
WITH TopTwoItems AS(
	select
		itemname,
		count(*),
		avg(netsales/qty) as avg_sales
	from sales
	group by itemname 
	order by count desc
	limit 2
	)
select avg(avg_sales) as average_sales
FROM TopTwoItems;


-- 2.3 Рассчитать среднее время (кол-во дней) между покупками в каждом регионе
with time_between_sales as (
select
	region, actiondate - lag(actiondate) over (partition by region order by actiondate) as t
from sales
)
select region, avg(t) 
from time_between_sales
group by region


-- 2.4 Посчитать процент  GMV (оборот) кофе japan от всех покупках в каждом регионе за каждый месяц
select region, extract(month from actiondate) as mon, 
	sum(case when itemname = 'Coffee Japan' then netsales else 0 end) / sum(netsales) * 100 as japan_percent
from sales
group by region, mon
order by region, mon

--2.5 Отсортировать по дате покупок и для первых 5 строчек посчитать скользящее среднее NetSales
-- в размером окна 3 - т.е. средней из текущей, предыдущей и следующей строчек
select actiondate, netsales, avg(netsales) over w as roll_avg
from (
	select actiondate, netsales
	from sales
	order by actiondate
	limit 5
) as t
window w as (
	order by actiondate
	rows between 1 preceding and 1 following
)
order by actiondate


--2.6 За каждый день вывести канал привлечения с максимальным GMV, и собственно сам GMV этого канала
with ranked_mediums as (
	select medium, actiondate, sum(netsales) as gmv, row_number() over (partition by actiondate order by sum(netsales) desc) as ranking
	from sales
	group by actiondate, medium
	order by actiondate, medium, sum(netsales)
)
select actiondate, medium, gmv
from ranked_mediums
where ranking = 1


-- 2.7 Найти наименее маржинальный канал привлечения (для которого минимально отношение прибыли к выручке)
select medium, sum(profit)/sum(netsales) as margin
from sales
group by medium
order by sum(profit)/sum(netsales)
limit 1
