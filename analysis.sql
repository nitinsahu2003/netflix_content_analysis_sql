-- 15 Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows
SELECT type, COUNT(*) AS no_of_type
FROM netflix
GROUP BY type


--2. Find the most common rating for movies and TV shows
WITH t1 AS(
	SELECT type, rating, COUNT(*) AS no_of_rating
	FROM netflix
	WHERE rating IS NOT NULL
	GROUP BY type, rating
),
t2 AS(
	SELECT *, RANK() OVER(PARTITION BY type ORDER BY no_of_rating DESC) AS rn
	FROM t1
)
SELECT type, rating, no_of_rating
FROM t2
WHERE rn = 1;


--3. List all movies released in a specific year (e.g., 2020)
SELECT title
FROM netflix
WHERE type = 'Movie' AND release_year = 2020;

--4. Find the top 5 countries with the most content on Netflix
SELECT TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country, COUNT(show_id) AS total_shows
FROM netflix
WHERE country IS NOT NULL
GROUP BY 1
ORDER BY total_shows DESC
LIMIT 5;

--5. Identify the longest movie
SELECT title, duration
FROM netflix
WHERE type = 'Movie' AND duration IS NOT NULL
ORDER BY SPLIT_PART(duration, ' ', 1)::INTEGER DESC
LIMIT 1

--6. Find content added in the last 5 years
SELECT *, TO_DATE(date_added, 'Month DD, YYYY') as date_added
FROM netflix
WHERE TO_DATE(date_added, 'Month DD, YYYY') >= DATE'2024-01-01' - INTERVAL '5 years'


--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT type, title
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%'


--8. List all TV shows with more than 5 seasons
SELECT title, SPLIT_PART(duration, ' ', 1) AS seasons
FROM netflix
WHERE type = 'TV Show' AND SPLIT_PART(duration, ' ', 1)::numeric > 5


--9. Count the number of content items in each genre
WITH t1 AS(
	SELECT show_id, UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre
	FROM netflix
)
SELECT genre, COUNT(genre) AS total_content
FROM t1
GROUP BY genre
ORDER BY total_content DESC

--10.Find each year and the average numbers of content release in India on netflix. 
	--return top 5 year with highest avg content release!
WITH t1 AS(
	SELECT EXTRACT(YEAR FROM TO_DATE(date_added, 'MONTH DD, YYYY')) AS year, 
		COUNT(*) AS yearly_content
	FROM netflix
	WHERE country ILIKE '%India%' AND date_added IS NOT NULL
	GROUP BY year
)
SELECT year, 
	yearly_content, 
	ROUND(
		yearly_content * 100 / SUM(yearly_content) OVER(), 2
	) AS avg_content_per_year
FROM t1
ORDER BY yearly_content DESC
LIMIT 5

--11. List all movies that are documentaries
SELECT title
FROM netflix
WHERE type = 'Movie' AND listed_in ILIKE '%Documentaries%'

--12. Find all content without a director
SELECT type, title
FROM netflix
WHERE director IS NULL

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
SELECT title, release_year
FROM netflix
WHERE type = 'Movie' AND cast_members ILIKE '%Salman Khan%' 
		AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10


--14. Find the top 10 actors who have appeared in the highest number 
		--of movies produced in India.
WITH t1 AS(
	SELECT UNNEST(STRING_TO_ARRAY(cast_members, ',')) AS actor
	FROM netflix
	WHERE country = 'India' AND type = 'Movie' AND cast_member IS NOT NULL
)
SELECT actor, COUNT(actors) AS no_of_movies
FROM t1
GROUP BY actor
ORDER BY no_of_movies DESC
LIMIT 10

--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' 
		--in the description field. Label content containing these keywords as 'Bad' 
		--and all other content as 'Good'. Count how many items fall into each category.
WITH t1 AS(
	SELECT title,
		CASE 
			WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad' 
			ELSE 'Good'
		END AS label_content	
	FROM netflix
)
SELECT label_content, COUNT(*) AS total_count
FROM t1
GROUP BY label_content








		