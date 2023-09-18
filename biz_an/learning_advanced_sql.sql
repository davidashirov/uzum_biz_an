-- OVER and PARTITION BY: Calculate avg margin over each region and output together with each individual sale margin
select 
	region,
	itemname,
	netsales,
	profit/netsales as margin,
	avg(profit/netsales) over (partition by region) as avg_margin,
	round(avg(profit/netsales) over (partition by region) ::numeric, 3)  as avg_margin_rounded
from sales


-- ROW_NUMBER() OVER
select
	region,
	itemname,
	row_number() over ()
from sales


-- ROW_NUMBER() OVER number of sale among sales in a region as they are
-- RANK() OVER is the same as ROW_NUMBER() but similar values are given the same spot and corresponding ranks are skipped 
-- (like 1, 1, 1, 4, 4, 6 if N1,2,3 are equal and N4,5 are equal instead of 1,2,3,4,5,6
-- DENSE_RANK() OVER is the same as ROW_NUMBER() but similar values are given the same spot and corresponding ranks are NOT skipped 
-- (like 1, 1, 1, 2, 2, 3 if N1,2,3 are equal and N4,5 are equal instead of 1,2,3,4,5,6
select
	region,
	itemname,
	netsales,
	row_number() over (partition by region) as size_rank_with_row_number,
	rank() over (partition by region order by netsales desc) as size_rank_with_rank,
	dense_rank() over (partition by region order by netsales desc) as size_rank_with_dense_rank
from sales


-- ROW_NUMBER() OVER rank the sale size among other sales in a region: top 10 sales in each region
select * from (
	select
		region,
		itemname,
		netsales,
		ROW_NUMBER() over (partition by region order by netsales desc) as size_rank
	from sales
	) as subquery
where size_rank < 11


-- LAG and LEAD
select
	region,
	itemname,
	actiondate,
	lag(netsales, 2) over () as before_prev_sale,
	lag(netsales) over () as previous_sale,
	netsales,
	lead(netsales) over () as next_sale,
	lag(netsales) over (partition by itemname) as previous_sale_of_this_item
from sales