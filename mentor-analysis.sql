-- Display the complete user_submissions table
SELECT * 
FROM user_submissions;



-- Retrieve each user's total number of submissions and the total points they have earned
SELECT 
    username,
    COUNT(id) AS total_submissions,
    SUM(points) AS points_earned
FROM 
    user_submissions
GROUP BY 
    username
ORDER BY 
    total_submissions DESC, 
    username DESC;



-- Calculate each user's average points per day
-- The result shows, for every user and each calendar day, their average points rounded to two decimal places
SELECT 
    username,
    TO_CHAR(submitted_at, 'DD-MM') AS day,
    ROUND(AVG(points), 2) AS average_points
FROM 
    user_submissions
GROUP BY 
    username, day
ORDER BY 
    username, day;



-- Identify the top three users with the highest number of correct submissions for each day
-- A correct submission is defined as any submission with points greater than zero

WITH daily_correct_submissions AS (
    SELECT 
        username,
        TO_CHAR(submitted_at, 'DD-MM') AS day,
        SUM(CASE WHEN points > 0 THEN 1 ELSE 0 END) AS correct_submissions
    FROM 
        user_submissions
    GROUP BY 
        username, day
),

daily_ranked_users AS (
    SELECT 
        *,
        DENSE_RANK() OVER (PARTITION BY day ORDER BY correct_submissions DESC) AS rank
    FROM 
        daily_correct_submissions
)

SELECT 
    day,
    username,
    correct_submissions
FROM 
    daily_ranked_users
WHERE 
    rank <= 3
ORDER BY 
    day, correct_submissions DESC;



-- Retrieve the top five users who have the highest number of incorrect submissions
-- Incorrect submissions are those where points are less than zero

SELECT 
    username,
    SUM(CASE WHEN points < 0 THEN 1 ELSE 0 END) AS incorrect_submissions
FROM 
    user_submissions
GROUP BY 
    username
ORDER BY 
    incorrect_submissions DESC
LIMIT 5;



-- Identify the top five users each week based on their total accumulated points
-- For each week, users are ranked by total points in descending order

SELECT 
    week_no,
    username,
    total_points,
    rank
FROM (
    SELECT 
        EXTRACT(WEEK FROM submitted_at) AS week_no,
        username,
        SUM(points) AS total_points,
        DENSE_RANK() OVER (PARTITION BY EXTRACT(WEEK FROM submitted_at) ORDER BY SUM(points) DESC) AS rank
    FROM 
        user_submissions
    GROUP BY 
        week_no, username
) AS ranked_users
WHERE 
    rank <= 5
ORDER BY 
    week_no ASC, rank ASC;
