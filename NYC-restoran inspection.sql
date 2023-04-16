SELECT * FROM restoran_inspections.nyc_restoran_inspections;

-- Updating columns which contains Date but are not in order YYYY-MM-DD 
UPDATE nyc_restoran_inspections SET RECORD_DATE = DATE_FORMAT(STR_TO_DATE(RECORD_DATE, '%m-%d-%Y'), '%Y-%m-%d');

UPDATE nyc_restoran_inspections SET INSPECTION_DATE = DATE_FORMAT(STR_TO_DATE(INSPECTION_DATE, '%m-%d-%Y'), '%Y-%m-%d');

UPDATE nyc_restoran_inspections 
SET GRADE_DATE = IF(GRADE_DATE IS NULL OR GRADE_DATE = '', NULL, DATE_FORMAT(STR_TO_DATE(GRADE_DATE, '%m-%d-%Y'), '%Y-%m-%d'));

-- Checking if there is duplicated data in the table
WITH duplicated_data AS (
Select Row_number() Over (Partition by CAMIS, DBA, BORO, BUILDING, STREET, ZIPCODE, PHONE, CUISINE_DESCRIPTION, INSPECTION_DATE, TAKEN_ACTION, VIOLATION_CODE, CRITICAL_FLAG,
SCORE, GRADE, GRADE_DATE, RECORD_DATE, INSPECTION_TYPE, Latitude, Longitude, Community_Board, Council_District, Council_District, Census_Tract, BIN, BBL, NTA) -1 AS duplicated
From `nyc_restoran_inspections` 
)

Select *
From duplicated_data
Where  duplicated > 1

-- Filtering the restorans based on their grades from inspection 
SELECT 
    camis,
    dba,
    boro,
    building,
    street,
    zipcode,
    cuisine_description,
    CASE
        WHEN grade = 'A' THEN 'top_A'
        WHEN grade = 'B' THEN 'top_B'
        WHEN grade = 'C' THEN 'top_c'
        WHEN grade = 'Z' THEN 'top_z'
        WHEN grade = 'P' THEN 'top_p'
        ELSE 'top_z'
    END AS restoran_grade
FROM
    nyc_restoran_inspections
ORDER BY restoran_grade;

-- Finding the best 10 restoran with the best scores 
SELECT dba, boro, building, street, zipcode, cuisine_description, grade, CAST(score AS SIGNED) AS score_int
FROM nyc_restoran_inspections 
WHERE score BETWEEN 1 AND 10 AND grade = 'A'
GROUP BY dba, boro, building, street, zipcode, cuisine_description, grade, score
ORDER BY score_int 
LIMIT 10;

--  Which violation code is the most present in the inspection details 
Select violation_code, Count(violation_code)  AS number_of_violation_code
FROM nyc_restoran_inspections
Group by violation_code, violation_description
Order by Count(violation_code) DESC

-- In which year there was the most inspection done
SELECT 
  CASE 
    WHEN Inspection_date BETWEEN '2015-01-01' AND '2015-12-31' THEN 'year_2015'
    WHEN Inspection_date BETWEEN '2016-01-01' AND '2017-12-31' THEN 'year_2016'
    WHEN Inspection_date BETWEEN '2017-01-01' AND '2017-12-31' THEN 'year_2017'
    WHEN Inspection_date BETWEEN '2018-01-01' AND '2018-12-31' THEN 'year_2018'
    WHEN Inspection_date BETWEEN '2019-01-01' AND '2019-12-31' THEN 'year_2019'
    WHEN Inspection_date BETWEEN '2020-01-01' AND '2020-12-31' THEN 'year_2020'
    ELSE 'out_of_scope'
  END AS inspeaction_dates_from_2015_to_2020,
  COUNT(Inspection_date) AS number_of_inspections
FROM nyc_restoran_inspections 
WHERE inspection_date IS NOT NULL 
GROUP BY inspeaction_dates_from_2015_to_2020
ORDER BY number_of_inspections;
 
-- Which district of NYC has the worste restoran grades
SELECT boro, grade, COUNT(REGEXP_REPLACE(grade, '[^[:print:]]', '')) AS number_of_grades
FROM nyc_restoran_inspections
WHERE grade IS NOT NULL AND TRIM(grade) <> ''
AND grade = 'C'
GROUP BY  boro, grade
Order by number_of_grades DESC

-- Which cousine in NYC collected the most grade 'A'
SELECT dba, cuisine_description, grade, 
COUNT(cuisine_description) AS number_of_cuisine
FROM `nyc_restoran_inspections`
WHERE grade = 'A'
GROUP BY dba, cuisine_description, grade
Order by number_of_cuisine DESC




