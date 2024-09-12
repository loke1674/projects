-- problem statement
-- pulling out monthly trends for gsearch sessions and orders for analyzing 
-- the growth

select * from website_sessions;

with cte1 as (
select a.website_session_id,a.created_at,a.utm_source,b.order_id
from website_sessions as a left join orders as b 
on a.website_session_id=b.website_session_id
),

cte2 as (
select * from cte1 where utm_source='gsearch' 
and created_at<'2012-11-27'
),

cte3 as (
select year(created_at) as yr,month(created_at) as mth,count(order_id) as total_orders,
count(utm_source) as total_sessions
from cte2 group by year(created_at),month(created_at)
),
cte4 as (
select *, case
when mth=1 then 'jan'
when mth=2 then 'feb'
when mth=3 then 'mar'
when mth=4 then 'apr'
when mth=5 then 'may'
when mth=6 then 'jun'
when mth=7 then 'jul'
when mth=8 then 'aug'
when mth=9 then 'sept'
when mth=10 then 'oct'
when mth=11  then 'nov'
else 'dec' end as mth_name from cte3
),

cte5 as (
select concat(yr,'-',mth_name) as year_mth,total_orders,total_sessions
from cte4
)
select * from cte5;

-- splitting up non brand and brand for gserach and measuring the sesssions
-- and orders

with cte1 as (
select a.website_session_id,a.utm_source,a.utm_campaign,
b.order_id from website_sessions as a 
left join orders as b on a.website_session_id=b.website_session_id
where a.created_at<'2012-11-27'
),

cte2 as (
select * from cte1 where utm_source='gsearch' and 
utm_campaign in ('nonbrand','brand')
),
cte3 as (
select utm_source,utm_campaign,count(order_id) as total_orders,
count(*) as total_sessions from cte2 group by utm_source,utm_campaign
),

cte4 as (
select * ,concat(round(total_orders/total_sessions*100,2),'%') as cvr
from cte3
)
 select * from cte4;

-- lets analyze the monthly session and orders for gsearch nonbrand
-- by device type

with cte1 as (
select a.website_session_id,a.created_at,a.utm_source,a.utm_campaign,
a.device_type,b.order_id from website_sessions as a
left join orders as b on a.website_session_id=b.website_session_id
where a.created_at<'2012-11-27'
),
cte2 as (
select * from cte1 where utm_source='gsearch' and utm_campaign='nonbrand'
),

cte3 as (
select substring(created_at,1,7) as yr_month_m,count(order_id) as total_orders_by_mobile,
count(*) as total_sessions_by_mobile from cte2 where device_type='mobile'
group by substring(created_at,1,7)
),

cte4 as (
select substring(created_at,1,7) as yr_month_d,count(order_id) as total_orders_by_desktop,
count(*) as total_sessions_by_desktop from cte2 where device_type='desktop'
group by substring(created_at,1,7)
),

cte5 as (
select a.yr_month_m,
a.total_orders_by_mobile as orders_by_mob,
a.total_sessions_by_mobile as session_by_mob,
b.total_orders_by_desktop as orders_by_desktop,
b.total_sessions_by_desktop as sessions_by_desktop 
from cte3 as a join cte4 as b where
a.yr_month_m=b.yr_month_d
)
select * from cte5;


#analyzing the monthly trends for gsearch channel and other channels


with cte1 as (
select a.website_session_id,a.created_at,a.utm_source,a.utm_campaign,
a.device_type,b.order_id from website_sessions as a
left join orders as b on a.website_session_id=b.website_session_id
where a.created_at<'2012-11-27'
),
cte2 as (
select substr(created_at,1,7) as yr_mth_a,
count(*) as tot_sess_gsearch
from cte1 where utm_source='gsearch' group by substr(created_at,1,7)
),

cte3 as (
select substr(created_at,1,7) as yr_mth_b,
count(*) as tot_sess_none
from cte1 where utm_source is null group by substr(created_at,1,7)
),

cte4 as (
select substr(created_at,1,7) as yr_mth_c,
count(*) as tot_sess_bsearch
from cte1 where utm_source='bsearch' group by substr(created_at,1,7)
),

cte5 as (
select substr(created_at,1,7) as yr_mth_d,
count(*) as tot_sess_social_book
from cte1 where utm_source='socialbook' group by substr(created_at,1,7)
)
select * from cte2 as a join cte3 as b join cte4 as c join cte5  as d;


#session to order rate by month

with cte1 as (
select a.website_session_id,a.created_at,b.order_id 
from website_sessions as a left join orders as b
on a.website_session_id=b.website_session_id
where a.created_at<'2012-11-27'
),
cte2 as (
select substr(created_at,1,7) as yr_month,count(website_session_id) as sessions,
count(order_id) as total_orders from cte1 group by substr(created_at,1,7)
),

cte3 as (
select *,round((total_orders/sessions)*100,2) as conversion_rate
from cte2
)
select * from cte3 order by conversion_rate desc;

/* the conversion rate in the month of october is peak 
and the conversion rate in the month of april is too low
*/

select * from website_sessions;
select * from website_pageviews;







