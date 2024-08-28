select * from content;

select * from reactions;
select * from content;
select * from reactiontypes;

UPDATE content
SET Category = LOWER(Category);

UPDATE Content
SET Category = REPLACE(Category, '"', '');

alter table content
drop column `URL`;

select `Content ID`,count(*) from
content group by `Content ID`;

with cte1 as (
select a.`Content ID`,a.`User ID`,a.Type as reaction_type,a.DateTime as DT,
b.`User ID` as owner_cont_id from reactions as a join content as b
on a.`Content ID`=b.`Content ID`
),

cte2 as (
select c.`Content ID`,c.`User ID`,c.reaction_type,c.DT,
c.owner_cont_id,d.Type as content_type,d.Category from cte1 as c join content as d
on c.`Content ID`=d.`Content ID`
),

cte3 as (
select e.`Content ID`,e.`User Id`,e.reaction_type,e.DT,e.owner_cont_id,e.content_type,
e.Category,f.Sentiment,f.Score from cte2 as e join reactiontypes as f
on e.reaction_type=f.Type
)
select count(*) from cte3;