-- 1. Retrieve the total no of order placed

select count(order_id)  as total_orders
from orders;



-- 2 .calculate total revenue generated from pizza sales
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id
 
 
 
 
    
-- 3.identify the highest-priced pizza.
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;




-- 4. identify the most common pizza size ordered.
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

-- 6. list the top 5 most ordered pizza types along with quantity.
SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;


-- 6 .join the necessary tables to find the total quantity 
-- of each pizza category ordered.
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;


-- 7 determine the distribution of orders by hour of the day
SELECT 
    HOUR(time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(time);


-- 8 . find category-wise distribution of pizza.
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

    
-- 8 group the ordersby date and calculate the average
-- number of pizzas ordered per day.
SELECT 
   round(AVG(quantity), 0)
FROM
    (SELECT 
        orders.date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.date) AS order_quantity;
    
    

-- 10 determine the top 3 most ordered pizza types based on revenue
SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;



-- 11 calculate the  percentage contribution of each
-- pizza type to total revenue 
SELECT pizza_types.category,
ROUND(SUM(order_details.quantity * pizzas.price)/ (SELECT 
ROUND(SUM(order_details.quantity * pizzas.price),2) AS 
total_sales FROM order_details JOIN pizzas
 ON pizzas.pizza_id = order_details.pizza_id) * 100,2) 
 AS revenue FROM pizza_types JOIN pizzas
 ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;



-- 12 .analyze the cumulative revenue generated over time
select date , 
sum(revenue) over(order by date) as cum_revenue
from 
(select orders.date,
sum(order_details.quantity* pizzas.price) as revenue 
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.date) as sales;


-- 13 determine the top 3 most orders pizza types
-- based on revenue for each pizza category .
select name , revenue from
(select category , name , revenue ,
rank() over(partition by category order by revenue desc)
as rn
 from 
(select pizza_types.category , pizza_types.name , 
sum((order_details.quantity)* pizzas.price) as revenue 
from pizza_types join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category , pizza_types.name) as a) as b
where rn <= 3;