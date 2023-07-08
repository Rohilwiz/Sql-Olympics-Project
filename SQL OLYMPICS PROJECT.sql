USE olympics;
SELECT * FROM olympics_ath;
SELECT * FROM olympics_region;



-- 1. How many olympics games have been held?

		select Count(DISTINCT games) as total_olympics_held
		from olympics_ath;


-- 2. List down all Olympics games held so far.

		SELECT DISTINCT year,season,city
		FROM olympics_ath
		order by year;



-- 3. Mention the total no of nations who participated in each olympics game?

		SELECT 
			  games, count(distinct noc) as Total_countries
		FROM   
			  olympics_ath
		   group by games
		   order by games;
   
   
   
   -- 4. Which year saw the highest and lowest no of countries participating in olympics?


		SELECT DISTINCT
			concat(first_value(t.games) over(order by t.total_countries)
			  , ' - '
			  , first_value(t.total_countries) over(order by t.total_countries)) as Lowest_Countries,
			  concat(first_value(t.games) over(order by t.total_countries desc)
			  , ' - '
			  , first_value(t.total_countries) over(order by t.total_countries desc)) as Highest_Countries
		from
		(SELECT  games, count(distinct nr.region) as total_countries
		 from  olympics_ath a
			 JOIN
		  olympics_region nr ON a.noc = nr.noc
		  group by games
		  order by games) as t
		  ;   
  
  
  
  
  -- 5. Which nation has participated in all of the olympic games?

		  select nr.region, count(distinct games) as total_olympics
		  from olympics_ath a 
			JOIN 
			olympics_region nr ON a.noc = nr.noc
			group by nr.region
			having total_olympics >= 51
			order by nr.region;
    
    
    
    
-- 6. Identify the sport which was played in all summer olympics.

/*  As I have counted total count of summer olympics(which is 29) from the query given below
   Select count(distinct games) from olympics_ath
 where games like ('% summer');
             OR
             Select count(distinct games) from olympics_ath
 where season = 'summer';
    ;
  */  
    
		SELECT 
			sport, COUNT(DISTINCT games) AS All_summer_games
		FROM
			olympics_ath
		WHERE
			season = 'Summer'
		GROUP BY sport
		HAVING All_summer_games = 29
		ORDER BY sport ;
     
     --   OR
        
		 SELECT 
			sport, COUNT(DISTINCT games) AS All_summer_games
		FROM
			olympics_ath
		WHERE
			games like ('% summer')
		GROUP BY sport
		HAVING All_summer_games = 29
		ORDER BY sport  ;       


   
-- 7. Which Sports were just played only once in the olympics?
        
 
		SELECT 
			sport, COUNT(DISTINCT games) AS Number_of_games
		FROM
			olympics_ath
		GROUP BY sport
		having Number_of_games = 1
		ORDER BY sport  ;   





-- 8. Fetch the total no of sports played in each olympic games.


		SELECT 
			games, count(distinct sport ) no_of_sports
		FROM
			olympics_ath
			group by games
		ORDER BY  games;





-- 9. Fetch details of the oldest athletes to win a gold medal.

		select *
		from
		(select *, rank() over(order by a.age desc) as rnk 
		from
		(SELECT *
		FROM 
			olympics_ath
		WHERE  medal = 'gold'
		and age<> 'NA'
		) as a) as b

		WHERE rnk = 1
		   ;
   
   
   
   -- 10. Find the Ratio of male and female athletes participated in all olympic games.
   -- Ans:  The ratio is 2.62, Which Shows that for every 5 males there were 2 females, Which is almost 30% of the total athletes.
            
		
        
        
        With MaleCount as ( Select Count(sex) as total_males
							From   olympics_ath
                            WHERE sex = 'M'),
				
			FemaleCount as ( SELECT count(sex) as total_females
								FROM olympics_ath
							   WHERE sex = 'F')
			SELECT total_males/total_females
			FROM   MaleCount
            Join
					FemaleCount;

-- 11. Fetch the top 5 athletes who have won the most gold medals.

		Select b.name, b.team, b.total_medals
		from
		(Select * , dense_rank() over (order by a.total_medals desc) as rnk
		From
		(Select name, team, count(medal) as total_medals
		from olympics_ath
		WHERE medal = 'gold'       
		group by name, team
		order by total_medals desc) as a) b
		where rnk <=5 
		;   



--  12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).


		Select b.name, b.team, b.total_medals
		from
		(Select * , dense_rank() over (order by a.total_medals desc) as rnk
		From
		(Select name, team, count(medal) as total_medals
		from olympics_ath
		WHERE medal <> 'NA'       
		group by name, team
		order by total_medals desc) as a) b
		where rnk <=5 ;   




--   13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

		Select b.region, b.total_medals
		from
		(Select *, rank() over( order by a.total_medals desc) as rnk
		from
		(Select nr.region, Count(a.medal) as total_medals
		from olympics_ath a
		JOIN 
		olympics_region nr ON a.noc = nr.noc
		where medal <> 'NA'
		group by nr.region
		order by total_medals desc) as a ) as b
		WHERE rnk <= 5;





-- 14. List down total gold, silver and broze medals won by each country.

     
     
		SELECT 
		  b.region,
		  COUNT(CASE WHEN b.gold_medals = 1 THEN 1 END) AS total_gold,
		  COUNT(CASE WHEN b.silver_medals = 1 THEN 1 END) AS total_silver,
		  COUNT(CASE WHEN b.bronze_medals = 1 THEN 1 END) AS total_bronze
		FROM (
		  SELECT 
			nr.region,
			CASE WHEN a.medal = 'gold' THEN 1 ELSE 0 END AS gold_medals,
			CASE WHEN a.medal = 'silver' THEN 1 ELSE 0 END AS silver_medals,
			CASE WHEN a.medal = 'bronze' THEN 1 ELSE 0 END AS bronze_medals
		  FROM 
			olympics_ath a 
			JOIN olympics_region nr ON nr.noc = a.noc
		) AS b
		GROUP BY b.region
		HAVING 
			  total_gold > 0
		  AND total_silver > 0
		  AND total_bronze > 0
		ORDER BY total_gold desc, total_silver desc, total_bronze desc;




-- 15. List down total gold, silver and broze medals won by each country corresponding to each olympic games.



		SELECT 
			b.games,
			b.region,
			COUNT(b.gold_medals) AS total_gold,
			COUNT(b.silver_medals) AS total_silver,
			COUNT(b.bronze_medals) AS total_bronze
		FROM
			(SELECT 
				a.games,
					nr.region,
					CASE
						WHEN a.medal = 'gold' THEN 1
					END AS gold_medals,
					CASE
						WHEN a.medal = 'silver' THEN 1
					END AS silver_medals,
					CASE
						WHEN a.medal = 'bronze' THEN 1
					END AS bronze_medals
			FROM
				olympics_ath a
			JOIN olympics_region nr ON nr.noc = a.noc) AS b
		GROUP BY a.games , nr.region
		ORDER BY a.games , nr.region;
       
       
-- 16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.


		WITH temp as (SELECT b.games,
			   b.region,
			   count(b.gold_medals) as total_gold,
			   count(b.silver_medals) as total_silver,
			   count(b.bronze_medals) as total_bronze
		from
		(select a.games, 
			   nr.region, 
			   CASE WHEN a.medal = 'gold' THEN 1  END as gold_medals,
			   CASE WHEN a.medal = 'silver' THEN 1  END as silver_medals,
			   CASE WHEN a.medal = 'bronze' THEN 1  END as bronze_medals
		FROM   olympics_ath a 
			   JOIN
			   olympics_region nr ON nr.noc = a.noc
			   ) as b
			   group by a.games, nr.region
			   order by a.games, nr.region)
			   
		SELECT DISTINCT games,
			  concat(first_value(region) over (partition by games order by total_gold desc), ' - ' ,
			  first_value(total_gold) over (partition by games order by total_gold desc)) as Max_gold,
			  concat(first_value(region) over (partition by games order by total_silver desc), ' - ' ,
			  first_value(total_silver) over (partition by games order by total_silver desc)) as Max_silver,
			  concat(first_value(region) over (partition by games order by total_bronze desc), ' - ' ,
			  first_value(total_bronze) over (partition by games order by total_bronze desc)) as Max_bronze
			  
		FROM temp
		order by games;       




-- 17. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.




		WITH temp as (SELECT b.games,
			   b.region,
			   count(b.gold_medals) as total_gold,
			   count(b.silver_medals) as total_silver,
			   count(b.bronze_medals) as total_bronze
		from
		(select a.games, 
			   nr.region, 
			   CASE WHEN a.medal = 'gold' THEN 1  END as gold_medals,
			   CASE WHEN a.medal = 'silver' THEN 1  END as silver_medals,
			   CASE WHEN a.medal = 'bronze' THEN 1  END as bronze_medals
		FROM   olympics_ath a 
			   JOIN
			   olympics_region nr ON nr.noc = a.noc
			   ) as b
			   group by b.games, b.region
			   order by b.games, b.region)
			   
		SELECT DISTINCT games,
			  concat(first_value(region) over (partition by games order by total_gold desc), ' - ' ,
			  first_value(total_gold) over (partition by games order by total_gold desc)) as Max_gold,
			  concat(first_value(region) over (partition by games order by total_silver desc), ' - ' ,
			  first_value(total_silver) over (partition by games order by total_silver desc)) as Max_silver,
			  concat(first_value(region) over (partition by games order by total_bronze desc), ' - ' ,
			  first_value(total_bronze) over (partition by games order by total_bronze desc)) as Max_bronze,
			  concat( first_value(region) over(partition by games), ' - ' , first_value(total_gold + total_silver + total_bronze) over (partition by games)) as max_medals
			  
		FROM temp
		order by games;       





-- 18. Which countries have never won gold medal but have won silver/bronze medals?


		SELECT 
			b.region,
			b.gold_medals AS total_gold,
			COUNT(b.silver_medals) AS total_silver,
			COUNT(b.bronze_medals) AS total_bronze
		FROM
			(SELECT 
				a.games,
					nr.region,
					CASE
						WHEN a.medal = 'gold' THEN 1
						ELSE 0
					END AS gold_medals,
					CASE
						WHEN a.medal = 'silver' THEN 1
					END AS silver_medals,
					CASE
						WHEN a.medal = 'bronze' THEN 1
					END AS bronze_medals
			FROM
				olympics_ath a
			JOIN olympics_region nr ON nr.noc = a.noc) AS b
		GROUP BY b.region, total_gold
		HAVING total_gold = 0 And COUNT(b.silver_medals) <> 0 OR COUNT(b.bronze_medals) <> 0
		ORDER BY b.region
		;




-- 19. In which Sport/event, India has won highest medals.
    
		   with temp as (select a.sport, a.total_medals, rank() over(order by total_medals desc) as rnk
			from
		   ( SELECT nr.region, b.sport, count(b.medal) as total_medals
			FROM olympics_ath b
				 JOIN
				 olympics_region nr ON nr.noc = b.noc
			where b.medal <> 'NA'
				  and nr.region in("india")
			Group by b.sport) as a)
			SELECT sport, total_medals
			from temp
			where rnk = 1
			;
    
    
    
    
-- 20. Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.
    
  
		  SELECT 
			b.games, nr.region, b.sport, COUNT(b.medal) AS total_medals
		FROM
			olympics_ath b
				JOIN
			olympics_region nr ON nr.noc = b.noc
		WHERE
			b.medal <> 'NA'
				AND nr.region IN ('india')
				AND b.sport IN ('Hockey')
		GROUP BY games
		ORDER BY games;