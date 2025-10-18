WITH combined_ads AS (
      SELECT
        ad_date,
        CAST(adset_id AS VARCHAR) AS adset_identifier
    FROM
        facebook_ads_basic_daily
    UNION ALL
    SELECT
        ad_date,
        adset_name AS adset_identifier 
    FROM
        google_ads_basic_daily
),
distinct_dates AS (
    
    SELECT DISTINCT
        ad_date,
        adset_identifier
    FROM
        combined_ads
),
date_groups AS (
    
    SELECT
        adset_identifier,
        ad_date,
        (ad_date - (ROW_NUMBER() OVER (PARTITION BY adset_identifier ORDER BY ad_date) * INTERVAL '1 day')) AS date_group
    FROM
        distinct_dates
),
streaks AS (
    
    SELECT
        adset_identifier,
        COUNT(*) AS duration_days
    FROM
        date_groups
    GROUP BY
        adset_identifier,
        date_group
),
ranked_streaks AS (
    
    SELECT
        adset_identifier,
        duration_days,
        ROW_NUMBER() OVER (PARTITION BY adset_identifier ORDER BY duration_days DESC) as rn
    FROM
        streaks
)
SELECT
    adset_identifier,
    duration_days
FROM
    ranked_streaks
WHERE
    rn = 1
ORDER BY
    duration_days DESC;