-- Netflix Data Analysis using SQL
-- Solutions to 15 business problems

-- 1. Count the number of Movies vs TV Shows
SELECT 
    type, 
    COUNT(*) AS total_count
FROM netflix
GROUP BY type;

-- 2. Find the most common rating for movies and TV shows
WITH RatingSummary AS (
    SELECT 
        type, 
        rating, 
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
Ranked AS (
    SELECT 
        type, 
        rating, 
        rating_count, 
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS ranking
    FROM RatingSummary
)
SELECT 
    type, 
    rating AS most_common_rating
FROM Ranked
WHERE ranking = 1;

-- 3. List all movies released in a specific year (e.g., 2020)
SELECT *
FROM netflix
WHERE release_year = 2020;

-- 4. Find the top 5 countries with the most content on Netflix
SELECT country, COUNT(*) AS content_count
FROM (
    SELECT UNNEST(STRING_TO_ARRAY(country, ',')) AS country
    FROM netflix
) AS country_split
WHERE country IS NOT NULL
GROUP BY country
ORDER BY content_count DESC
LIMIT 5;

-- 5. Identify the longest movie
SELECT *
FROM netflix
WHERE type = 'Movie'
ORDER BY CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) DESC;

-- 6. Find content added in the last 5 years
SELECT *
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'
SELECT *
FROM (
    SELECT *, UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
    FROM netflix
) AS directors_list
WHERE director_name = 'Rajiv Chilaka';

-- 8. List all TV shows with more than 5 seasons
SELECT *
FROM netflix
WHERE type = 'TV Show' 
AND CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) > 5;

-- 9. Count the number of content items in each genre
SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre, 
    COUNT(*) AS total_content
FROM netflix
GROUP BY genre;

-- 10. Find each year and the average number of content releases by India on Netflix.
-- Return the top 5 years with the highest average content release.
SELECT 
    country, 
    release_year, 
    COUNT(show_id) AS total_releases, 
    ROUND(
        COUNT(show_id)::NUMERIC / 
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India') * 100, 
        2
    ) AS avg_release_percentage
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release_percentage DESC
LIMIT 5;

-- 11. List all movies that are documentaries
SELECT *
FROM netflix
WHERE listed_in LIKE '%Documentaries%';

-- 12. Find all content without a director
SELECT *
FROM netflix
WHERE director IS NULL;

-- 13. Find how many movies actor 'Salman Khan' appeared in during the last 10 years
SELECT *
FROM netflix
WHERE casts LIKE '%Salman Khan%'
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor, 
    COUNT(*) AS movie_count
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY movie_count DESC
LIMIT 10;

-- 15. Categorize content based on the presence of keywords 'kill' and 'violence' in descriptions.
-- Label 'Bad' if keywords are present, otherwise label 'Good'.
SELECT 
    category,
    type,
    COUNT(*) AS content_count
FROM (
    SELECT 
        *,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS content_categorized
GROUP BY category, type
ORDER BY type;

-- End of reports
