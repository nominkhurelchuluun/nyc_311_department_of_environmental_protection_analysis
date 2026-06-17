SELECT * FROM `calm-airship-477322-k5.Project1.nyc_311` LIMIT 1000

SELECT DISTINCT borough FROM `calm-airship-477322-k5.Project1.nyc_311`

--- total requets by complaint type
SELECT
    complaint_type,
    COUNT(*) AS total_requests
FROM `calm-airship-477322-k5.Project1.nyc_311`
GROUP BY complaint_type
ORDER BY total_requests DESC;

--- top complaint type with each borough 

WITH borough_complaints AS (
  SELECT
    borough,
    complaint_type,
    COUNT(*) AS total_requests
  FROM `calm-airship-477322-k5.Project1.nyc_311`
  WHERE borough != 'Unspecified'
  GROUP BY borough, complaint_type
)

SELECT *
FROM (
  SELECT *,
         RANK() OVER (
           PARTITION BY borough
           ORDER BY total_requests DESC
         ) AS rnk
  FROM borough_complaints
)
WHERE rnk = 1;

--- average resolution time by complaint type

SELECT
    borough,
    COUNT(*) AS closed_requests,
    ROUND(
      AVG(
        TIMESTAMP_DIFF(
          closed_date,
          created_date,
          HOUR
        ) / 24.0
      ),
      2
    ) AS avg_resolution_days
FROM `calm-airship-477322-k5.Project1.nyc_311`
WHERE status = 'Closed'
  AND borough != 'Unspecified'
  AND closed_date IS NOT NULL
GROUP BY borough
ORDER BY avg_resolution_days DESC;

--- monthly volume trend

SELECT
    EXTRACT(YEAR FROM created_date) AS year,
    EXTRACT(MONTH FROM created_date) AS month,
    complaint_type,
    COUNT(*) AS requests
FROM `calm-airship-477322-k5.Project1.nyc_311`
GROUP BY year, month, complaint_type
ORDER BY year, month;

--- open vs closed requests

SELECT
    status,
    COUNT(*) AS total,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct
FROM `calm-airship-477322-k5.Project1.nyc_311`
GROUP BY status
ORDER BY total DESC;

--- borough performance ranking 
SELECT
    borough,
    COUNT(*) AS total_requests,
    ROUND(
      AVG(
        TIMESTAMP_DIFF(
          closed_date,
          created_date,
          DAY
        )
      ),
      2
    ) AS avg_resolution_days,
    RANK() OVER (
      ORDER BY AVG(
        TIMESTAMP_DIFF(
          closed_date,
          created_date,
          DAY
        )
      )
    ) AS service_rank
FROM `calm-airship-477322-k5.Project1.nyc_311`
WHERE status = 'Closed'
  AND borough != 'Unspecified'
GROUP BY borough;

