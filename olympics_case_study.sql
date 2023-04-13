select *
from athlete_events a join noc_regions n on a.noc=n.NOC;

-- #------------Assigment-6---------------------

-- Assuming not all games are Olympics

-- Q1.How many olympics games have been held? 

select count(distinct Year) -- answer 5(distinct) and 120(not distinct), 
from athlete_events -- maybe because only 50,000 out of 200,000 records could be loaded into the table
where event like '%OLYmpic%';

-- Q2.List down all Olympics games held so far.
select distinct games, Year
from athlete_events
where event like '%OLYmpic%'
order by year;

-- Q3.Mention the total no of nations who participated in each olympics game?
select count( distinct team)
from athlete_events 
where event like '%Olympic%'
;

-- Q4.Which year saw the highest and lowest no of countries participating in olympics?

(select cast(year as signed) yr, count(distinct a.noc) nation_cnt
from athlete_events  a join noc_regions n on a.noc=n.noc
where cast(year as signed)>0
group by yr
order by nation_cnt 
limit 1
)
union 
(select cast(year as signed) yr, count(distinct a.noc) nation_cnt
from athlete_events a join noc_regions n on a.noc=n.noc 
where cast(year as signed)>0
group by yr
order by nation_cnt desc 
limit 1)
;



-- Q5.Which nation has participated in all of the olympic games?
select count(distinct games)
from athlete_events a join noc_regions n on a.noc=n.noc
;

select a.noc, count(distinct games)
from athlete_events a join noc_regions n on a.noc=n.noc 
group by noc
having count(distinct games) = ( select count(distinct games)
									from athlete_events a join noc_regions n on a.noc=n.noc)

;



-- Q6.Fetch the top 5 athletes who have won the most gold medals.

select *
from athlete_events a join noc_regions n on a.noc=n.NOC;

select name, count(medal) cnt
from athlete_events
where medal= 'Gold'
group by name, id
order by cnt desc, name
limit 5
;

-- Q7.Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
select name, count( medal) cnt
from athlete_events
where medal not like '%NA%'
group by id
order by cnt desc, name desc;

#using window function t
select name,
	   medal , 
	   count( medal) over(partition by id order by id desc) ttl_medals, 
	   count( medal) over(partition by id, medal order by id desc) ttl_medals_by_types
from athlete_events
where medal not like '%NA%'
order by  ttl_medals desc, ttl_medals_by_types desc, name desc
;


-- Q8.Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
select team, count(medal) cnt
from athlete_events
where medal not like '%na%' 
group by team
order by cnt desc
limit 5
;

-- Q9.List down total gold, silver and broze medals won by each country.
select *
from athlete_events a join noc_regions n on a.noc=n.noc
;
select n.region, 
	   sum(case when medal= 'Gold' then 1 else 0 end) as Gold_medals,
       sum(case when medal= 'Silver' then 1 else 0 end) as Silver_medals,
       sum(case when medal= 'Bronze' then 1 else 0 end) as Bronze_medals	
from athlete_events a join noc_regions n on a.noc=n.noc
-- where medal not like '%na%' -- to not include countries that didn't win any medal(not needed)
group by n.region
order by Gold_medals desc, Silver_medals desc , Bronze_medals desc
;

-- Q10.List down total gold, silver and broze medals won by each country corresponding to each olympic games.
select team, Event,
	   sum(case when medal= 'Gold' then 1 else 0 end) as Gold_medals,
       sum(case when medal= 'Silver' then 1 else 0 end) as Silver_medals,
       sum(case when medal= 'Bronze' then 1 else 0 end) as Bronze_medals	
from athlete_events
where event like '%olympic%' and medal not like '%na%' -- to not include countries that didn't win any medal
group by team, event
order by Gold_medals desc, Silver_medals desc, Bronze_medals desc
;



-- Identify the sport which was played in all summer olympics.


select distinct sport, count( distinct games)
from athlete_events a join noc_regions n on a.noc=n.noc
where season= 'Summer'
group by sport
having count(distinct games) = (select count(distinct games)
						from athlete_events a join noc_regions n on a.noc=n.noc
                        where season= 'Summer'
                        )
;

-- Which Sports were just played only once in the olympics?

select distinct sport, count( distinct games)
from athlete_events a join noc_regions n on a.noc=n.noc
where season= 'Summer'
group by sport
having count(distinct games) = 1 	
;

with cte as
(
select distinct games, 
		n.noc,
        medal,
        count(medal) over(partition by games,n.noc,medal order by medal) cnt
from athlete_events a join noc_regions n on a.noc=n.noc
where medal not like "%na%"
)
,
max_medals as
(
select games, noc, medal, cnt, rnk
from
(
select *,
		dense_rank() over(partition by games, medal order by cnt desc) rnk
from cte
)t
 where rnk =1
-- order by games, noc, rnk
)
select games, 
	   max(case when medal= 'Gold' then concat(noc,'-', cnt) end )as max_gold,
	   max(case when medal= 'Silver' then concat(noc,'-', cnt) end )as max_silver,
       max(case when medal= 'Bronze' then concat(noc,'-', cnt) end )as max_bronze
from max_medals
group by games
;



-- Which countries have never won gold medal but have won silver/bronze medals?


-- In which Sport/event, India has won highest medals.


-- Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.


-- Fetch the total no of sports played in each olympic games.


-- Fetch details of the oldest athletes to win a gold medal.


-- Find the Ratio of male and female athletes participated in all olympic games.


-- Identify which country won the most gold, most silver and most bronze medals in each olympic games.


-- Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
