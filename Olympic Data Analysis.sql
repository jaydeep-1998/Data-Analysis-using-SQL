-- CREATE DATABASE olympics;

Use olympics;

CREATE TABLE olympic_history
(
    id          INT,
    name        VARCHAR(255),
    sex         VARCHAR(255),
    age         VARCHAR(255),
    height      VARCHAR(255),
    weight      VARCHAR(255),
    team        VARCHAR(255),
    noc         VARCHAR(255),
    games       VARCHAR(255),
    year        INT,
    season      VARCHAR(255),
    city        VARCHAR(255),
    sport       VARCHAR(255),
    event       VARCHAR(255),
    medal       VARCHAR(255)
);

CREATE TABLE olympic_history_noc
(
    noc         VARCHAR(50),
    region      VARCHAR(50),
    notes       VARCHAR(50)
);

SELECT * FROM olympic_history limit 50;
SELECT * FROM olympic_history_noc;

-- Solving problems using SQL queries

-- 1. How many olympics games have been held?
SELECT COUNT(DISTINCT games) 
FROM olympic_history;

-- 2. List down all Olympics games held so far. 
SELECT games 
FROM olympic_history 
GROUP BY games 
ORDER BY games;

-- 3. Mention the total no of nations who participated in each olympics game?
select games,count(distinct noc)
from olympic_history
group by games
order by games; 

-- 4. Which year saw the highest and lowest no of countries participating in olympics?
SELECT games, COUNT(DISTINCT noc) as total_countries
FROM olympic_history
GROUP BY games
ORDER BY total_countries desc;

SELECT 
  SUM(CASE WHEN a = (SELECT MAX(a) FROM cte_country) THEN year END) AS max_year,
  SUM(CASE WHEN a = (SELECT MIN(a) FROM cte_country) THEN year END) AS min_year
FROM cte_country;

-- 5. Which nation has participated in all of the olympic games?
-- Method 1 
SELECT ohn.region
FROM olympic_history oh
join olympic_history_noc ohn on oh.noc = ohn.noc
GROUP BY ohn.region
HAVING 
    COUNT(DISTINCT CONCAT(games,ohn.region)) = (select count(distinct games) from olympic_history);

-- Method 2
WITH 
temp_cte as (
    SELECT noc,COUNT(DISTINCT CONCAT(noc,games)) as total_participation 
    FROM olympic_history 
    GROUP BY noc
),
temp_cte_2 as (
    select count(distinct games) as total_games 
    from olympic_history
)
SELECT temp_cte.noc, temp_cte.total_participation 
FROM temp_cte, temp_cte_2 
WHERE temp_cte_2.total_games = temp_cte.total_participation;

-- 6. Identify the sport which was played in all summer olympics.

WITH 
  summer_sport AS (
    SELECT games, sport
    FROM olympic_history
    WHERE season = 'Summer'
    GROUP BY games, sport
  ),
  distinct_games_count AS (
    SELECT COUNT(DISTINCT games) as games_count 
    FROM summer_sport
  )
SELECT sport, COUNT(*) AS game_count
FROM summer_sport
GROUP BY sport
HAVING COUNT(DISTINCT games) = (SELECT games_count FROM distinct_games_count);

-- 7. Which Sports were just played only once in the olympics.





-- 8. Fetch the total no of sports played in each olympic games.
select games, count(distinct sport) as total_sport
from olympic_history
group by games
order by total_sport;

-- 9. Fetch oldest athletes to win a gold medal

with cte as(
SELECT name, age, medal
FROM olympic_history
WHERE medal = 'Gold' 
AND age != 'NA')
select * from cte
where age = (select max(age) from cte);

-- 10. Find the Ratio of male and female athletes participated in all olympic games.

select count(sex)
from olympic_history
where sex='M';

select count(sex)
from olympic_history
where sex='F';

SELECT 
	(SELECT COUNT(*) FROM olympic_history WHERE sex='M') / 
	(SELECT COUNT(*) FROM olympic_history WHERE sex='F') as sex_ratio;
    
 -- 11. Fetch the top 5 athletes who have won the most gold medals.  
 
 SELECT 
    name, 
    total_medal
FROM (
    SELECT 
        name, 
        COUNT(medal) as total_medal,  
        DENSE_RANK() OVER (ORDER BY COUNT(medal) DESC) as medal_rank
    FROM 
        olympic_history  
    WHERE 
        medal = 'Gold'
    GROUP BY 
        name
    ) subquery
WHERE 
    medal_rank <= 5;
   
   
   
   
-- using cte
WITH cte AS (
    SELECT 
        name, 
        COUNT(medal) as total_medal
    FROM 
        olympic_history
    WHERE 
        medal = 'Gold'
    GROUP BY 
        name
    ORDER BY 
        total_medal DESC
),
cte2 AS (
    SELECT 
        *,
        DENSE_RANK() OVER (ORDER BY total_medal DESC) as medal_rank
    FROM 
        cte
)
SELECT 
    name, 
    total_medal
FROM 
    cte2
WHERE 
    medal_rank <= 5;


-- 12. Fetch the top 5 athletes who have won the most medals 

WITH cte AS (
    SELECT name, COUNT(medal) as total_medal
    FROM olympic_history
    WHERE medal != 'NA'
    GROUP BY name
    ORDER BY total_medal DESC
),
cte2 AS (
    SELECT *,
        DENSE_RANK() OVER (ORDER BY total_medal DESC) as medal_rank
    FROM cte
)
SELECT 
    name, 
    total_medal
FROM 
    cte2
WHERE 
    medal_rank <= 5;
    
    
-- 13.Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

WITH cte AS (
    SELECT 
        noc, 
        COUNT(medal) as total_medal
    FROM 
        olympic_history
    WHERE 
        medal != 'NA'
    GROUP BY 
        noc
    ORDER BY 
        total_medal DESC
),
cte2 AS (
    SELECT 
        *,
        DENSE_RANK() OVER (ORDER BY total_medal DESC) as medal_rank
    FROM 
        cte
)
SELECT 
    noc, 
    total_medal
FROM 
    cte2
WHERE 
    medal_rank <= 5;

-- 14. List down total gold, silver and bronze medals won by each country

WITH gold_cte AS (
    SELECT noc, COUNT(medal) AS gold_medal
    FROM olympic_history
    WHERE medal = 'Gold'
    GROUP BY noc
),
silver_cte AS (
    SELECT noc, COUNT(medal) AS silver_medal
    FROM olympic_history
    WHERE medal = 'Silver'
    GROUP BY noc
),
bronze_cte AS (
    SELECT noc, COUNT(medal) AS bronze_medal
    FROM olympic_history
    WHERE medal = 'Bronze'
    GROUP BY noc
)
SELECT gc.noc, gold_medal, silver_medal, bronze_medal
FROM gold_cte gc
JOIN silver_cte sc ON sc.noc = gc.noc
JOIN bronze_cte bc ON bc.noc = gc.noc
ORDER BY gold_medal DESC, silver_medal DESC, bronze_medal DESC;



select * from olympic_history; 
	

WITH gold_cte AS (
    SELECT games, noc, COUNT(medal) AS gold_medal
    FROM olympic_history
    WHERE medal = 'Gold'
    GROUP BY games, noc
),
silver_cte AS (
    SELECT games, noc, COUNT(medal) AS silver_medal
    FROM olympic_history
    WHERE medal = 'Silver'
    GROUP BY games, noc
),
bronze_cte AS (
    SELECT games, noc, COUNT(medal) AS bronze_medal
    FROM olympic_history
    WHERE medal = 'Bronze'
    GROUP BY games, noc
)
SELECT gc.games, gc.noc, COALESCE(gold_medal, 0) AS gold_medal, COALESCE(silver_medal, 0) AS silver_medal, COALESCE(bronze_medal, 0) AS bronze_medal
FROM gold_cte gc
LEFT JOIN silver_cte sc ON gc.games = sc.games AND gc.noc = sc.noc
LEFT JOIN bronze_cte bc ON gc.games = bc.games AND gc.noc = bc.noc
ORDER BY gc.games, gc.noc;



SELECT games, noc, COUNT(medal) AS bronze_medal
FROM olympic_history
WHERE medal = 'Bronze'
GROUP BY games, noc
order by games, noc;





