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
INNER JOIN collegeplaying 
USING(playerid)
INNER JOIN schools
USING(schoolid)
WHERE schoolname ILIKE '%vanderbilt%'
GROUP BY fullname
ORDER BY total_salary DESC;
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
GROUP BY player_position		
						  
