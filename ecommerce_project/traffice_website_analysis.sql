select * from order_item_refunds;
select * from order_items;
select * from orders;
select * from products;
select * from website_pageviews;
select * from website_sessions;

/*lets calculate the session to order conversion rate
for each utm content */

with cte1 as (
select a.website_session_id,a.utm_content,b.order_id
from website_sessions as a left join orders as b
on a.website_session_id=b.website_session_id
),

cte2 as (
select utm_content,count(website_session_id) as session_count,
count(order_id) as order_count from cte1
group by utm_content
),

cte3 as (
select *,concat(round((order_count/session_count)*100,2),"%")
as session_to_order_rate from cte2
)
select * from cte3;

/*from the sql query we can see that b_ad_2 has the 
highest session_to_order_rate with approxiamelty 9%
compared to other utm_content */

#finding top 5 traffic sources

with cte1 as (
select utm_source,utm_campaign,http_referer,count(*) as session
from website_sessions where created_at<'2012-04-12'  group by utm_source,utm_campaign,http_referer
)
select * from cte1 order by session desc limit 5;

/*we can understand that gsearch with
nonbrand campaign has the highest session compared to other
utmsource and campaign which means that the team needs to 
focus more to optimize the traffic source */

#calculating the traffic conversion rates
with cte1 as (
select * from website_sessions where created_at<'2012-04-14'
and utm_source='gsearch' and utm_campaign='nonbrand'
),

cte2 as (
select a.website_session_id,b.order_id from cte1
as a left join orders as b on a.website_session_id=b.website_session_id
),

cte3 as(
select count(website_session_id) as sessions,count(order_id) as orders
from cte2
)
select *,round((orders/sessions*100),2) as sess_to_order_rate
from cte3;

/*as you can see for gsearch and nonbrand the conversion
rate is 2.8% wich is quite low which means the marketing
team should reduce the bit */

/*let's create a pivot table for each primary product and
- of people bought 1 items and 2 items during their purchase */

with cte1 as (
select primary_product_id as ppid1,count(items_purchased) as w_1_items
from orders where items_purchased=1 group by primary_product_id
),

cte2 as (
select primary_product_id as ppid2,count(items_purchased) as w_2_items
from orders where items_purchased=2 group by primary_product_id
),

cte3 as (
select a.ppid1,a.w_1_items,b.ppid2,b.w_2_items
from cte1 as a join cte2 as b where a.ppid1=b.ppid2
),
cte4 as (
select ppid1 as primary_product_id,w_1_items,w_2_items
 from cte3
 )
 select *,(w_1_items+w_2_items) as total_orders from cte4;
 
 #traffic source trending by weeks 
 
with cte1 as (
select * from website_sessions
where created_at <'2012-05-12'
and utm_source='gsearch'
and utm_campaign='nonbrand'
),

cte2 as (
select min(date(created_at)) as wk,count(*) as total_session
from cte1 group by year(created_at),week(created_at)
)
select * from cte2;

/*more people used the session 
from 1st april to 7th april compared to other dates */

#conversion rates from sessions-orders by devices

with cte1 as (
select a.website_session_id,a.device_type,b.order_id
from website_sessions as a left join orders as b
on a.website_session_id=b.website_session_id
where date(a.created_at)<'2012-05-11' and
a.utm_source='gsearch' 
and a.utm_campaign='nonbrand'

),
cte2 as (
select device_type,count(website_session_id) as sessions,
count(order_id) as orders from cte1 
group by device_type
)
select *,(orders/sessions) as session_order_rate
from cte2;

/*the conversion rate for desktop is 3%
and mobile is 0.9% which is quite low  */

#weekly trending granular segment analysis

with cte1 as (
select * from website_sessions
where date(created_at)<'2012-06-09'
and utm_source='gsearch' 
and utm_campaign='nonbrand'
),

cte2 as (
select min(date(created_at)) as week_trend_a,count(*) as 
dtop_sessions from cte1 where device_type='desktop'
group by year(created_at),week(created_at)
),
cte3 as (
select min(date(created_at)) as week_trend_b,
count(*) as mob_sessions from cte1 where device_type='mobile'
group by year(created_at),week(created_at)
),
cte4 as (
select a.week_trend_a as week_trend,a.dtop_sessions,
b.mob_sessions from cte2 as a join cte3 as b on
a.week_trend_a=b.week_trend_b 
)
select * from cte4 where week_trend>='2012-04-15';

/* dtop sessions is doing well
in all the weeks compared to mobile sessions */

/* webpage performance analysis */

#finding top website pages


with cte1 as (
select pageview_url,count(*) as total_sessions
from website_pageviews where date(created_at)<'2012-06-09'
group by pageview_url

)
select * from cte1 order by total_sessions desc;

/*home url has the most visited page among users */

with cte1 as (
select pageview_url,count(*)  as total_page_views
from website_pageviews where created_at<'2012-06-12'
group by pageview_url
order by count(*) desc limit 1
)
select * from cte1;

/*homepage url has the highest pageviews */


#measuring the bouncing rates
with cte1 as (
select * from website_pageviews where 
created_at<'2012-06-14'
),
cte2 as (
select website_session_id,count(*) as total_session
from cte1 group by website_session_id
),

cte3 as (
select count(total_session) as total_sessions
from cte2
),

cte4 as (
select sum(
case when total_session=1 then 1
else 0 end
) as bounced_sessions
from cte2
),
cte5 as (

select a.total_sessions,b.bounced_sessions from cte3 as a
join cte4 as b
)
select *,(bounced_sessions/total_sessions) as bounced_rate
from cte5;

/*the bounce rate is 59% which is bad */

/*lets analyze the bounce rate analysis for landing page and homepage
from which the landing page was getting traffic */

-- measure the bounce rate for gseach non brand
-- from the lander page was started before july 28 2012

with cte1 as (
select a.website_pageview_id,a.created_at,a.website_session_id,
a.pageview_url,b.utm_source,b.utm_campaign from website_pageviews
as a join website_sessions as b on a.website_session_id=b.website_session_id
),

cte2 as (
select * from cte1 where utm_source='gsearch'
and utm_campaign='nonbrand'
),

cte3 as (
select * from cte2 where 
created_at<'2012-07-28'
),

cte4 as (
select * from cte3 where 
created_at>'2012-06-19 00:35:54'
),

cte5 as (
select website_session_id,pageview_url,count(*) over(partition by website_session_id) as cnt
from cte4
),

cte6 as (
select * from cte5 where pageview_url in ('/home','/lander-1')
),

cte7 as (
select pageview_url,count(*) as total_session,
sum(
case when cnt=1 then 1
else 0 end ) as bounced_session
from cte6 group by pageview_url
)
select *,(bounced_session/total_session) as bounced_rate
from cte7;

/*so bouncing rate for home page is 58% where as the bouncing 
rate for landing page is 53% which is quite low compared to the home 
page */

-- lets analyze the conversion funnel analysis of user from 1 page all
-- the way to the thank you page

with cte1 as (
select a.website_pageview_id,a.created_at,a.website_session_id,
a.pageview_url,b.utm_source,b.utm_campaign from website_pageviews
as a join website_sessions as b on a.website_session_id=b.website_session_id
),

cte2 as (
select * from cte1 where utm_source='gsearch'
and utm_campaign='nonbrand' and created_at between
'2012-08-05' and '2012-09-04'
),

cte3 as (
select * from cte2 where pageview_url in 
('/lander-1','/products','/the-original-mr-fuzzy',
'/cart','/shipping','/billing','/thank-you-for-your-order'
)
),

cte4 as (
select sum(case when pageview_url='/lander-1' then 1 else 0 end ) as total_sessions,
sum(case when pageview_url='/products' then 1 else 0 end) as to_products,
sum(case when pageview_url='/the-original-mr-fuzzy' then 1 else 0 end) as to_fuzzy,
sum(case when pageview_url='/cart' then 1 else 0 end ) as to_cart,
sum(case when pageview_url='/shipping' then 1 else 0 end ) as to_shipp,
sum(case when pageview_url='/billing' then 1 else 0 end ) as to_bill,
sum(case when pageview_url='/thank-you-for-your-order' then 1 else 0 end) as to_thank
from cte3
),
cte5 as (
select concat(round(to_products/total_sessions*100,2),"%") as product_cvr,
concat(round(to_fuzzy/to_products*100,2),"%") as fuzzy_cvr,
concat(round(to_cart/to_fuzzy*100),"%") as cart_cvr,
concat(round(to_shipp/to_cart*100),"%") as shipp_cvr,
concat(round(to_bill/to_shipp*100),"%") as bill_cvr,
concat(round(to_thank/to_bill*100),"%") as thank_cvr
from cte4
)
select * from cte5;

/* the conversion funnel rate percentage from session to products is 
47% and product to fuzzy is 75% and to cart is 43% and to ship is 
66% and to bill is 80% and to thank is 44% so from this we can 
infer the drop is huge in cart where most of the people stops to 
proceed from fuzzy to cart */

/*based on the above results the website manager has altered the billing 
section so they asked to test the normal billing section billing and
updated one billing 2 to see which session has the most conversion to orders
*/  
#so lets calculate the session to order rate for each billing segment

with cte1 as (
select a.created_at,a.website_session_id,a.pageview_url,b.order_id
from website_pageviews as a left join orders as b on 
a.website_session_id=b.website_session_id 
where a.created_at<'2012-11-10'
),

cte2 as (
select * from cte1 where pageview_url in ('/billing','/billing-2')
and website_session_id >=25325
),
cte3 as (
select pageview_url,count(*) as total_session,count(order_id) as order_session
from cte2 group by pageview_url
)
select *,round(order_session/total_session*100,2) as orate
from cte3;

/* session rate to order rate for billing 2 is 62% whereas 
for billing is 45% there is a significant imporovement in the order 
rate for billing section 2 */











