SELECT * FROM CASE_STUDY.BRIGHTTV.VIEWERSHIP;
SELECT * FROM CASE_STUDY.BRIGHTTV.USER_PROFILES;

CREATE OR REPLACE VIEW brighttv_clean_view AS
WITH base_data AS (
    SELECT
        v.userid,
        v.channel2 AS channel_name,
      
        COALESCE(
          TRY_TO_TIMESTAMP(v.recorddate2, 'YYYY/MM/DD HH24:MI:SS'),
          TRY_TO_TIMESTAMP(v.recorddate2, 'YYYY/MM/DD HH24:MI'),
          TRY_TO_TIMESTAMP(v.recorddate2, 'YYYY-MM-DD"T"HH24:MI:SS'),
          TRY_TO_TIMESTAMP(v.recorddate2, 'YYYY-MM-DD HH24:MI:SS'),
          TRY_TO_TIMESTAMP(v.recorddate2)  
        ) AS record_ts,
        v.duration2 AS watch_duration_minutes,
        u.gender,
        u.race,
        u.age,
        u.province
    FROM viewership v
    LEFT JOIN user_profiles u
        ON v.userid = u.userid
),

time_features AS (
    SELECT
        *,
        CAST(record_ts AS DATE) AS watch_date,
        DAYNAME(record_ts) AS day_of_week,
        HOUR(record_ts) AS watch_hour
    FROM base_data
),

time_of_day AS (
    SELECT
        *,
        CASE
            WHEN watch_hour BETWEEN 5 AND 11 THEN 'Morning'
            WHEN watch_hour BETWEEN 12 AND 16 THEN 'Afternoon'
            WHEN watch_hour BETWEEN 17 AND 20 THEN 'Evening'
            ELSE 'Night'
        END AS time_of_day
    FROM time_features
),

demographics AS (
    SELECT
        *,
        CASE
            WHEN age BETWEEN 0 AND 12 THEN '0–12 Kids'
            WHEN age BETWEEN 13 AND 18 THEN '13–18 Teens'
            WHEN age BETWEEN 19 AND 35 THEN '19–35 Youth'
            WHEN age BETWEEN 36 AND 55 THEN '36–55 Adult'
            WHEN age BETWEEN 56 AND 65 THEN '56–65 Older Adult'
            WHEN age > 65 THEN 'Senior'
            ELSE 'Unknown'
        END AS age_group
    FROM time_of_day
)

SELECT
    userid,
    gender,
    race,
    age_group,
    province,
    channel_name,
    watch_date,
    day_of_week,
    time_of_day,
    watch_duration_minutes
FROM demographics;


SELECT COUNT(*) FROM brighttv_clean_view;
SELECT * FROM brighttv_clean_view;
