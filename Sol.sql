use film_rental;
show tables;
select * from actor;
select * from address;
select * from category;
select * from city;
select * from country;
select * from customer;
select * from film;
select * from film_actor;
select * from film_category;
select * from inventory;
select * from language;
select * from payment;
select * from rental;
select * from staff;
select * from store; 
-- 1.	What is the total revenue generated from all rentals in the database? (2 Marks)

select floor(sum(amount)) as total_revenue from payment;

-- 2.	How many rentals were made in each month_name? (2 Marks)

select monthname(rental_date) as month_name,count(*) as count_of_rentals from rental group by month_name order by count_of_rentals asc;

-- 3.	What is the rental rate of the film with the longest title 
-- in the database? (2 Marks)

select rental_rate, title from film where length(title) = (select max(length(title)) from film);

-- 4.	What is the average rental rate for films that were taken from the 
-- last 30 days from the date("2005-05-05 22:04:30")? (2 Marks)

select avg(amount) from payment
where datediff(payment_date, "2005-05-05 22:04:30") >= 30;

-- 5.	What is the most popular category of films in terms of the 
-- number of rentals? (3 Marks)

select cat.name, count(*) as most_popular_film from inventory inv inner join rental ren inner join film_category fc inner join category cat
on inv.inventory_id = ren.inventory_id and inv.film_id = fc.film_id and fc.category_id = cat.category_id
group by cat.name;

-- 6.	Find the longest movie duration from the list of films that have not 
-- been rented by any customer. (3 Marks)

select film_id, title, description, length as duration, rating
from film
where film_id not in (select film_id from inventory) order by length desc limit 1;

-- 7.	What is the average rental rate for films, broken down by category? (3 Marks)

select category.name, avg(film.rental_rate) as AVG from category inner join film_category inner join film
on category.category_id = film_category.category_id and film_category.film_id = film.film_id
group by category.name order by AVG desc;

-- 8.	What is the total revenue generated from rentals for each actor in 
-- the database? (3 Marks)

select concat_ws(' ',actor.first_name,actor.last_name) as Actor_Name, sum(payment.amount) as Total_Revenue
from actor inner join film_actor inner join inventory inner join rental inner join payment 
on actor.actor_id = film_actor.actor_id and film_actor.film_id  = inventory.film_id and inventory.inventory_id = rental.inventory_id and rental.rental_id = payment.rental_id
group by Actor_Name order by Total_Revenue desc;

-- 9.	Show all the actresses who worked in a film having a "Wrestler" 
-- in the description. (3 Marks)

select distinct concat_ws(' ',actor.first_name,actor.last_name) as Actor_Name 
from actor inner join film_actor inner join film
on actor.actor_id = film_actor.actor_id and film_actor.film_id = film.film_id
where lower(film.description) like '%wrestler%';

-- 10.	Which customers have rented the same film more than once? (3 Marks)

select concat_ws(customer.first_name,customer.last_name) as Cust_name, inventory.film_id as Film_ID, count(*) as rented_count
from customer inner join rental inner join inventory
on customer.customer_id = rental.customer_id and rental.inventory_id = inventory.inventory_id
group by Cust_name,Film_ID
having rented_count >1
order by rented_count desc; 

-- 11.	How many films in the comedy category have a rental rate higher 
-- than the average rental rate? (3 Marks)

select category.name, count(*) from 
category inner join film_category inner join film 
on category.category_id = film_category.category_id and film_category.film_id = film.film_id
where lower(category.name) = 'comedy' and film.rental_rate > (select avg(film.rental_rate) from film)
group by category.name;

-- 12.	Which films have been rented the most by customers living in each city? (3 Marks)


select city.city, count(*) as no_of_films from inventory inner join rental inner join customer inner join address inner join city
on inventory.inventory_id = rental.inventory_id and rental.customer_id = customer.customer_id and customer.address_id = address.address_id and address.city_id = city.city_id
group by 1
order by 2 desc;

# 13. What is the total amount spent by customers whose rental payments exceed $200?
# customer -> payment -> rental -> inventory -> film
select concat_ws(" ", customer.first_name, customer.last_name) as customer_name, sum(payment.amount) as total_purchase from customer inner join payment inner join rental inner join inventory inner join film
on customer.customer_id = payment.customer_id and payment.rental_id = rental.rental_id and rental.inventory_id = inventory.inventory_id and inventory.film_id = film.film_id
group by customer_name
having total_purchase > 200;

# 14. Display the fields which are having foreign key constraints related to the "rental" table. [Hint: using Information_schema]
SELECT distinct CONSTRAINT_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
WHERE TABLE_NAME='rental' and CONSTRAINT_TYPE = "FOREIGN KEY";

# 15. Create a View for the total revenue generated by each staff member, broken down by store city with country name?
# payment -> staff -> store -> address | store -> staff
# payment.staff_id -> staff.staff_id -> store.manager_staff_id -> staff.staff_id | store.address_id -> address.city_id
CREATE VIEW sales_by_store
AS
(select
     concat_ws(" ", staff.first_name, staff.last_name) as manager,
     concat_ws(" ", city.city, country.country) as location,
     sum(payment.amount) as total_revenue
from payment inner join store inner join staff inner join address inner join city inner join country
on payment.staff_id = store.manager_staff_id and
   store.address_id = address.address_id and
   store.manager_staff_id = staff.staff_id and
   address.city_id = city.city_id and
   city.country_id = country.country_id
group by payment.staff_id
order by 3 desc);

select * from sales_by_store;

# 16. Create a view based on rental information consisting of visiting_day, customer_name, title of film, no_of_rental_days, amount paid by the customer along with percentage of customer spending.
# visiting_day : ranking based on customer payment history 
# no_of_rental_days : return_date - rental_date
# percentage : total distribution of the customer payment amount
CREATE VIEW sales_by_store
AS
(select
     concat_ws(" ", staff.first_name, staff.last_name) as manager,
     concat_ws(" ", city.city, country.country) as location,
     sum(payment.amount) as total_revenue
from payment inner join store inner join staff inner join address inner join city inner join country
on payment.staff_id = store.manager_staff_id and
   store.address_id = address.address_id and
   store.manager_staff_id = staff.staff_id and
   address.city_id = city.city_id and
   city.country_id = country.country_id
group by payment.staff_id
order by 3 desc);

select * from sales_by_store;

# 17. Display the customers who paid 50% of their total rental costs within one day.
select *
from customer_rental_info
where percentage = 50 and no_of_rental_days < 1;




