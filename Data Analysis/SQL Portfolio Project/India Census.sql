SELECT * from [dbo].[Data2]
SELECT * from [dbo].[Data1]

-- Number of rows in our Datasets
SELECT COUNT(*) FROM [dbo].[Data1]
SELECT COUNT(*) FROM [dbo].[Data2]

-- Dataset for Jharkhand and Bihar
SELECT * FROM [dbo].[Data1]
WHERE STATE IN ('Jharkhand', 'Bihar')

-- Population of India
SELECT SUM(Population) AS TOTAL_POPULATION 
FROM [dbo].[Data2]

-- Avg Growth
SELECT State ,AVG(Growth)*100 AS Average_Growth 
FROM [dbo].[Data1]
GROUP BY State 

-- Avg Sex Ratio
SELECT State ,ROUND(AVG(Sex_Ratio),0) AS Average_Sex_Ratio
FROM [dbo].[Data1]
GROUP BY State 
ORDER BY Average_Sex_Ratio DESC

-- Avg Literacy Rate
SELECT State ,ROUND(AVG(Literacy),0) AS Average_Literacy_Rate
FROM [dbo].[Data1]
GROUP BY State 
HAVING ROUND(AVG(Literacy),0) > 90
ORDER BY Average_Literacy_Rate DESC

-- Top 3 States showing Highest Growth Ratio
SELECT TOP 3 State ,AVG(Growth)*100 AS Average_Growth 
FROM [dbo].[Data1]
GROUP BY State 
ORDER BY Average_Growth DESC 

-- Bottom 3 States showing Lowest Sex Ratio
SELECT TOP 3 State ,ROUND(AVG(Sex_Ratio),0) AS Average_Sex_Ratio
FROM [dbo].[Data1]
GROUP BY State 
ORDER BY Average_Sex_Ratio 

-- Top and Bottom 3 states in literacy rate

DROP TABLE IF EXISTS #TopStates; -- Here We created a temporary table for top 3 states
CREATE TABLE #TopStates
(	state nvarchar(255),
	topstate float

)

INSERT INTO #TopStates
SELECT State ,ROUND(AVG(Literacy),0) AS Average_Literacy_Ratio
FROM [dbo].[Data1]
GROUP BY State 
ORDER BY Average_Literacy_Ratio DESC

SELECT Top 3 * FROM #TopStates ORDER BY #TopStates.topstate DESC


DROP TABLE IF EXISTS #BottomStates; -- Here We created a temporary table bottom 3 states
CREATE TABLE #BottomStates
(	state nvarchar(255),
	bottomstate float

)

INSERT INTO #BottomStates
SELECT State ,ROUND(AVG(Literacy),0) AS Average_Literacy_Ratio
FROM [dbo].[Data1]
GROUP BY State 
ORDER BY Average_Literacy_Ratio DESC

SELECT Top 3 * FROM #BottomStates ORDER BY #BottomStates.bottomstate ASC


-- Joining both the temporary tables to get the result
-- Union Operator

SELECT * FROM (
SELECT Top 3 * FROM #TopStates ORDER BY #TopStates.topstate DESC) AS A

UNION

SELECT * FROM (SELECT Top 3 * FROM #BottomStates ORDER BY #BottomStates.bottomstate ASC) AS B

-- Filter out the states starting with letter a

SELECT DISTINCT State 
FROM [dbo].[Data1] 
WHERE LOWER(State) LIKE 'a%' OR LOWER(State) LIKE 'b%'

SELECT DISTINCT State 
FROM [dbo].[Data1] 
WHERE LOWER(State) LIKE 'a%' AND LOWER(State) LIKE '%m'


-- Total Males and Females

-- If we run query from here Output will be the State Level Data 
SELECT d.State, SUM(d.Males) AS Total_Males, SUM(d.Females) AS Total_Females 
FROM

-- If we run query from here Output will be the District Level Data 
(SELECT c.District, c.State, ROUND(c.Population/(c.Sex_Ratio+1),0) AS Males, ROUND((c.Population * c.Sex_Ratio)/(c.Sex_Ratio+1),0) AS Females 
 FROM 

-- Joining both the Actual Tables
(SELECT a.District, a.State, a.Sex_Ratio/1000 AS Sex_Ratio, b.Population
 FROM [dbo].[Data1] AS a 
 INNER JOIN
 [dbo].[Data2] AS b ON a.District = b.District) AS c) AS d
GROUP BY d.State


-- Total Literacy Rate
 
-- If we run query from here Output will be the State Level Data 
SELECT c.State,SUM(Literate_People) Total_Literate_People,sum(Illiterate_People) Total_Illiterate_People 
FROM 

-- If we run query from here Output will be the District Level Data 
(SELECT d.District, d.State, ROUND(d.Literacy_Ratio * d.Population,0) AS Literate_People, ROUND((1-d.Literacy_Ratio)* d.Population,0) AS Illiterate_People 
 FROM

-- Joining both the Actual Tables
(SELECT a.District, a.State, a.Literacy/100 AS Literacy_Ratio, b.Population
 FROM [dbo].[Data1] AS a 
 INNER JOIN
 [dbo].[Data2] AS b ON a.District = b.District) AS d ) AS c
GROUP BY c.State


-- Population in previous census vs current census

-- If we run query from here Output will be the Country's Data
SELECT SUM(m.Previous_Census_Population) AS Previous_Census_Population, SUM(m.Current_Census_Population) AS Current_Census_Population 
FROM

-- If we run query from here Output will be the State Level Data 
(SELECT e.State, SUM(e.Previous_Census_Population) AS Previous_Census_Population, SUM(e.Current_Census_Population) AS Current_Census_Population 
FROM

-- If we run query from here Output will be the District Level Data
(SELECT d.District, d.State, ROUND(d.Population/(1 + d.Growth), 0) AS Previous_Census_Population, d.Population AS Current_Census_Population 
FROM

-- Joining both the Actual Tables
(SELECT a.District, a.State, a.Growth AS Growth, b.Population
 FROM [dbo].[Data1] AS a 
 INNER JOIN
 [dbo].[Data2] AS b ON a.District = b.District) AS d) AS e
 GROUP BY e.State) AS m



-- Population vs Area

SELECT (g.Total_Area/g.Previous_Census_Population) AS Previous_Census_Population_vs_Area, (g.Total_Area/g.Current_Census_Population) AS Current_Census_Population_vs_Area 
FROM

-- Creating connection between Population and area table so by creating a common key in both tables
(SELECT q.*,r.Total_Area 
FROM (

SELECT '1' AS Keyy,n.* FROM

(SELECT SUM(m.Previous_Census_Population) AS Previous_Census_Population, SUM(m.Current_Census_Population) AS Current_Census_Population 
FROM

-- If we run query from here Output will be the State Level Data 
(SELECT e.State, SUM(e.Previous_Census_Population) AS Previous_Census_Population, SUM(e.Current_Census_Population) AS Current_Census_Population 
FROM

-- If we run query from here Output will be the District Level Data
(SELECT d.District, d.State, ROUND(d.Population/(1 + d.Growth), 0) AS Previous_Census_Population, d.Population AS Current_Census_Population 
FROM

-- Joining both the Actual Tables
(SELECT a.District, a.State, a.Growth AS Growth, b.Population
 FROM [dbo].[Data1] AS a 
 INNER JOIN
 [dbo].[Data2] AS b ON a.District = b.District) AS d) AS e
 GROUP BY e.State) AS m) AS n ) AS q
 INNER JOIN (
SELECT '1' AS Keyy,z.* 
FROM

-- Getting total area
(SELECT SUM(area_km2) AS Total_Area 
FROM [dbo].[Data2]) AS z ) AS r 
ON q.Keyy = r.keyy) AS g

--window 

-- output top 3 districts from each state with highest literacy rate

SELECT a.* 
FROM
(SELECT District,State,Literacy,RANK() OVER(PARTITION BY State ORDER BY Literacy DESC) AS rnk FROM [dbo].[Data1]) a

WHERE a.rnk IN (1,2,3) ORDER BY State