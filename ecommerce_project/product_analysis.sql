#lets analyze the monthly sales total revenue and margins for the sales

select * from  orders;

with cte1 as (
select substr(created_at,1,7) as yr_month,count(*) as no_of_sales,
sum(price_usd) as total_revenue,sum(price_usd-cogs_usd) as margin
from orders where date(created_at)<'2013-01-04' group by substr(created_at,1,7)
)
select * from cte1;

-- analyzing the clickthrough rate of a new product before and after the 
-- product launch

with pre_product as (
select *,case
when date(created_at) <'2013-01-06' then 'pre_product'
else 'post_product' end as cat from website_pageviews
),
cte2 as (
select * from pre_product
where date(created_at)>'2012-10-06' and 
date(created_at)<'2013-04-06'
),

cte3 as (
select cat,count(website_session_id) as total_sessions,
sum(case when pageview_url='/products' then 1 else 0 end) as with_next_page,
sum(case when pageview_url='/the-original-mr-fuzzy' then 1 else 0 end) as orgianl_fuzzy,
sum(case when pageview_url='/the-forever-love-bear' then 1 else 0 end) as love_bear
from cte2 group by cat
)
select * from cte3;

#as you can see the difference before the product launch and after 
# the product launch

#cross product analysis


select * from orders;
select * from order_items;


with cte1 as (
select a.order_id,a.primary_product_id,b.product_id
from orders as a left join order_items as b on
a.order_id=b.order_id and b.is_primary_item=0
),

cte2 as (
select primary_product_id,product_id as cross_product,count(*) as 
total_orders from cte1 group by primary_product_id,product_id
)
select * from cte2 order by primary_product_id;


select * from orders;
select * from website_pageviews;

#company has launched a new scheme of adding a new product in the cart
#page since 25 the sept 2013 we need to analyze ctr of cart page 
#aov total_orders and items purchased the month before and after

with cte1 as (
select * from website_pageviews 
where date(created_at) between '2013-08-25' and '2013-10-25'
),

cte2 as (
select *,case 
when date(created_at) <'2013-09-25' then 'pre_cross_sell'
else 'post_cross_sell' end as cross_sell from cte1
),

cte3 as (
select cross_sell,
sum(case when pageview_url='/cart' then 1 else 0 end ) as cart_sessions,
sum(case when pageview_url='/shipping' then 1 else 0 end) as shipping_sessions
from cte2 group by cross_sell
),

cte4 as (
select *,(shipping_sessions/cart_sessions*100) as click_through_rate
from cte3
),

cte5 as (
select d.website_session_id,d.pageview_url,d.cross_sell,e.items_purchased,
e.order_id,
e.price_usd from cte2 as d left join orders as e on d.website_session_id=
e.website_session_id and d.pageview_url='/thank-you-for-your-order'
),

cte6 as (
select cross_sell,avg(price_usd) as aov,count(order_id) as total_orders,
sum(items_purchased) as total_items 
from cte5 group by cross_sell
)
select a.cross_sell,a.cart_sessions,a.shipping_sessions,a.click_through_rate,
b.aov,b.total_orders,b.total_items from cte4 as a join cte6 as b on a.cross_sell=b.cross_sell; 

#launced a new product birthday bear on 12 december so we have to run
# the pre post analysis before a month and after a month and calculating
# the conversion rate order value and products per order

select * from website_pageviews;

with cte1 as (
select * from website_pageviews 
where date(created_at) between '2013-11-12' and '2014-01-12'
),

cte2 as (
select *,case
when date(created_at)<'2013-12-12' then  'pre_birthday_bear'
else 'post_birthday_bear' end as time_period from cte1
),

cte3 as (
select a.created_at,a.website_session_id,a.pageview_url,a.time_period,
b.order_id,b.items_purchased,b.price_usd,b.cogs_usd from cte2 as a
left join orders as b on a.website_session_id=b.website_session_id
and a.pageview_url='/thank-you-for-your-order'
),

cte4 as (
select time_period,count(distinct website_session_id) as sessions,
count(order_id) as orders,sum(items_purchased) as total_items,avg(price_usd)
as aov,sum(price_usd) as revenue from cte3 group by time_period
)
select *,(orders/sessions*100) as conversion_rate,(total_items/orders) as order_products,
revenue/sessions 
 from cte4;

select * from order_items;
select * from order_item_refunds;
select * from orders;

with cte1 as (
select * from order_items where 
date(created_at)<'2014-10-15'
),

cte2 as (
select
a.order_item_id,a.created_at,a.order_id,a.product_id,b.order_item_refund_id,
b.refund_amount_usd from cte1 as a left join order_item_refunds
as b on a.order_item_id=b.order_item_id
),

cte3 as (
select substr(created_at,1,7) as yr_month,count(*) as p1_orders,
count(order_item_refund_id) as p1_refund_orders from 
cte2 where product_id=1 group by substr(created_at,1,7)
),

cte4 as (
select substr(created_at,1,7) as yr_month,count(*) as p2_orders,
count(order_item_refund_id) as p2_refund_orders from 
cte2 where product_id=2 group by substr(created_at,1,7)
),

cte5 as (
select substr(created_at,1,7) as yr_month,count(*) as p3_orders,
count(order_item_refund_id) as p3_refund_orders from 
cte2 where product_id=3 group by substr(created_at,1,7)
),

cte6 as (
select substr(created_at,1,7) as yr_month,count(*) as p4_orders,
count(order_item_refund_id) as p4_refund_orders from 
cte2 where product_id=4 group by substr(created_at,1,7)
),

cte7 as (


select a.yr_month,a.p1_orders,a.p1_refund_orders,
p2_orders,p2_refund_orders,p3_orders,p3_refund_orders,
p4_orders,p4_refund_orders
from cte3 as a left join cte4 as b 
on a.yr_month=b.yr_month left join cte5 as c
on b.yr_month=c.yr_month left join cte6 as d
on c.yr_month=d.yr_month
)

select yr_month,
p1_refund_orders/p1_orders as p1_refund_rate,
p2_refund_orders/p2_orders as p2_refund_rate,
p3_refund_orders/p3_orders as p3_refund_rate,
p4_refund_orders/p4_orders as p4_refund_Rate from 
cte7;




