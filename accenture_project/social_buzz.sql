/*first thing i did was i downloaded the necesssary data sets and then looked each data
set in each of the data set the first column is'nt necessary so i removed from the 
csv file itself then i created a databases then i loaded the three necessary
csv files into this particular databases */

select * from content;
select * from reactions;
select * from reactiontypes;

/* after loading the datasets i found that reaction table has missing values
so im going to remove those values */

delete from reactions
where `User ID`='' or `Type`='';


/* so we have deleted the rows which has missing values */

with cte1 as (

select a.`Content ID`,a.`Type` as reaction_type ,b.`Type` as content_type from reactions
as a join content as b on a.`Content ID`=b.`Content ID`
),

cte2 as (
select c.`Content ID`,c.reaction_type,c.content_type,d.`Category` 
from cte1 as c inner join content as d on c.`Content ID`=d.`Content ID`
),

cte3 as (
select e.`Content ID`,e.reaction_type,e.content_type,e.`Category`,f.`Score`
from cte2 as e inner join reactiontypes as f on e.reaction_type=f.`Type`
),

cte4 as (
select `Category`,sum(`Score`) as popularity_score from 
cte3 group by `Category`
)
select * from cte4 order by popularity_score desc limit 5;

# from the analysis top 5 categoris are Animals,science,healty eating,technology,food

