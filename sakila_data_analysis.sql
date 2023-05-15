/***************************************************/
/* SQL for Data Analysis - Sakila Movie Rental Store  */
/***************************************************/

/* Before you run these queries, make sure to create Sakila DB and import the related data first */


/* 1. Email Campaigns for customers of Store 2
First, Last name and Email address of customers from Store 2 */
SELECT
	first_name,
    last_name,
    email
FROM
	customer
WHERE store_id = 2;

/* 2. Number of movies with rental rate of 0.99$ */
SELECT
	COUNT(*)
FROM 
	film
WHERE rental_rate = 0.99;

/* 3. We want to see rental rate and how many movies are in each rental rate categories */
SELECT 
    rental_rate, 
    COUNT(*) AS number_of_movies
FROM
    film
GROUP BY rental_rate
ORDER BY rental_rate;

/* 4. Which rating do we have the most films in? */
SELECT
	rating,
    COUNT(*) AS number_of_movies
FROM 
	film
GROUP BY rating
ORDER BY number_of_movies DESC
LIMIT 1;

/* 5. Which rating is most prevalant in each store? */
SELECT
	i.store_id,
    rating,
    COUNT(*) AS number_of_movies
FROM 
	film AS f
		INNER JOIN
	inventory AS i ON f.film_id = i.film_id
GROUP BY 
	i.store_id, 
    rating
ORDER BY 
	i.store_id ASC,
    number_of_movies DESC;

/* 6. We want to mail the customers about the upcoming promotion */
SELECT
	c.customer_id,
    c.first_name,
    c.last_name,
    a.address,
    a.address2,
    a.postal_code
FROM 
	customer AS c
		LEFT JOIN
	address AS a ON c.address_id = a.address_id;

/* 7. List of films by Film Name, Category, Language */
SELECT
	f.film_id,
    f.title,
    c.name AS category,
    l.name AS language
FROM 
	film AS f
		LEFT JOIN
	film_category AS fc ON f.film_id = fc.film_id
		LEFT JOIN
	category AS c ON fc.category_id = c.category_id
    LEFT JOIN 
		language AS l ON f.language_id = l.language_id;

/* 8. How many times each movie has been rented out? */
SELECT
	f.film_id,
    f.title,
    COUNT(r.rental_id) AS num_rented
FROM 
	 film AS f
		LEFT JOIN
	inventory AS i ON f.film_id = i.film_id
		LEFT JOIN
	rental AS r ON i.inventory_id = r.inventory_id
GROUP BY f.film_id
ORDER BY num_rented DESC;

/* 9. Revenue per Movie */

SELECT
	f.film_id,
    f.title,
    f.rental_rate,
    COUNT(r.rental_id) AS times_rented,
    f.rental_rate * COUNT(rental_id) AS total_revenue
FROM 
	film AS f
		LEFT JOIN 
	inventory AS i ON f.film_id = i.film_id
		LEFT JOIN
	rental AS r ON i.inventory_id = r.inventory_id
GROUP BY f.film_id
ORDER BY total_revenue DESC;

/* 10. Most Spending Customer so that we can send him/her rewards or debate points */
SELECT 
	c.customer_id,
    c.first_name,
    c.last_name,
    SUM(amount) AS total_spend
FROM 
	customer AS c
		LEFT JOIN 
	payment AS p ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY total_spend DESC
LIMIT 1;

/* 11. What Store has historically brought the most revenue */
SELECT
	s.store_id,
    SUM(p.amount) AS total_revenue
FROM 
	store AS s
		LEFT JOIN
	inventory AS i ON s.store_id = i.store_id
		LEFT JOIN
	rental AS r ON i.inventory_id = r.inventory_id
		LEFT JOIN
	payment AS p ON r.rental_id = p.rental_id
GROUP BY s.store_id
ORDER BY total_revenue DESC;

/* 12. How many rentals we have for each month */
SELECT
	DATE_FORMAT(rental_date, '%Y-%m') AS year_month_rented,
    COUNT(rental_id) AS number_of_rented_movies
FROM 
	rental
GROUP BY 
	year_month_rented
ORDER BY 
	year_month_rented;

/* 13. Rentals per Month (such Jan => How much, etc) */
SELECT
	DATE_FORMAT(rental_date, '%Y-%m') AS year_month_rented,
	MONTHNAME(rental_date) AS month_name,
    COUNT(rental_id) AS number_of_rented_movies
FROM 
	rental
GROUP BY 
	year_month_rented,
    month_name
ORDER BY 
	year_month_rented;

/* 14. Which date first movie was rented out? */
SELECT
	rental_date
FROM 
	rental
ORDER BY rental_date ASC
LIMIT 1;

/* Version 2 */
SELECT
	MIN(rental_date)
FROM 
	rental;

/* 15. Which date last movie was rented out? */
SELECT
	MAX(rental_date)
FROM 
	rental;

/* 16. For each movie, when was the first time and last time it was rented out? */
SELECT
	f.film_id,
    f.title,
    MIN(r.rental_date) AS first_date_rented,
    MAX(r.rental_date) AS last_date_rented
FROM 
	film AS f
		LEFT JOIN
	inventory AS i ON f.film_id = i.film_id
		LEFT JOIN
	rental AS r ON i.inventory_id = r.inventory_id
GROUP BY f.film_id
ORDER BY f.title;		

/* 17. Last Rental Date of every customer */
SELECT
	c.customer_id,
    c.first_name,
    c.last_name,
    MAX(r.rental_date) AS last_date_rented
FROM 
	customer AS c
		LEFT JOIN
	rental AS r ON c.customer_id = r.customer_id
GROUP BY c.customer_id
ORDER BY c.customer_id;

/* 18. Revenue Per Month */
SELECT
	DATE_FORMAT(payment_date, '%Y-%m') AS year_month_rented,
    SUM(amount) AS total_revenue
FROM 
	payment
GROUP BY
	year_month_rented
ORDER BY
	year_month_rented;

/* 19. How many distint Renters per month */
SELECT
	DATE_FORMAT(rental_date, '%Y-%m') AS year_month_rented,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM 
	rental
GROUP BY 
	year_month_rented
ORDER BY
	year_month_rented;

/* 20. Number of Distinct Film Rented Each Month */
SELECT
	DATE_FORMAT(r.rental_date, '%Y-%m') AS year_month_rented,
    COUNT(DISTINCT i.film_id) AS unique_films_rented
FROM 
	rental AS r
		LEFT JOIN
	inventory AS i ON r.inventory_id = i.inventory_id
GROUP BY year_month_rented
ORDER BY year_month_rented;

/* 21. Number of Rentals in Comedy , Sports and Family */
SELECT
	c.category_id,
	c.name,
    COUNT(r.rental_id) AS number_of_rentals
FROM 
	rental AS r
		LEFT JOIN
	inventory AS i ON r.inventory_id = i.inventory_id
		LEFT JOIN
	film_category AS fc ON i.film_id = fc.film_id
		LEFT JOIN
	category AS c ON fc.category_id = c.category_id
WHERE c.name IN ('Comedy', 'Sports', 'Family')
GROUP BY c.category_id;

/* 22. Users who have been rented at least 3 times */
SELECT
	c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(r.rental_id) AS total_rentals
FROM 
	customer AS c
		LEFT JOIN
	rental AS r ON c.customer_id = r.customer_id
GROUP BY c.customer_id
HAVING total_rentals >= 3
ORDER BY total_rentals DESC;

/* 23. How much revenue has one single store made over PG13 and R rated films */
SELECT
	i.store_id,
    f.rating,
    SUM(p.amount) AS total_revenue
FROM 
	rental AS r
		LEFT JOIN
	inventory AS i ON r.inventory_id = i.inventory_id
		LEFT JOIN
	payment AS p ON r.rental_id = p.payment_id
		LEFT JOIN 
	film AS f ON i.film_id = f.film_id
WHERE f.rating IN('PG-13', 'R')
GROUP BY 
	i.store_id,
    f.rating
ORDER BY 
	i.store_id,
    f.rating;

/*******************************************************/


/* 24. Active User  where active = 1 */
DROP TEMPORARY TABLE IF EXISTS active_users;
CREATE TEMPORARY TABLE active_users (
SELECT 
	*
FROM 
	customer
WHERE active = 1
);
/* 25. Reward Users : who has rented at least 30 times */
DROP TEMPORARY TABLE IF EXISTS users_rented_30;
CREATE TEMPORARY TABLE users_rented_30 (
SELECT
	c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(r.rental_id) AS total_rentals,
    c.address_id
FROM 
	customer AS c
		LEFT JOIN
	rental AS r ON c.customer_id = r.customer_id
GROUP BY c.customer_id
HAVING total_rentals >= 30
ORDER BY total_rentals DESC
);

/* 26. Reward Users who are also active */
SELECT
	*
FROM 
	users_rented_30 AS ur
		INNER JOIN
	active_users au ON ur.customer_id = au.customer_id;
		
/* 27. All Rewards Users with Phone */
SELECT
	*
FROM 
	users_rented_30 AS ur
		LEFT JOIN
	address AS a ON ur.address_id = a.address_id
WHERE a.phone IS NOT NULL;
