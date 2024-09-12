#analyzing the repeated visitors

select * from order_items;
select * from orders;
select * from website_sessions;

with cte1 as  (
select user_id,count(distinct website_session_id) as total_sessions
from website_sessions where
date(created_at) >='2014-01-01' 
and date(created_at) <'2014-11-01'
group by user_id
),

cte2 as (
select *,
case when total_sessions=1 then 0
when total_sessions=2 then 1
when total_sessions=3 then 2
else 3 end as repeated_sessions
from cte1
)
select repeated_sessions,count(user_id) as total_users
from cte2 group by repeated_sessions;

#analyzing the maximum minimum and average time between 1st and 2nd session

select * from website_sessions;

with cte1 as (
select * from website_sessions
where date(created_at)>='2014-01-01'
and date(created_at)<'2014-11-03'
),

cte2 as (
select user_id,created_at,lag(created_at) over(partition by user_id
order by created_at) as lagg from cte1
),

cte3 as (
select *,datediff(created_at,lagg) as no_of_days 
from cte2
),

cte4 as (
select *,rank() over(partition by user_id order by created_at) as rnk
from cte3
)
select max(no_of_days) as max_days,min(no_of_days) as min_days,
avg(no_of_days) as average_no_of_days from cte4 where rnk=2;

#analyzing new and repeated sessions for each channel type 
select * from website_sessions;

with cte1 as (
select utm_source,utm_campaign,http_referer,
count(is_repeat_session) as new_session
from website_sessions where
is_repeat_session=0 and 
date(created_at)>='2014-01-01'
and date(created_at)<'2014-11-05'
group by utm_source,utm_campaign,http_referer
)
select * from cte1;

#lets analyze the conversion rates and revenue generated per session
# for repeated sessions and non repeated
#sessions

with cte1 as (
select a.website_session_id,a.created_at,a.user_id,a.is_repeat_session,
b.order_id,b.price_usd from website_sessions as a left join orders as b
on a.website_session_id=b.website_session_id 
where date(a.created_at)>='2014-01-01'
and date(a.created_at)<'2014-11-05'
),

cte2 as (
select is_repeat_session,count(website_session_id) as total_session,
count(order_id) as total_orders,sum(price_usd) as revenue
 from cte1 group by is_repeat_session
)
select *,total_orders/total_session as cvr,revenue/total_session
as rev_per_session from cte2;

#so the revenue is generated more in the repeated session than new session
#so 
