-- SELECT all and sort by actiondate
select * from sales
order by actiondate

-- BETWEEN and ORDER BY
select * from sales
where client_id between 3 and 5
order by client_id asc

-- Top N - LIMIT keyword, show top 10 negative profitability deals
select * from sales
where profit < 0
order by profit asc
limit 10

-- UNIQUE - find all unique values for given column(s)
select distinct itemname, region
from sales

-- Rename columns - AS keyword
select region as district, itemname as coffee, netsales as gmv
from sales

-- EXTRACT some part of a date. List of parts: (https://www.w3schools.com/sql/func_mysql_extract.asp)
select 
	region, 
	itemname, 
	netsales,
	extract(year from actiondate) as year,
	extract(month from actiondate) as month,
	extract(day from actiondate) as day
from sales
order by actiondate asc

--  UPPER, LOWER, LENGTH, TRIM (removes trailing and leading spaces)
select
	region,
	upper(region),
	lower(region),
	length(region),
	trim(region)
from sales


-- CONCAT
select 
	region || ', ' || itemname,
	cast(netsales as varchar) || ', ' || cast(profit as varchar) as netsales_comma_profit
from sales

-- CONCAT entire sentenses!
select 
	cast(qty as varchar) || ' ' || itemname || ' units were sold for ' || cast(netsales as varchar) || ' with ' || cast(profit as varchar) || ' profit in ' || region
from sales


-- BOOL expressions
select 
	region,
	itemname,
	profit,
	(profit > 0) as profitable
from sales


-- LIKE, % wildcard, coffee ending with '...ia'
select 
	region,
	itemname,
	(itemname like '%ia') as itemname_ending_with_ia
from sales


-- SUBSTRING - extract substring from region
select region, substring(region from 8) 
from sales

-- POSITION - get position of a character
select region, position('о' in region)
from sales

-- Combine SUBSTRING and POSITION to cut strings from some symbol
select 
	cast(actiondate as varchar) as data_as_varchar,
	position('-' in cast(actiondate as varchar)) as position_of_dash,
	substring(cast(actiondate as varchar), position('-' in cast(actiondate as varchar))+1) as month_and_day_as_varchar
from sales


-- MIN, MAX, AVG, SUM, COUNT
SELECT
  MIN(netsales),
  MAX(netsales),
  ROUND(AVG(netsales)::numeric, 2) -- WARMING - AVG returns double precision type, 
  -- ROUND can't accept it, so we cast result to numeric type (::numeric)
FROM sales;

-- If there are more columns passed to SELECT which are not aggregated with MIN SUM AVG COUNT,
-- We must use GROUP BY this column
select
  region, -- Unaggregated column
  ROUND(AVG(netsales)::numeric, 2) as avg_sales, -- WARMING - AVG returns double precision type,
  COUNT(*) as n_sales_in_region
  -- ROUND can't accept it, so we cast result to numeric type (::numeric)
FROM sales
group by region -- without this it return error "ERROR: column "sales.region" must appear in the GROUP BY clause or be used in an aggregate function"
order by n_sales_in_region desc


-- HAVING is like special WHERE clause which can be used with GROUP BY
select
  region, -- Unaggregated column
  ROUND(AVG(netsales)::numeric, 2) as avg_sales,
  COUNT(*) as n_sales_in_region
FROM sales
group by region
having COUNT(*) > 10 -- only regions with number of sales > 10
order by n_sales_in_region desc


-- CASE statement - works like 'if, else if, else'
select
	region,
	itemname,
	netsales,
	profit,
	case
		when profit > 0 then 'Profit'
		when profit < 0 then 'Loss'
		else 'break even'
	end
from sales
	

-- Nested requests in SQL: number of profitable and lossy deals in each region.
select
	region,
	profitability,
	count(*)
from (
	select
		region,
		itemname,
		netsales,
		profit,
		case
			when profit > 0 then 'Profit'
			when profit < 0 then 'Loss'
			else 'break even'
		end as profitability
	from sales
) as subtable -- each subquery should be named somehow
group by region, profitability
order by region, profitability

-- More subqueries
select
	region,
	itemname,
	netsales,
	(select avg(netsales) from sales limit 1) as average_sale,
	netsales - (select avg(netsales) from sales limit 1) as deviation_from_avg_sale
from sales


-- Transposed 
select
	sum(case
		when profit >=0 then 1
		when profit < 0 then 0
		end) as n_profitable_deals,
	sum(case
		when profit >=0 then 0
		when profit < 0 then 1
		end) as n_lossy_deals
from sales