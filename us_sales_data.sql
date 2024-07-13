select * from `sales data`;

alter table `sales data`
rename to sales_data;

alter table sales_data
drop column MyUnknownColumn;

select * from sales_data;

#let us the check the duplicates in the data

select count(*) from sales_data;

create view  sales_data_1 as 
select distinct * from sales_data;

select * from sales_data_1;
select count(*) from sales_data_1;
#so i have removed the duplicates in the data and i have stored it in view for futher analysis

#top 5 selling products

select product,round(sum(sales)) as total_sales 
from sales_data_1 group by product order by 
round(sum(sales)) desc limit 5;

#analysis1
/* from this you can infer that macbook laptop has the highest sales 
followed by iphone and lenevo laptop so people are likely to spend on laptop and phone 
*/

#which city has the highest sales in december 

select city,round(sum(sales)) as total_sales 
from sales_data_1 where month=12 group by city order by round(sum(sales)) desc
limit 1;

/* 
analysis 2

so san francisco has the highest sales in the december month 
*/

#display the top three products from each city 

with top_3 as (
select product,city,round(sum(sales)) as total_sales
from sales_data_1
group by product,city
),

top_3_prod as (
select *,row_number() over(partition by city order by total_sales desc) as rn
from top_3
)

select product,city from top_3_prod where 
rn<=3;

#find the percentage change in overall sales for each date in the month of december

with date_sales as (
select date(`Order Date`) as  od,round(sum(sales)) as total_sales
from sales_data_1 group by date(`Order Date`) order by date(`Order Date`)
),
lag_sales as (
select *,lag(total_sales) over(order by od) as prev_sales
from date_sales)

select od,concat(round((total_sales-prev_sales)/prev_sales*100,2),"%") as per_change
from lag_sales;


#display the highest sales in the month of  dec

with max_sales_in_12 as (
select * from sales_data_1 
where month(`Order Date`)=12
)
select product,sales from max_sales_in_12 where sales=(select max(sales) from max_sales_in_12)
limit 1;

#display the highest sales on dec 15 

with hig_sal_dec_15 as (
select * from sales_data_1 where 
month(`Order Date`)=12 and day(`Order Date`)=12
)
select product,sales from hig_sal_dec_15 where sales=(select max(sales) from hig_sal_dec_15)
limit 1;

#what is the total revenue generated in 2019

select ceil(sum(sales)) as total_revenue from sales_data_1;

#total quantity 
select sum(`Quantity Ordered`) as total_quantity from sales_data_1;


#display the quarter sales

select quarter(`Order Date`),sum(sales) from 
sales_data_1 group by quarter(`Order Date`)
order by quarter(`Order Date`);

select distinct(month(`Order Date`)) from sales_data_1;

select count(*) from sales_data_1;
select count(*) from sales_data;
select * from sales_data where year(`Order Date`)=2020;

select * from sales_data;

select quarter(`Order Date`) as order_date,sum(`Price Each`) from sales_data
where year(`Order Date`)=2019 and quarter(`Order Date`)=2 group by quarter(`Order Date`);



select timediff(current_date(),`Order Date`) from sales_data;

select week(`Order Date`) from sales_data;
select dayname(`Order Date`) from sales_data;
select weekday(`Order Date`) from sales_data;


select * from sales_data order by `Order Date`;

with cte1 as(
select quarter(`Order Date`) as quartersales,sum(sales) as total_sales
from sales_data group by quarter(`Order Date`)
),
cte2 as (
select *,lag(total_sales) over(order by quartersales) as sales_change from cte1
) 
select *,concat(round((total_sales-sales_change)/total_sales*100,2),"%") as per_change
from cte2





