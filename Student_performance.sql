-- Step 1: Create Warehouse
CREATE WAREHOUSE student_perf_wh WITH
   WAREHOUSE_SIZE = 'XSMALL'
   AUTO_SUSPEND = 300
   AUTO_RESUME = TRUE;

-- Step 2: Create Database and Schema
-- 2.1 Create Database
CREATE OR REPLACE DATABASE student_analysis_db;
USE DATABASE student_analysis_db;

-- 2.2 Create Schema
CREATE OR REPLACE SCHEMA public;
USE SCHEMA public;

-- Step 3: Load Data into Snowflake
-- 3.1 Create a Stage (temporary storage for loading files)
CREATE OR REPLACE STAGE student_stage
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1);

-- 3.2 Create the Table for student performance data
CREATE OR REPLACE TABLE student_performance (
    gender STRING,
    race_ethnicity STRING,
    parental_level_of_education STRING,
    lunch STRING,
    test_preparation_course STRING,
    math_score FLOAT,
    reading_score FLOAT,
    writing_score FLOAT
);

-- 3.3 Upload Data to the Stage (using SnowSQL or web interface)
-- Using SnowSQL to upload the file
snowsql -a <account_name> -u <username> -q "PUT file:///mnt/data/study_performance.csv @student_stage;"

-- Step 4: Load Data into the Table
COPY INTO student_performance
FROM @student_stage
FILE_FORMAT = (TYPE = 'CSV', SKIP_HEADER = 1, FIELD_OPTIONALLY_ENCLOSED_BY = '"')
ON_ERROR = 'CONTINUE';

-- Step 5: Data Exploration
-- 5.1 Preview the Data (check the first 10 rows)
SELECT * FROM student_performance LIMIT 10;

-- 5.2 Check for Missing Data (NULL values)
SELECT 
    COUNT(*) AS total_records,
    COUNT_IF(math_score IS NULL) AS null_math,
    COUNT_IF(reading_score IS NULL) AS null_reading,
    COUNT_IF(writing_score IS NULL) AS null_writing
FROM student_performance;

-- 5.3 Generate Summary Statistics for Numerical Columns
SELECT 
    AVG(math_score) AS avg_math_score,
    AVG(reading_score) AS avg_reading_score,
    AVG(writing_score) AS avg_writing_score,
    MIN(math_score) AS min_math_score,
    MAX(math_score) AS max_math_score
FROM student_performance;

-- 5.4 Analyze Categorical Data (Gender and Parental Education Level)
SELECT gender, COUNT(*) AS count 
FROM student_performance
GROUP BY gender;

SELECT parental_level_of_education, COUNT(*) AS count 
FROM student_performance
GROUP BY parental_level_of_education;

-- 5.5 Correlation Analysis (Correlation between different scores)
SELECT 
    CORR(math_score, reading_score) AS math_reading_corr,
    CORR(math_score, writing_score) AS math_writing_corr,
    CORR(reading_score, writing_score) AS reading_writing_corr
FROM student_performance;

-- Step 6: Data Analysis
-- 6.1 Average Scores by Gender
SELECT 
    gender, 
    AVG(math_score) AS avg_math,
    AVG(reading_score) AS avg_reading,
    AVG(writing_score) AS avg_writing
FROM student_performance
GROUP BY gender;

-- 6.2 Impact of Test Preparation Course on Scores
SELECT 
    test_preparation_course, 
    AVG(math_score) AS avg_math,
    AVG(reading_score) AS avg_reading,
    AVG(writing_score) AS avg_writing
FROM student_performance
GROUP BY test_preparation_course;

-- 6.3 Performance by Parental Education Level
SELECT 
    parental_level_of_education,
    AVG(math_score) AS avg_math,
    AVG(reading_score) AS avg_reading,
    AVG(writing_score) AS avg_writing
FROM student_performance
GROUP BY parental_level_of_education
ORDER BY avg_math DESC;

-- 6.4 Identify Top Performers (students scoring above 90 in all subjects)
SELECT *
FROM student_performance
WHERE math_score > 90 AND reading_score > 90 AND writing_score > 90;

-- Step 7: Connect Snowflake to Power BI for Visualization

-- 1. Open Power BI Desktop.
-- 2. Click on "Get Data" from the Home ribbon.
-- 3. Select "Snowflake" from the list of available data sources.
-- 4. In the "Snowflake" connection window, enter the following connection details:
--    - Server: Your Snowflake account URL (e.g., xy12345.snowflakecomputing.com)
--    - Warehouse: student_perf_wh
--    - Database: student_analysis_db
--    - Schema: public
-- 5. Once connected, you can load the data from the `student_performance` table directly into Power BI.
-- 6. From here, you can create dashboards, charts, and reports based on your analysis.

-- No need to run a SQL export, Power BI will retrieve data in real-time from Snowflake.

-- After connecting Power BI to Snowflake, you can:
-- 1. Use the Query Editor to filter and transform the data.
-- 2. Create various visualizations like bar charts, pie charts, scatter plots, etc.
-- 3. Build reports and dashboards with your analysis results.
