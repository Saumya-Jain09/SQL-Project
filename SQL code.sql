CREATE DATABASE new_wheels;
 USE new_wheels ;

##Question 1 
 SELECT COUNT(customer_id), state
FROM customer_t 
GROUP BY state
ORDER BY COUNT(customer_id) DESC ;


##Question 4

SELECT COUNT(product_id) as Customer_Number , Vehicle_Maker 
FROM product_t
GROUP BY vehicle_maker 
ORDER BY COUNT(product_id) DESC;


##Question 10
Select quarter_number, round(avg(datediff(ship_date,order_date)),0) as time_taken from order_t
Group by 1
order by avg(datediff(ship_date,order_date));


##Question9
select cust.credit_card_type, round(avg(o.discount),2) AS average_discount
from
order_t as o INNER JOIN customer_t as cust
on o.customer_id=cust.customer_id
group by cust.credit_card_type
order by 2 DESC;



##Question 8

SELECT QUARTER_NUMBER , SUM((VEHICLE_PRICE*QUANTITY)-(DISCOUNT*VEHICLE_PRICE*QUANTITY)) as REVENUE ,
count(order_id) as TOTAL_ORDERS
from order_t
group by 1
order by 1 ;

##QUESTION 6

SELECT 
QUARTER_NUMBER,
COUNT(ORDER_ID) AS NO_OF_ORDERS
FROM ORDER_T
GROUP BY 1
ORDER BY 2 DESC;


##question 5

select state, vehicle_maker 
from ( 
		select
        state ,vehicle_maker,
        COUNT(customer_id) as no_of_cust ,
        rank() over(partition by state order by count(customer_id) DESC) rnk
        FROM CUSTOMER_T JOIN order_t using (customer_id) join product_t using (product_id)
        group by 1,2) tb1
        where rnk =1;
        
##QUESTION 2
      
WITH RATING_BUCKET AS
(
	SELECT
    QUARTER_NUMBER, CUSTOMER_FEEDBACK,
        CASE 
			WHEN CUSTOMER_FEEDBACK = "Very Bad" THEN "1"
            WHEN CUSTOMER_FEEDBACK = "Bad" THEN "2"
            WHEN CUSTOMER_FEEDBACK = "Okay" THEN "3"
            WHEN CUSTOMER_FEEDBACK = "Good" THEN "4"
            WHEN CUSTOMER_FEEDBACK = "Very Good" THEN "5"
		END AS FEEDBACK
	FROM order_t
)
SELECT
	QUARTER_NUMBER,ROUND(AVG(FEEDBACK),2) AS AVG_RATING FROM RATING_BUCKET
    GROUP BY 1
    ORDER BY 1;
    
    ##Question 3 
    
WITH CTE AS (
   SELECT
    QUARTER_NUMBER, CUSTOMER_FEEDBACK ,
    Count(Customer_id) AS NUMBER_OF_CUSTOMER ,SUM(COUNT(CUSTOMER_ID)) OVER (PARTITION BY QUARTER_NUMBER) AS TOTAL_NUMBER_OF_CUSTOMER
    FROM ORDER_T GROUP BY QUARTER_NUMBER , CUSTOMER_FEEDBACK ORDER BY QUARTER_NUMBER 
    )
    SELECT QUARTER_NUMBER , CUSTOMER_FEEDBACK, NUMBER_OF_CUSTOMER/TOTAL_NUMBER_OF_CUSTOMER*100 AS PERCENTAGE_OF_CUSTOMER_FEEBACK
    FROM CTE ;
    
    
    
    
##QUESTION 7
WITH QoQ AS 
(
	SELECT
		QUARTER_NUMBER,
		SUM(calc_revenue_f(VEHICLE_PRICE, DISCOUNT, QUANTITY)) revenue
	FROM 
		order_t
	GROUP BY 1
)
SELECT
	QUARTER_NUMBER,
    REVENUE,
    LAG(REVENUE) OVER (ORDER BY QUARTER_NUMBER) AS PREVIOUS_QUARTER_REVENUE,
    ((REVENUE - LAG(REVENUE) OVER (ORDER BY QUARTER_NUMBER))/LAG(REVENUE) OVER(ORDER BY QUARTER_NUMBER) * 100) AS "QUARTER OVER QUARTER REVENUE(%)"
FROM
	QoQ;
    
    
    WITH WoW AS 
(
    SELECT
          week_number,
          SUM((order_cost - ((discount/100)*order_cost))) revenue
    FROM gl_eats_rest_t pro 
	INNER JOIN gl_eats_ord_t ord
	    ON pro.restaurant_id = ord.restaurant_id
	GROUP BY 1
)
SELECT
      week_number,
      revenue,
      LAG(revenue) OVER(ORDER BY week_number) AS previous_revenue,
      (revenue - LAG(revenue) OVER(ORDER BY week_number))/LAG(revenue) OVER(ORDER BY week_number) AS wow_perc_change
FROM WoW;

##Question 3
WITH RATING_BUCKET AS
(
	SELECT
    QUARTER_NUMBER, CUSTOMER_FEEDBACK,
        CASE 
			WHEN CUSTOMER_FEEDBACK = "Very Bad" THEN "1"
            WHEN CUSTOMER_FEEDBACK = "Bad" THEN "2"
            WHEN CUSTOMER_FEEDBACK = "Okay" THEN "3"
            WHEN CUSTOMER_FEEDBACK = "Good" THEN "4"
            WHEN CUSTOMER_FEEDBACK = "Very Good" THEN "5"
		END AS FEEDBACK
	FROM order_t
)
SELECT
	QUARTER_NUMBER,
	(SUM((CASE WHEN CUSTOMER_FEEDBACK = "1" THEN 1 ELSE 0 END)) / COUNT(CUSTOMER_FEDBACK))*100 AS "VERY_BAD(%)",
    (SUM((CASE WHEN CUSTOMER_FEEDBACK = 2 THEN 1 ELSE 0 END)) / COUNT(CUSTOMER_FEEDBACK))*100 AS "BAD(%)",
    (SUM((CASE WHEN CUSTOMER_FEEDBACK = 3 THEN 1 ELSE 0 END))/ COUNT(CUSTOMER_FEDBACK))*100 AS "OKAY(%)",
    (SUM((CASE WHEN CUSTOMER_FEEDBACK = 4 THEN 1 ELSE 0 END))/ COUNT(CUSTOMER_FEDBACK))*100 AS "GOOD(%)",
    (SUM((CASE WHEN customer_feedback = 5 THEN 1 ELSE 0 END))/ COUNT(CUSTOMER_FEDBACK))*100 AS "VERY_GOOD(%)" 
FROM RATING_BUCKET
GROUP BY 1
ORDER BY 1; 

Select customer_feedback, quarter_number,count(Customer_id), 
sum(count(customer_id)) over (partition by quarter_number)  
from order_t
Group by customer_feedback,quarter_number order by quarter_number






