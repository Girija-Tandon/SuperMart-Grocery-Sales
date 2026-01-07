use hotel;
-- 1.Find the top 5 Sub-Categories with the highest total Sales (ignore discounts for now). 
-- Return Sub Category and total sales, sorted descending.
select `Sub Category` , sum(Sales) as total_sales
from `supermart grocery sales - retail analytics dataset`
group by `Sub Category`
order by total_sales desc 
limit 5;


-- 2.Which City generated the highest total Profit? Return City, total Sales, total Profit, and Profit Margin % (Profit/Sales * 100).
select City, sum(Sales) as total_sales, sum(Profit) as total_Profit, 
	   round(100.0 * sum(Profit) / sum(Sales) ,2) as profit_margin
from  `supermart grocery sales - retail analytics dataset`
group by City
order by total_Profit desc
limit 1;


-- 3.Show total Sales and total Profit for each month (from Order Date). Format the month as 'YYYY-MM'. Order by date.
select sum(Sales) as total_sales , round(sum(Profit),2) as total_profit ,
       date_format(str_to_date(`Order Date` , '%d-%m-%Y') , '%Y-%m') as Month
from `supermart grocery sales - retail analytics dataset`
group by date_format(str_to_date(`Order Date` , '%d-%m-%Y') , '%Y-%m') 
order by Month;


-- 4.Rank the Regions by average Profit per order. Return Region, total orders, total Profit, and average Profit per order.
select Region, count(*) as total_order, sum(Profit) as total_profit,
       round(sum(Profit) / count(*) , 2) as profit_per_order
from `supermart grocery sales - retail analytics dataset`
group by Region
order by profit_per_order desc;


-- 5.For the Central region only, find total Sales and Profit for each Category. Which Category performs best in terms of Profit?
select  sum(Sales) as total_sales, sum(Profit) as total_Profit,
       Category
from `supermart grocery sales - retail analytics dataset`
where Region = 'Central'
group by  Category
order by total_profit desc ;


-- 6.Identify all Sub-Categories where total Profit is negative (i.e., overall loss).
-- Return Sub Category, total Sales, total Profit, sorted by Profit ascending.
select "Sub-Category",Sum(Sales) as total_sales, sum(Profit) as total_profit
from `supermart grocery sales - retail analytics dataset`
group by "Sub-Category"
having  sum(Profit) < 0
order by  total_profit asc;


-- 7.Find the average Discount % given in each Category. Also show total Sales and total Profit.
--  Is there a correlation visible between high discount and low profit?
select  Category , avg(Discount) as avg_discount, Sum(Sales) as total_sales, sum(Profit) as total_profit
from  `supermart grocery sales - retail analytics dataset`
group by Category
order by total_profit desc;


-- 8.Find the top 3 customers (Customer Name) who generated the highest total Profit for the store. 
-- Return Customer Name, total Sales, total Profit.
select `Customer Name` , Sum(Sales) as total_sales, sum(Profit) as total_profit 
from `supermart grocery sales - retail analytics dataset`
group by `Customer Name` 
order by total_profit desc
limit 3;
-- 9.Assuming the data spans multiple years, calculate total Sales for each year. Then show YoY growth % in Sales.
with yearly_sales as (
      select extract(year  from to_date ("Order Date", 'DD-MM-YYYY')) as year,
             Sum(Sales) as total_sales
	 from `supermart grocery sales - retail analytics dataset`
     group by year 
)
select year, 
      total_sales,
      round( 100.0 * (total_sales - lag(total_sales) over(order by year)) / lag(total_sales) over(order by year) , 2) as YoY_growth
from yearly_sales
order by year;


-- 10.Show daily Sales along with Running Total (cumulative) Sales up to that date. Order by Order Date.
select str_to_date("Order Date", '%d-%m-%Y') as order_date , sum(Sales) as total_sales,
       sum(sum(Sales)) over(order by str_to_date("Order Date", '%d-%m-%Y') rows between unbounded preceding and current row) as running_total
from `supermart grocery sales - retail analytics dataset`
group by order_date 
order by order_date ;


-- 11.Find orders where Discount > 0.30 (30%) and Profit was negative. How many such loss-making high-discount orders exist?
select count(*) as loss_orders
from `supermart grocery sales - retail analytics dataset` 
where Discount > 0.30 and Profit < 0 ;


-- 12.Which Sub-Categories contribute to 80% of total Sales? List them cumulatively until the running sales reach ~80% of grand total.
with sub_sales as (
     select `Sub Category` , sum(Sales) as sub_total_sales
     from `supermart grocery sales - retail analytics dataset`
     group by `Sub Category`
	),
ordered as (
     select `Sub Category`, sub_total_sales,
             sum(sub_total_sales) over(order by sub_total_sales desc) as running_total
	from sub_sales
),
totals as (
  select sum(sub_total_sales) over() as grand_total
  from ordered
)
select  `Sub Category`, 
        sub_total_sales,
        running_total,
        round(100.0 * running_total /  grand_total , 2) as cumulative_pct
from totals
order by running_total desc;
