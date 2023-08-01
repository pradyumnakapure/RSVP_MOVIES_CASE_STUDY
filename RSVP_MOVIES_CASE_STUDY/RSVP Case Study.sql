USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:




-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:

SELECT COUNT(*) AS rows_director_mapping FROM director_mapping ;
SELECT COUNT(*) AS rows_genre FROM genre ;
SELECT COUNT(*) AS rows_movies FROM movie ;
SELECT COUNT(*) AS rows_names FROM names ;
SELECT COUNT(*) AS rows_ratings FROM ratings;
SELECT COUNT(*) AS rows_role_mapping FROM role_mapping ;






-- Q2. Which columns in the movie table have null values?
-- Type your code below:

SELECT -- For each column if the value in the row is a NULL then we put a 1 else a 0 and then take a sum to find total NULLs
	SUM( CASE WHEN id IS NULL THEN 1 ELSE 0 END ) AS id_nulls,
    SUM( CASE WHEN title IS NULL THEN 1 ELSE 0 END ) AS title_nulls,
    SUM( CASE WHEN year IS NULL THEN 1 ELSE 0 END ) AS year_nulls,
    SUM( CASE WHEN date_published IS NULL THEN 1 ELSE 0 END ) AS date_published_nulls,
    SUM( CASE WHEN duration IS NULL THEN 1 ELSE 0 END ) AS duration_nulls,
    SUM( CASE WHEN country IS NULL THEN 1 ELSE 0 END ) AS country_nulls,
    SUM( CASE WHEN worlwide_gross_income IS NULL THEN 1 ELSE 0 END ) AS worldwide_gross_income_nulls,
    SUM( CASE WHEN languages IS NULL THEN 1 ELSE 0 END ) AS languages_nulls,
    SUM( CASE WHEN production_company IS NULL THEN 1 ELSE 0 END ) AS production_company_nulls
 FROM movie;






-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:


+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

-- Order by year
SELECT 
    year, COUNT(id) AS number_of_movies
FROM
    movie
GROUP BY year
ORDER BY year ASC;

-- Order by month
SELECT 
    MONTH(date_published) AS month_num,
    COUNT(id) AS number_of_movies
FROM
    movie
GROUP BY MONTH(date_published)
ORDER BY MONTH(date_published) ASC;








/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

SELECT 
    COUNT(id) AS number_of_movies_2019, year
FROM
    movie
WHERE
    (country LIKE '%USA%'
        OR country LIKE '%India%') AND year = 2019;

 -- USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.





/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

SELECT DISTINCT(genre) from genre;






/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

SELECT
		g.genre, COUNT(m.id) AS number_of_movies -- Counting number of movies in each genre
FROM genre g
INNER JOIN movie m
		ON g.movie_id = m.id
GROUP BY genre
ORDER BY COUNT(id) DESC
LIMIT 1;







/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:

WITH only_1_genre AS -- Opening a CTE to group movies by their number of genres and find fnd movies with only one genre
(
SELECT movie_id, COUNT(genre) from genre
GROUP BY movie_id
HAVING count(genre)=1 -- Filtering movies belonging to only one genre
)
 SELECT 
    COUNT(m.id) AS number_of_movies_with_only_1_genre
FROM
    movie m
        INNER JOIN -- Joining movie table with CTE
    only_1_genre g ON m.id = g.movie_id;

-- 3289 movies belong to only one genre

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant.
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT 
    genre, ROUND(AVG(duration), 2) AS avg_duration
FROM
    movie AS m
        INNER JOIN
    genre AS g ON g.movie_id = m.id
GROUP BY genre
ORDER BY avg_duration DESC;







/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:


WITH gen_rank AS -- Opening a CTE to group by genres and number of movies in it and rank based on number of movies
(
 SELECT 
    genre,
    COUNT(m.id) AS movie_count, 
    RANK() OVER( ORDER BY COUNT(m.id) DESC ) AS genre_rank
FROM
    movie m
        INNER JOIN -- Joining movie table with genre table
    genre g ON m.id = g.movie_id
GROUP BY genre
)
SELECT * FROM gen_rank
WHERE genre='Thriller'; -- Filtering for Thriller genre to find its rank








/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/




-- Segment 2:




-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:


SELECT 
    MIN(avg_rating),
    MAX(avg_rating),
    MIN(total_votes),
    MAX(total_votes),
    MIN(median_rating),
    MAX(median_rating)
FROM
    ratings;



    

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too

WITH movie_rankings as -- CTE to get average ratings of movies and ranks
(
	SELECT m.title, r.avg_rating,  DENSE_RANK() OVER(ORDER BY avg_rating DESC) as movie_rank
	FROM ratings r
	INNER JOIN movie m
	ON r.movie_id = m.id
)
SELECT * FROM movie_rankings -- Getting all columns from the CTE
WHERE movie_rank<=10;






/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

SELECT 
    median_rating, COUNT(movie_id) AS movie_count -- Finding number of movies in each median rating by grouping by median rating
FROM
    ratings
GROUP BY median_rating
ORDER BY median_rating ASC;







/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:

WITH prod_rank AS -- Opening a CTE to find Production companies and number of movies done and ranking them
(
SELECT 
	m.production_company, -- Name of production company
    COUNT(m.id), -- Counting number of movies
    DENSE_RANK() OVER(ORDER BY COUNT(m.id) DESC) AS prod_company_rank -- Ranking based on number of movies and ordering in descending
FROM movie m
INNER JOIN ratings r -- Joining ratings table with movies table
ON m.id = r.movie_id
WHERE avg_rating>8 AND m.production_company IS NOT NULL -- Filtering movies with average rating > 8 and filtering out null values
GROUP BY m.production_company
)
SELECT * FROM prod_rank
WHERE prod_company_rank = 1;








-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:


SELECT 
    g.genre, COUNT(m.id) AS movie_count -- Selecting genre name and number of movies in that genre
FROM
    movie m
        INNER JOIN
    genre g ON m.id = g.movie_id -- Joining genre table with movie
        INNER JOIN
    ratings r ON m.id = r.movie_id -- Joining ratings table with genre and movie
WHERE
    r.total_votes > 1000 -- Filtering movies with total votes greater than 1000
        AND MONTH(date_published) = 3 -- Filtering for movies released in March
        AND YEAR(date_published) = 2017 -- Filtering for movies released in 2017
        AND m.country LIKE '%USA%' -- Filtering for movies released in USA
GROUP BY g.genre
ORDER BY COUNT(m.id) DESC;







-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:


SELECT 
    m.title, avg_rating, g.genre -- Selecting movie name, average rating and genre
FROM
    movie m
        INNER JOIN
    genre g ON m.id = g.movie_id -- Joining genre table with movie
        INNER JOIN
    ratings r ON m.id = r.movie_id -- Joining ratings table with genre and movie
WHERE
    avg_rating > 8 AND m.title LIKE 'The%' -- Filtering movies with average rating >8 and title starting with 'The'
ORDER BY avg_rating DESC;


-- Same query as above but by using median rating
SELECT 
    m.title, avg_rating, g.genre -- Selecting movie name, average rating and genre
FROM
    movie m
        INNER JOIN
    genre g ON m.id = g.movie_id -- Joining genre table with movie
        INNER JOIN
    ratings r ON m.id = r.movie_id -- Joining ratings table with genre and movie
WHERE
    median_rating > 8 AND m.title LIKE 'The%' -- Filtering movies with average rating >8 and title starting with 'The'
ORDER BY avg_rating DESC;




-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:


SELECT 
    COUNT(m.id) AS movie_count-- Number of movies
FROM
    movie m
        INNER JOIN
    ratings r ON m.id = r.movie_id -- Joining ratings table with movie
WHERE
    date_published BETWEEN '2018-04-01' AND '2019-04-01' AND median_rating = 8;  -- Filtering movies with median rating = 8 and published date between 1st April 2018 and 2019







-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:


SELECT 
    language, SUM(total_votes) as total_votes -- Movie language and sum of total votes
FROM -- Here we have a subquery to filter movies which have only german and any other language, only italian and any other language, and any other languages except these two
    (
    SELECT 
        CASE
                WHEN languages LIKE '%German%' THEN 'German' -- Combinations having German and anything else
                WHEN languages LIKE '%Italian%' THEN 'Italian' -- Combinations having Italian and anything else
                ELSE languages -- Any other languages
		END AS language,
            total_votes
    FROM
        movie m
    INNER JOIN ratings r ON m.id = r.movie_id
    ) AS temp -- Joining ratings table with movie and naming as temp
WHERE -- Here we are filtering only German and Italian
    language IN ('German' , 'Italian')
GROUP BY language;




-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

SELECT -- In all the below columns, wherever there is a null we put a 1, else a 0 and then summing to get total nulls
    SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END) AS name_nulls, 
    SUM(CASE WHEN height IS NULL THEN 1 ELSE 0 END) AS height_nulls, 
    SUM(CASE WHEN date_of_birth IS NULL THEN 1 ELSE 0 END) AS date_of_birth_nulls, 
    SUM(CASE WHEN known_for_movies IS NULL THEN 1 ELSE 0 END) AS known_for_movies_nulls
FROM names n;






/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/



-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:



WITH top_genre AS -- Opening a CTE t find top 3 genres
(
	SELECT genre FROM movie m
	INNER JOIN genre g
	ON m.id= g.movie_id
	INNER JOIN ratings r
	ON m.id = r.movie_id
	WHERE avg_rating>8
	GROUP BY genre
	ORDER BY COUNT(m.id) DESC
	LIMIT 3
)
SELECT 
    n.name AS director_name, COUNT(m.id) AS movie_count -- Selecting director name and number of movies
FROM
    movie m
        INNER JOIN
    director_mapping d ON m.id = d.movie_id  -- Joining director mapping table with movie
        INNER JOIN
    names n ON d.name_id = n.id  -- Joining names table with director mapping table
        INNER JOIN
    genre g ON m.id = g.movie_id -- Joining genre table with movie table
        INNER JOIN
    ratings r ON m.id = r.movie_id  -- Joining ratings table with movie table
WHERE g.genre IN (SELECT * FROM top_genre) AND avg_rating>8 -- Filtering for genres which appear in the top 3 genres category and have an average rating>8
GROUP BY director_name
ORDER BY COUNT(m.id) DESC  -- Ordering in descending manner by number of movies
LIMIT 3;





/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT 
    n.name AS actor_name, COUNT(m.id) AS movie_count -- Getting actor name and number of movies acted in
FROM
    movie m
        INNER JOIN
    role_mapping ro ON m.id = ro.movie_id -- Joining role mapping table with movie
        INNER JOIN
    names n ON ro.name_id = n.id -- Joining names table with role mapping table
        INNER JOIN
    ratings r ON m.id = r.movie_id -- Joining ratings table with movie
WHERE
    median_rating >= 8 AND ro.category = 'actor' -- Filtering for role as Actor and average movie rating > 8
GROUP BY actor_name
ORDER BY COUNT(m.id) DESC  -- Ordering in descending manner by number of movies
LIMIT 2; -- Top 2





/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

WITH prod_company AS
(
	SELECT PRODUCTION_COMPANY,
	SUM(TOTAL_VOTES) AS vote_count,
	DENSE_RANK() OVER (ORDER BY SUM(TOTAL_VOTES) DESC) AS prod_comp_rank
	FROM movie M
	INNER JOIN ratings R
	ON M.ID = R.MOVIE_ID
	GROUP BY PRODUCTION_COMPANY
)
SELECT * FROM prod_company
WHERE prod_comp_rank<=3;






/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:


WITH actor_rankings AS -- Opening a CTE
(
    SELECT 
        n.name AS actor_name,
        SUM(r.total_votes) AS total_votes, -- Summing up total votes
        COUNT(m.id) AS movie_count, -- Number of movies
        ROUND(SUM(r.total_votes * r.avg_rating) / SUM(r.total_votes), 2) AS actor_avg_rating, -- Finding weighted average
        RANK() OVER (ORDER BY SUM(r.total_votes * r.avg_rating) / SUM(r.total_votes) DESC) AS actor_rank -- Finding rank based on weighted average
    FROM movie m
    INNER JOIN role_mapping ro -- Joining movie table with role mapping table
		ON ro.movie_id = m.id
    INNER JOIN ratings r -- Joining movie table with ratings table
		ON m.id = r.movie_id
    INNER JOIN names n -- Joining names table with role mapping table
		ON ro.name_id = n.id
    WHERE ro.category = 'actor' AND m.country = 'India' -- Filtering for actors from India
    GROUP BY actor_name
    HAVING COUNT(m.id) >= 5 -- Filtering for number of movies acted in > 5
    ORDER BY actor_avg_rating DESC, total_votes DESC
)
SELECT * FROM actor_rankings
WHERE actor_rank = 1;



-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

WITH actress_rankings AS -- Opening a CTE
(
	SELECT 
		n.name AS actress_name,
		SUM(r.total_votes) AS total_votes, -- Summing up total votes
		COUNT(m.id) AS movie_count, -- Number of movies
		ROUND (SUM(r.total_votes*r.avg_rating) / SUM(r.total_votes),2) AS actress_avg_rating, -- Finding weighted average
		RANK() OVER( ORDER BY  SUM(r.total_votes*r.avg_rating) / SUM(r.total_votes) DESC) as actress_rank -- Finding rank based on weighted average
	FROM movie m
	INNER JOIN role_mapping ro -- Joining movie table with role mapping table
		ON ro.movie_id = m.id
	INNER JOIN ratings r -- Joining movie table with ratings table
		ON m.id = r.movie_id
	INNER JOIN names n -- Joining names table with role mapping table
		ON ro.name_id = n.id
	WHERE ro.category = 'actress' AND m.country ='India' AND m.languages ='Hindi' -- Filtering for actors from India
	GROUP BY actress_name
	HAVING COUNT(m.id)>=3 -- Filtering for number of movies acted in > 5
	ORDER BY actress_avg_rating DESC, total_votes DESC
)
SELECT * FROM actress_rankings;

/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:

SELECT 
    title,
    avg_rating,
    CASE
        WHEN avg_rating > 8 THEN 'Superhit movies'
        WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit movies'
        WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch movies'
        ELSE 'Flop Movies'
    END AS avg_rating_category
FROM
    movie m
        INNER JOIN
    genre g ON m.id = g.movie_id
        INNER JOIN
    ratings r ON r.movie_id = m.id
WHERE
    genre = 'Thriller'
ORDER BY avg_rating DESC;







/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

WITH genre_avg_duration AS
(
	SELECT 
		   g.genre AS genre,
		   ROUND(AVG(m.duration),2) AS avg_duration
	FROM genre g
	INNER JOIN movie m
		ON g.movie_id = m.id
	GROUP BY genre 
)
SELECT  *,
		SUM(avg_duration) OVER w AS running_total_duration,
		ROUND(AVG(avg_duration) OVER w, 2) AS moving_avg_duration
FROM genre_avg_duration 
WINDOW w AS (ORDER BY genre ASC ROWS UNBOUNDED PRECEDING);







-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies

WITH top3_genre AS -- Opening a CTE to find top three genres based on movie count
(
	SELECT g.genre  FROM movie m
	INNER JOIN genre g
		ON g.movie_id = m.id
	GROUP BY g.genre
	ORDER BY COUNT(m.id) DESC
	LIMIT 3
),
top5movies AS -- Opening a CTE to find top movies based on worldwide gross income
(
	SELECT  g.genre, m.year, m.title,
	 CASE WHEN worlwide_gross_income LIKE '%INR%' THEN CONCAT ('$', ' ', SUBSTRING(worlwide_gross_income,5, LENGTH(worlwide_gross_income)-4)/82.26) -- When currency is INR, extract the number and convert to USD
	 ELSE worlwide_gross_income -- All other cases we leave the currency as USD
	 END AS worldwide_gross_income
	 FROM movie m
	 INNER JOIN genre g
		ON m.id = g.movie_id
	 WHERE genre IN (SELECT genre FROM top3_genre)
 ),
 rankings AS -- Opening a CTE to do a ranking on the top movies
 (
	 SELECT 
		*, 
		DENSE_RANK() OVER(PARTITION BY year,genre ORDER BY CONVERT(SUBSTRING(worldwide_gross_income,3, LENGTH(worldwide_gross_income)-2), UNSIGNED INT) DESC) AS movie_rank -- Creating a rnking by partioning by year and genre and ordering by the numeric part of gross income and converting that to INT
	 from top5movies
 )
 SELECT * from rankings
 WHERE movie_rank<=5 -- Filtering for top 5 movies
 ORDER BY genre, year, movie_rank;








-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

SELECT
	production_company,
	COUNT(id) as movie_count,
	ROW_NUMBER() OVER(ORDER BY COUNT(id) DESC) AS prod_comp_rank
FROM 
	movie m
INNER JOIN ratings r
	ON m.id = r.movie_id
WHERE median_rating>=8
AND production_company IS NOT NULL AND POSITION(',' IN languages)>0
GROUP BY production_company
LIMIT 2;








-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

WITH actress_rankings AS -- Opening a CTE
(
	SELECT 
		n.name AS actress_name,
		SUM(r.total_votes) AS total_votes, -- Summing up total votes
		COUNT(m.id) AS movie_count, -- Number of movies
		SUM(r.total_votes*r.avg_rating) / SUM(r.total_votes) AS actress_avg_rating, -- Finding weighted average
		RANK() OVER( ORDER BY  SUM(r.total_votes*r.avg_rating) / SUM(r.total_votes) DESC, SUM(r.total_votes) DESC ) as actress_rank -- Finding rank based on weighted average
	FROM movie m
	INNER JOIN role_mapping ro -- Joining movie table with role mapping table
		ON ro.movie_id = m.id
	INNER JOIN ratings r -- Joining movie table with ratings table
		ON m.id = r.movie_id
	INNER JOIN names n -- Joining names table with role mapping table
		ON ro.name_id = n.id
	INNER JOIN genre g -- Joining movie table with genre table
		ON g.movie_id = m.id
	WHERE ro.category = 'actress' AND g.genre='Drama' AND r.avg_rating>=8 -- Filtering for actresses and drama genre
	GROUP BY actress_name
)
SELECT * FROM actress_rankings
WHERE actress_avg_rating>=8 AND actress_rank <=3; -- Filtering for average actress rating >=8 and rank of actress<3






/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:


WITH ctf_date_summary AS
(
    SELECT d.name_id,
           NAME,
           d.movie_id,
           duration,
           r.avg_rating,
           total_votes,
           m.date_published,
           Lead(date_published, 1) OVER (PARTITION BY d.name_id ORDER BY date_published, movie_id) AS next_date_published
    FROM director_mapping AS d
    INNER JOIN names AS n ON n.id = d.name_id
    INNER JOIN movie AS m ON m.id = d.movie_id
    INNER JOIN ratings AS r ON r.movie_id = m.id
),
top_director_summary AS
(
    SELECT *,
           Datediff(next_date_published, date_published) AS date_difference
    FROM ctf_date_summary
)
SELECT name_id AS director_id,
       NAME AS director_name,
       COUNT(movie_id) AS number_of_movies,
       ROUND(AVG(date_difference), 2) AS avg_inter_movie_days,
       ROUND(AVG(avg_rating), 2) AS avg_rating,
       SUM(total_votes) AS total_votes,
       MIN(avg_rating) AS min_rating,
       MAX(avg_rating) AS max_rating,
       SUM(duration) AS total_duration
FROM top_director_summary
GROUP BY director_id
ORDER BY COUNT(movie_id) DESC, AVG(avg_rating) DESC
LIMIT 9;



