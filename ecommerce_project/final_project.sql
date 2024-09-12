-- situation
-- vp is close to securing the maven fuzzy factory funding as an analyst
-- we have to pull out the relevant data and craft a story about the companys
-- performace over the years


#1.lets pull out the overall session and orders by quarter

with cte1 as (
select website_session_id,created_at,user_id
from website_sessions
),

cte2 as (
select *,year(created_at) as yr,quarter(created_at) as qtr
from cte1
),

cte3 as (
select a.website_session_id,a.created_at,a.user_id,a.yr,a.qtr,
b.order_id from cte2 as a left join orders as b on 
a.website_session_id=b.website_session_id
),

cte4 as (
select yr,qtr,count(website_session_id) as total_sessions,
count(order_id) as total_orders from cte3
group by yr,qtr
)
select * from cte4;

#lets deep dive and measure the order conversion rate,revenue per order
#and revenue per session
with cte1 as (
select website_session_id,created_at,user_id
from website_sessions
),

cte2 as (
select *,year(created_at) as yr,quarter(created_at) as qtr
from cte1
),

cte3 as (
select a.website_session_id,a.created_at,a.user_id,a.yr,a.qtr,
b.order_id,b.price_usd from cte2 as a left join orders as b on 
a.website_session_id=b.website_session_id
),

cte4 as (
select yr,qtr,count(website_session_id) as total_session,
count(order_id) as total_orders,sum(price_usd) as revenue_generated
from cte3 group by yr,qtr
)
select yr,qtr,total_orders/total_session as cvr,revenue_generated/total_orders
as revenue_per_order,revenue_generated/total_session as revenue_per_session
from cte4;

# as you can see the cvr keeps improving over the years and the 
# the revenue generated per order is maximum in the 3rd quarter of 
#2014

select * from orders;

with cte1 as
(
select substr(created_at,1,7) as yr_month,sum(price_usd) as p1_revenue,
sum(price_usd-cogs_usd) as p1_margin  from orders where primary_product_id=1
group by substr(created_at,1,7)
),
cte2 as (
select substr(created_at,1,7) as yr_month,sum(price_usd) as p2_revenue,
sum(price_usd-cogs_usd) as p2_margin  from orders where primary_product_id=2
group by substr(created_at,1,7)
),

cte3 as
(
select substr(created_at,1,7) as yr_month,sum(price_usd) as p3_revenue,
sum(price_usd-cogs_usd) as p3_margin  from orders where primary_product_id=3
group by substr(created_at,1,7)
),

cte4 as (
select substr(created_at,1,7) as yr_month,sum(price_usd) as p4_revenue,
sum(price_usd-cogs_usd) as p4_margin  from orders where primary_product_id=4
group by substr(created_at,1,7)
)

select a.yr_month,a.p1_revenue,a.p1_margin,
b.p2_revenue,b.p2_margin,c.p3_revenue,c.p3_margin,
d.p4_revenue,d.p4_margin
 from cte1 as a
left join cte2 as b 
on a.yr_month=b.yr_month
left join cte3 as c
on b.yr_month=c.yr_month
left join cte4 as d
on c.yr_month=d.yr_month;

#as per the ceo request we have summarized the month wise revenue
#and sales margin for each product

#lets analyze the monthly sessions for product page and next page conversion rate


select * from website_pageviews;

with cte1 as (
select substr(created_at,1,7) as a_yr_month,count(pageview_url) as 
product_session from website_pageviews where pageview_url='/products'
group by substr(created_at,1,7)
),

cte2 as (
select substr(created_at,1,7) as b_yr_month,count(pageview_url) as 
next_session from website_pageviews where pageview_url in 
('/the-original-mr-fuzzy','/the-forever-love-bear','/the-birthday-sugar-panda',
'/the-hudson-river-mini-bear')
group by substr(created_at,1,7)
),

cte3 as (
select a.a_yr_month as yr_month,a.product_session,b.next_session
from cte1 as a join cte2 as b on a.a_yr_month=b.b_yr_month
)
select *,next_session/product_session*100 as percentage_conversion
from cte3;

#percentage conversion from product sessions to next sessions is increasing
#over the years and it is a great sign of improvement

-- based on our analysis that we did so far what i recommend is that
-- we can promote the product birthday sugar and hudson river as it doing well in terms of revenue and conversion rate

-- when it comes to traffic performance gsearch non brand is doing well
-- compared to gsearch brand as people are more focused on a particular brand
-- so try to promote the brand through gsearch and non brand so there is more
-- chance in increasing the overall revenue