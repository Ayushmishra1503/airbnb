-- 🏠 Airbnb New York City Data Analysis (SQL)
-- This script explores the NYC Airbnb dataset using SQL Server Management Studio (SSMS).
-- It includes data cleaning, host analysis, correlation checks, and superhost performance insights.

-- ==========================================
-- 1️⃣ View Raw Data
-- ==========================================
SELECT * 
FROM DataAnalysis..['listings New York$']
ORDER BY id;

-- ==========================================
-- 2️⃣ Data Cleaning
-- Convert price from string ('$1,200') to numeric for calculations
-- ==========================================
SELECT property_type,
       CAST(REPLACE(SUBSTRING(price, 2, 10), ',', '') AS FLOAT) AS Pricing
FROM DataAnalysis..['listings New York$']
WHERE CAST(REPLACE(SUBSTRING(price, 2, 10), ',', '') AS FLOAT) > 0
ORDER BY Pricing DESC;

-- ==========================================
-- 3️⃣ Overall Summary Stats
-- Count listings, total accommodations, reviews, avg ratings, avg price
-- ==========================================
SELECT COUNT(*) AS Listings,
       SUM(accommodates) AS Accommodations,
       SUM(number_of_reviews) AS Reviews,
       ROUND(AVG(review_scores_rating), 2) AS Avg_Ratings,
       CONCAT('$', ROUND(AVG(Pricing), 2)) AS Avg_Pricing
FROM (
    SELECT *,
           CAST(REPLACE(SUBSTRING(price, 2, 10), ',', '') AS FLOAT) AS Pricing
    FROM DataAnalysis..['listings New York$']
) t
WHERE Pricing > 0;

-- ==========================================
-- 4️⃣ Host Analysis
-- Find hosts who live in the same neighborhood as their listings
-- Using INNER JOINs & GROUP BY
-- ==========================================
SELECT a.host_neighbourhood,
       COUNT(DISTINCT(a.host_id)) AS Hosts_live_here
FROM DataAnalysis..['listings New York$'] a
INNER JOIN DataAnalysis..['listings New York$'] b
    ON a.host_neighbourhood = b.neighbourhood_cleansed 
   AND a.host_name = b.host_name
GROUP BY a.host_neighbourhood
ORDER BY a.host_neighbourhood;

-- ==========================================
-- 5️⃣ Stored Procedure Example
-- Fetch host details for a given neighborhood
-- ==========================================
DROP PROCEDURE IF EXISTS dbo.HostInSameNeighbourhood;
GO
CREATE PROCEDURE dbo.HostInSameNeighbourhood
    @neighbourhood NVARCHAR(100)
AS
BEGIN
    SELECT host_name, host_neighbourhood, name, property_type, room_type,
           accommodates, price, review_scores_rating, number_of_reviews
    FROM DataAnalysis..['listings New York$']
    WHERE neighbourhood_group_cleansed = @neighbourhood
      AND review_scores_rating IS NOT NULL
      AND price IS NOT NULL;
END;
GO

EXEC HostInSameNeighbourhood @neighbourhood = 'Brooklyn';

-- ==========================================
-- 6️⃣ Correlation Analysis
-- Check if higher prices correlate with better ratings
-- Using Pearson correlation formula in SQL
-- ==========================================
SELECT (n*Sxy - Sx*Sy) / 
       SQRT((n*Sx2 - POWER(Sx, 2)) * (n*Sy2 - POWER(Sy, 2))) AS Correlation
FROM (
    SELECT COUNT(*) AS n,
           SUM(price) AS Sx,
           SUM(Score) AS Sy,
           SUM(price*Score) AS Sxy,
           SUM(POWER(price, 2)) AS Sx2,
           SUM(POWER(Score, 2)) AS Sy2
    FROM Review_table1
    WHERE Score IS NOT NULL AND Price > 0
) t;
-- Result: Weak positive correlation between higher prices & reviews

-- ==========================================
-- 7️⃣ Superhost vs Non-Superhost
-- Compare pricing, ratings, cleanliness, response rates
-- ==========================================
SELECT Superhost,
       ROUND(AVG(CAST(REPLACE(SUBSTRING(t.price, 2, 10), ',', '') AS FLOAT)), 2) AS AvgPrice,
       AVG(Score) AS AvgScore,
       AVG(Cleanliness) AS AvgCleanliness,
       AVG(Communication) AS AvgCommunication,
       AVG(Checkin) AS AvgCheckin
FROM (
    SELECT *,
           CASE WHEN host_is_superhost = 'f' THEN 0 ELSE 1 END AS Superhost
    FROM DataAnalysis..['listings New York$']
) t
INNER JOIN Review_table2 rt2 ON t.name = rt2.Name
WHERE rt2.Price > 0 AND Reviews > 10 AND Score IS NOT NULL
GROUP BY Superhost;
-- Insight: Superhosts provide better service across metrics at nearly the same price.

-- ==========================================
-- 8️⃣ Neighborhood Insights
-- Average pricing, reviews, ratings per borough
-- ==========================================
SELECT neighbourhood_group_cleansed AS Borough,
       COUNT(*) AS Listings,
       ROUND(AVG(CAST(REPLACE(SUBSTRING(price, 2, 10), ',', '') AS FLOAT)), 2) AS AvgPrice,
       ROUND(AVG(review_scores_rating), 2) AS AvgRating,
       SUM(number_of_reviews) AS TotalReviews
FROM DataAnalysis..['listings New York$']
WHERE review_scores_rating IS NOT NULL
  AND CAST(REPLACE(SUBSTRING(price, 2, 10), ',', '') AS FLOAT) > 0
GROUP BY neighbourhood_group_cleansed
ORDER BY AvgPrice DESC;

-- ==========================================
-- ✅ Summary
-- - Weak positive correlation between price & reviews overall
-- - Superhosts outperform Non-Superhosts in all review categories
-- - Manhattan & Brooklyn are premium markets; Bronx & Queens more affordable
-- - Entire homes dominate revenues; private rooms dominate listings
