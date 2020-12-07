SELECT COUNT(DISTINCT(year))
FROM homegames; --QUESTION 1: 1871-2016 TOTAL OF 146 years 



WITH shortest_player AS (SELECT *
						FROM people
						ORDER BY height
						LIMIT 1),
sp_total_games AS (SELECT *
				  FROM shortest_player
				  LEFT JOIN appearances
				  USING(playerid))
SELECT DISTINCT(name), namelast, namefirst, height, g_all AS games_played, sp_total_games.yearid
FROM sp_total_games
LEFT JOIN teams
USING(teamid); --QUESTION 2



WITH top_sal AS (SELECT DISTINCT(sal.yearid), p.namegiven AS first, p.namelast AS last, s.schoolname AS college, sal.salary
	FROM people AS p
	INNER JOIN salaries AS sal
	USING (playerid)
	INNER JOIN collegeplaying AS c
	USING(playerid)
	INNER JOIN schools AS s
	USING (schoolid)
	WHERE schoolname iLIKE '%vanderbilt%'
	ORDER BY salary DESC)
SELECT first, last, college, SUM(salary)::TEXT::MONEY total_sal
FROM top_sal
GROUP BY first,last,college
ORDER BY total_sal DESC; --QUESTION 3



SELECT
	CASE WHEN pos LIKE 'OF' THEN 'Outfield'
		WHEN pos LIKE 'C' THEN 'Battery'
		WHEN pos LIKE 'P' THEN 'Battery'
		ELSE 'Infield' END AS fielding_group,
	SUM(po) AS putouts
FROM fielding
WHERE yearid = 2016
GROUP BY fielding_group
ORDER BY putouts DESC; --QUESTION 4



WITH decades as (	
	SELECT 	generate_series(1920,2010,10) as low_b,
			generate_series(1929,2019,10) as high_b)
			
WITH decades as (	
	SELECT 	generate_series(1920,2010,10) as low_b,
			generate_series(1929,2019,10) as high_b)
			
SELECT 	low_b as decade,
		--SUM(so) as strikeouts,
		--SUM(g)/2 as games,  -- used last 2 lines to check that each step adds correctly
		ROUND(SUM(so::numeric)/(sum(g::numeric)/2),2) as SO_per_game,  -- note divide by 2, since games are played by 2 teams
		ROUND(SUM(hr::numeric)/(sum(g::numeric)/2),2) as hr_per_game
FROM decades LEFT JOIN teams
	ON yearid BETWEEN low_b AND high_b
GROUP BY decade
ORDER BY decade --QUESTION 5



WITH batting AS (SELECT playerid, 
				 SUM(sb) AS stolen_bases, 
				 SUM(cs) AS caught_stealing, 
				 SUM(sb) + SUM(cs) AS total_attempts,
				 yearid AS year
				 FROM batting
				 GROUP BY playerid, yearid)
SELECT DISTINCT(CONCAT(namelast, ',', ' ', namefirst)) AS player_name,
	   SUM(total_attempts) AS total_attempts,
	   SUM(stolen_bases) AS stolen_success,
	   ROUND(SUM(stolen_bases::DECIMAL/total_attempts::DECIMAL)*100, 2) AS success_rate
FROM batting
JOIN people ON batting.playerid = people.playerid
WHERE total_attempts >= 20
	AND total_attempts IS NOT NULL
	AND stolen_bases IS NOT NULL
	AND year = '2016'
GROUP BY people.playerid
ORDER BY success_rate DESC; --QUESTION 6



WITH rank_wins AS (SELECT yearid, teamid, w, RANK() OVER(PARTITION BY yearid ORDER BY w DESC) AS tm_rank, wswin
		FROM teams
		WHERE yearid >= 1970
		AND yearid <= 2016
		AND yearid <> 1981)
SELECT *
FROM rank_wins
WHERE  tm_rank = 1
	AND wswin IS NOT NULL --QUESTION 7



SELECT DISTINCT p.park_name, h.team,
	(h.attendance/h.games) as avg_attendance, t.name		
FROM homegames as h JOIN parks as p ON h.park = p.park
LEFT JOIN teams as t on h.team = t.teamid AND t.yearid = h.year
WHERE year = 2016
AND games >= 10
ORDER BY avg_attendance DESC
LIMIT 5; --QUESTION 8



WITH manager_both AS (SELECT playerid, al.lgid AS al_lg, nl.lgid AS nl_lg,
					  al.yearid AS al_year, nl.yearid AS nl_year,
					  al.awardid AS al_award, nl.awardid AS nl_award
	FROM awardsmanagers AS al INNER JOIN awardsmanagers AS nl
	USING(playerid)
	WHERE al.awardid LIKE 'TSN%'
	AND nl.awardid LIKE 'TSN%'
	AND al.lgid LIKE 'AL'
	AND nl.lgid LIKE 'NL')
SELECT DISTINCT(people.playerid), namefirst, namelast, managers.teamid,
		managers.yearid AS year, managers.lgid
FROM manager_both AS mb LEFT JOIN people USING(playerid)
LEFT JOIN salaries USING(playerid)
LEFT JOIN managers USING(playerid)
WHERE managers.yearid = al_year OR managers.yearid = nl_year; --QUESTION 9



WITH tn_colleges AS (SELECT schoolid,
					schoolname,
					schoolstate
					FROM schools
					WHERE schoolstate = 'TN'
					GROUP BY schoolid)
SELECT DISTINCT schoolname AS college,
	   AVG(salary)::TEXT::NUMERIC::MONEY AS avg_salary
FROM tn_colleges
JOIN collegeplaying ON tn_colleges.schoolid = collegeplaying.schoolid
JOIN people ON collegeplaying.playerid = people.playerid
JOIN salaries ON people.playerid = salaries.playerid
GROUP BY schoolname
ORDER BY avg_salary DESC; --BONUS #1













