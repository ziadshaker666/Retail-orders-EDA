-- checking some insights in the data that was already cleaned using pandas

select *
from retail_orders.orders_cleaned;

alter table orders_cleaned
modify profit float(2);
-- find top 10 highest reveue generating products 

select product_id, sum(sell_price) as sales
from orders_cleaned
group by product_id
order by sum(sell_price) desc limit 10;



-- find top 5 highest selling products in each region
select region, product_id, sum(sell_price) as sales
from orders_cleaned
group by region, product_id
order by region, sales desc;


with sales_per_region as
(
select region, product_id, sum(sell_price) as sales
from orders_cleaned
group by region, product_id
order by region, sales desc
),
cte_2 as
(
select *,
row_number () over(partition by region order by sales desc) as rn
from sales_per_region
)
select *
from cte_2
where rn <=5;

-- find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023

select year(order_date) as order_year, month(order_date) as order_month, sum(sell_price) as sales
from orders_cleaned
group by order_year, order_month
order by order_year, order_month;

with cte_1 as
(
select year(order_date) as order_year, month(order_date) as order_month, sum(sell_price) as sales
from orders_cleaned
group by order_year, order_month
order by order_year, order_month
)
select order_month,
sum(case when order_year = 2022 then sales else 0 end) as `2022`,
sum(case when order_year = 2023 then sales else 0 end) as `2023`
from cte_1
group by order_month
order by order_month;


-- for each category which month had highest sales 

select category, substring(order_date,1,7) as order_month, sum(sell_price) as sales
from orders_cleaned
group by category, order_month
order by category, order_month;

with cte_1 as
(
select category, substring(order_date,1,7) as order_month, sum(sell_price) as sales
from orders_cleaned
group by category, order_month
)
select *
from (
select *,
row_number () over (partition by category order by sales desc) as Ranking
from cte_1
) cte_2
where Ranking = 1;



-- which sub category had highest growth by profit in 2023 compare to 2022

with cte_1 as
(
select sub_category, (order_date) as order_year, sum(sell_price) as sales
from orders_cleaned
group by sub_category, order_year
order by sub_category, order_year
)
,cte_2 as 
(
select sub_category,
sum(case when order_year = 2022 then sales else 0 end) as `2022`,
sum(case when order_year = 2023 then sales else 0 end) as `2023`
from cte_1
group by sub_category
)
select  *
, (`2023` - `2022`) * 100 / `2022` as growth
from cte_2
order by growth desc limit 5;