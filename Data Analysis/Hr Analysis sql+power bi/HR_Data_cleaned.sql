USE projects;

SELECT * FROM hr;

# Rename id column to emp_id
ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id VARCHAR(20) NULL;

# Check data types of all columns
DESCRIBE hr;

SELECT birthdate FROM hr;

SET sql_safe_updates = 0;

# To date, convert birthdate values
# In this code, we use the LIKE operator to first determine whether the value has a forward slash, or "/." If so, we convert the value to the '%Y-%m-%d' format using the STR_TO_DATE() and DA TE_FORMAT() functions, assuming the format is '%m/%d/%Y'. When a dash '-' appears, we presume the format is '%m-%d-%y' and change the value to '%Y-%m-%d'. The birthday value is set to NULL if the value does not fit either format.
# It should be noted that the value is converted to the '%Y-%m-%d' format, which is the default MySQL date format, using the DATE_FORMAT() function. If you prefer a different date format, you can modify the format string in the DATE_FORMAT() function to suit your unique requirements.
UPDATE hr
SET birthdate = CASE
	WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

# Change birthdate column datatype
ALTER TABLE hr
MODIFY COLUMN birthdate DATE;

# Convert hire_date values to date
UPDATE hr
SET hire_date = CASE
	WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

SELECT termdate FROM hr;

# Convert termdate values to date and remove time
UPDATE hr
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate != '';

# Convert termdate column to date
ALTER TABLE hr
MODIFY COLUMN termdate date;

# Change hire_date column data type
ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

SELECT termdate FROM hr;

# Add age column
ALTER TABLE hr ADD COLUMN age INT;
UPDATE hr
SET age = timestampdiff(YEAR, birthdate, CURDATE());

SELECT 
	min(age) AS Youngest,
    max(age) AS Oldest
FROM hr;

SELECT count(*) FROM hr WHERE age < 18;

SELECT birthdate, age FROM hr;


-- QUESTIONS

-- 1. What is the gender breakdown of employees in the company?
SELECT gender, count(*) AS Count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?
SELECT race, count(*) AS Count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY race
ORDER BY Count DESC;

-- 3. What is the age distribution of employees in the company?
SELECT 
	min(age) AS Youngest,
    max(age) AS Oldest
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00';

SELECT 
	CASE 
		WHEN age >= 18 AND age <= 24 THEN '18-24'
        WHEN age >= 25 AND age <= 34 THEN '25-34'
        WHEN age >= 35 AND age <= 44 THEN '35-44'
        WHEN age >= 45 AND age <= 54 THEN '45-54'
        WHEN age >= 55 AND age <= 64 THEN '55-64'
        ELSE '65+'
	END AS Age_Group,
    count(*) as Count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY Age_Group
ORDER BY Age_Group;

SELECT 
	CASE 
		WHEN age >= 18 AND age <= 24 THEN '18-24'
        WHEN age >= 25 AND age <= 34 THEN '25-34'
        WHEN age >= 35 AND age <= 44 THEN '35-44'
        WHEN age >= 45 AND age <= 54 THEN '45-54'
        WHEN age >= 55 AND age <= 64 THEN '55-64'
        ELSE '65+'
	END AS Age_Group, gender,
    count(*) as Count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY Age_Group, gender
ORDER BY Age_Group, gender;

-- 4. How many employees work at headquarters versus remote locations?
SELECT location, COUNT(*) as count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY location;


-- 5. What is the average length of employment for employees who have been terminated?
SELECT ROUND(AVG(DATEDIFF(termdate, hire_date))/365,0) AS avg_length_of_employment
FROM hr
WHERE termdate <> '0000-00-00' AND termdate <= CURDATE() AND age >= 18;



-- 6. How does the gender distribution vary across departments and job titles?
SELECT department, gender, COUNT(*) as count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY department, gender
ORDER BY department;

-- 7. What is the distribution of job titles across the company?
SELECT jobtitle, COUNT(*) as count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY jobtitle
ORDER BY jobtitle DESC;

-- 8. Which department has the highest turnover rate?
SELECT department,
	total_count,
    terminated_count,
    terminated_count/total_count AS termination_rate
FROM(
	SELECT department,
    count(*) AS total_count,
    SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminated_count
    FROM hr
    WHERE age >= 18
    GROUP BY department
    ) AS subquery
ORDER BY termination_rate DESC;
    

-- 9. What is the distribution of employees across locations by state?
SELECT location_state, COUNT(*) as count
FROM hr
WHERE age >= 18 AND termdate = '0000-00-00'
GROUP BY location_state
ORDER BY count DESC;

-- 10. How has the company's employee count changed over time based on hire and term dates?
SELECT 
    year, 
    hires, 
    terminations, 
    (hires - terminations) AS net_change,
    ROUND(((hires - terminations) / hires * 100), 2) AS net_change_percent
FROM(
    SELECT 
        YEAR(hire_date) AS year, 
        COUNT(*) AS hires, 
        SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= CURDATE() THEN 1 ELSE 0 END) AS terminations
    FROM 
        hr
    WHERE age >= 18
    GROUP BY 
        YEAR(hire_date)
	) subquery
ORDER BY year ASC;
        
        
	

-- 11. What is the tenure distribution for each department?
SELECT department, ROUND(AVG(DATEDIFF(CURDATE(), termdate)/365),0) as avg_tenure
FROM hr
WHERE termdate <= CURDATE() AND termdate <> '0000-00-00' AND age >= 18
GROUP BY department