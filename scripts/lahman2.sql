--1. What range of years for baseball games played does the provided database cover? 

SELECT MIN(year) AS first_year,
		(SELECT MAX(year) FROM homegames) AS last_year
FROM homegames;
-- 1871-2016

--2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?

SELECT namefirst, namelast, height, teams.name AS team_name, COUNT(g_all) AS games_played 
FROM people 
INNER JOIN appearances
USING(playerid)
INNER JOIN teams
USING(teamid)
GROUP BY namefirst, namelast, height, team_name
ORDER BY height ASC
LIMIT 1;

--3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?


SELECT DISTINCT namefirst ||' '|| namelast AS fullname, SUM(salary) AS total_salary
FROM salaries
INNER JOIN people
USING(playerid)
WHERE playerid IN
				(SELECT playerid
				FROM collegeplaying
				WHERE schoolid = 'vandy')
GROUP BY fullname
ORDER BY total_salary DESC
--david price

--4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

WITH position_grouping AS	
				(SELECT yearid, PO,
					CASE WHEN pos = 'OF' THEN 'Outfield'
						WHEN pos = 'P' OR pos = 'C' THEN 'Battery'
						ELSE 'Infield' END AS player_position
					FROM fielding
					WHERE yearid = '2016') 
SELECT player_position, SUM(PO) AS total_putouts
FROM position_grouping
GROUP BY player_position;		
						  
--5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
WITH baseball_games AS (
    SELECT 
        MAX(g) * COUNT(DISTINCT teamid)/2 AS total_games,  
        SUM(so) AS total_so, 
        CONCAT(FLOOR(yearID/10)*10,'s') AS decade, 
        SUM(hr) AS total_hr
    FROM batting
    WHERE yearid >= 1920
    GROUP BY yearid
) 
SELECT 
    ROUND(SUM(total_so)/SUM(total_games),2) AS so_per_game, 
    ROUND(SUM(total_hr)/SUM(total_games),2) AS hr_per_game, 
    decade
FROM baseball_games
GROUP BY decade;													 


--6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.
SELECT MAX(sb) AS stolen_bases, playerid
FROM batting
WHERE yearid = '2016'
GROUP BY playerid
ORDER BY stolen_bases DESC;


--7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

SELECT number_of_wins, team
FROM
		(SELECT name AS team, w AS number_of_wins
		FROM teams
		WHERE yearid BETWEEN '1970' AND '2016'
		AND wswin = 'N'
		AND yearid <> '1981'
		ORDER BY number_of_wins DESC
		LIMIT 1) AS most_wins_without_ws
		
UNION ALL

SELECT number_of_wins, team
FROM
		(SELECT name AS team, w AS number_of_wins
		FROM teams
		WHERE yearid BETWEEN '1970' AND '2016'
		AND wswin = 'Y'
		AND yearid <> '1981'
		ORDER BY number_of_wins ASC
		LIMIT 1) AS least_wins_with_ws;

--8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.
SELECT avg_attendance, team_name, park_name, attendance 
FROM
		(SELECT (SUM(hg.attendance)/hg.games) AS avg_attendance, t.name AS team_name, p.park_name AS park_name, 'highest_attendance' AS attendance
		FROM homegames AS hg
		LEFT JOIN parks AS p
		ON p.park = hg.park
		INNER JOIN teams AS t
		ON hg.team = t.teamid
		WHERE hg.year = 2016
		GROUP BY team_name, park_name, hg.games
		HAVING games >= 10
		ORDER BY avg_attendance DESC
		LIMIT 5) AS top_five_highest

UNION ALL

SELECT avg_attendance, team_name, park_name, attendance
FROM
		(SELECT (SUM(hg.attendance)/hg.games) AS avg_attendance, t.name AS team_name, p.park_name AS park_name, 'lowest_attendance' AS attendance
		FROM homegames AS hg
		LEFT JOIN parks AS p
		ON p.park = hg.park
		LEFT JOIN teams AS t
		ON hg.team = t.teamid
		WHERE hg.year = 2016
		GROUP BY team_name, park_name, hg.games
		HAVING games >= 10
		ORDER BY avg_attendance ASC
		LIMIT 5) AS top_five_lowest;
--lowest attendance is not correct, still working

