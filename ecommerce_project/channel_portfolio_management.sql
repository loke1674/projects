#compartive analysis of bsearch channel and gsearch channel

with cte1 as (
select * from website_sessions where created_at 
>='2012-08-22' and created_at < '2012-11-29'
),

cte2 as (
select min(date(created_at)) as week_trend,count(*) as gsearch_session
from cte1 where utm_source='gsearch' and utm_campaign='nonbrand'
group by year(created_at),week(created_at)
),

cte3 as (
select min(date(created_at)) as week_trend,count(*) as bsearch_session
from cte1 where utm_source='bsearch' and utm_campaign='nonbrand'
group by year(created_at),week(created_at)
)

select a.week_trend,a.gsearch_session,b.bsearch_session from cte2
 as a join cte3 as b on a.week_trend=b.week_trend;
 
--  analyzing the percentage traffic of bsearch nonbrand on mobile compared
--  to mobile 

with cte1 as (
select * from website_sessions where created_at 
>='2012-08-22' and created_at < '2012-11-30'
and utm_campaign='nonbrand'
),

cte2 as (
select utm_source,count(*) as total_session
from cte1 group by utm_source
),

cte3 as (
select utm_source,count(*) as mobile_session
from cte1 where device_type='mobile'
group by utm_source
),

cte4 as (
select a.utm_source,a.total_session,b.mobile_session from 
cte2 as a join cte3 as b on a.utm_source=b.utm_source
)
select *,(mobile_session/total_session)*100 as pct_mobile
from cte4;

#cross bid optimization analysis

with cte1 as (
select a.website_session_id,a.created_at,a.utm_source,a.utm_campaign,
a.device_type,b.order_id from website_sessions as a left join
orders as b on a.website_session_id=b.website_session_id
),

cte2 as (
select * from cte1 where 
date(created_at) >='2012-08-22' and date(created_at)<='2012-09-18' and 
utm_campaign='nonbrand'
),
cte3 as (
select device_type,utm_source,count(*) as sessions,
count(order_id) as orders from cte2 group by 
device_type,utm_source
)
select *,round((orders/sessions*100),2) as cvr from cte3;

#analyzing the channel portfolio trend

with cte1 as (
select * from website_sessions where
date(created_at)>='2012-11-04' and date(created_at)<'2012-12-22'
and utm_campaign='nonbrand'
),

cte2 as (
select min(date(created_at)) as wk_trend,count(*) as g_mtop_session
from cte1 where utm_source='gsearch' and device_type='mobile'
group by year(date(created_at)),week(date(created_at))
),

cte3 as (
select min(date(created_at)) as wk_trend,count(*) as b_mtop_session
from cte1 where utm_source='bsearch' and device_type='mobile'
group by year(date(created_at)),week(date(created_at))
),

cte4 as (
select min(date(created_at)) as wk_trend,count(*) as g_dtop_session
from cte1 where utm_source='gsearch' and device_type='desktop'
group by year(date(created_at)),week(date(created_at))
),

cte5 as (

select min(date(created_at)) as wk_trend,count(*) as b_dtop_session
from cte1 where utm_source='bsearch' and device_type='desktop'
group by year(date(created_at)),week(date(created_at))
)

select a.wk_trend,a.g_mtop_session,b.b_mtop_session,c.g_dtop_session,
d.b_dtop_session from cte2 as a join cte3 as b join cte4 as c join
cte5 as d on a.wk_trend=b.wk_trend and b.wk_trend=c.wk_trend
and c.wk_trend=d.wk_trend;

#analyzing the business trends weekly and monthly

with cte1 as (
select a.website_session_id,a.created_at,b.order_id from 
website_sessions as a left join orders as b
on a.website_session_id=b.website_session_id
where date(a.created_at)<'2013-01-01'
),
cte2 as (
select substr(created_at,1,7) as mth_trend,count(website_session_id)
as total_sessions,count(order_id) as total_orders
from cte1 group by substr(created_at,1,7)
)
select * from cte2;

with cte1 as (
select a.website_session_id,a.created_at,b.order_id from 
website_sessions as a left join orders as b
on a.website_session_id=b.website_session_id
where date(a.created_at)<'2013-01-01'
),

cte2 as (
select min(date(created_at)) as weektrend,count(website_session_id)
as total_sessions,count(order_id) as total_orders from cte1
group by year(date(created_at)),week(date(created_at))
)
select * from cte2;

#analyzing the average traffic session by hour and day week

with cte1 as (
select website_session_id,created_at,hour(created_at) as hr,
weekday(created_at) as dayweek from website_sessions where
date(created_at) between '2012-09-15' and '2012-11-15'
),

cte2 as (
select hr,count(website_session_id) as monday from 
cte1 where dayweek=0 group by hr order by hr
),

cte3 as (
select hr,count(website_session_id) as tuesday from 
cte1 where dayweek=1 group by hr order by hr
),

cte4 as (
select hr,count(website_session_id) as wednesday from 
cte1 where dayweek=2 group by hr order by hr
),

cte5 as (
select hr,count(website_session_id) as thursday from 
cte1 where dayweek=3 group by hr order by hr
),
cte6 as (
select hr,count(website_session_id) as friday from 
cte1 where dayweek=4 group by hr order by hr
),
cte7 as (
select hr,count(website_session_id) as saturday from 
cte1 where dayweek=5 group by hr order by hr
),

cte8 as (
select hr,count(website_session_id) as sunday from 
cte1 where dayweek=6 group by hr order by hr
)
select a.hr,a.monday,b.tuesday,c.wednesday,d.thursday,
e.friday,f.saturday,g.sunday from cte2 as a
join cte3 as b join cte4 as c join cte5 as d join
cte6 as e join cte7 as f join cte8 as g on 
a.hr=b.hr and b.hr=c.hr and c.hr=d.hr and d.hr=e.hr
and e.hr=f.hr and f.hr=g.hr;


