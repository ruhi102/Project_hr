CREATE Database project;
Use project;
select * from hr;

-- data cleaning
-- change title for id
ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id varchar(20) null;

-- get summary of data
DESCRIBE hr;

SELECT birthdate from hr;

-- allow workbench to be altered
set sql_safe_updates=0;

-- Modify the date to have this format YYYY-MM-DD
alter table hr
modify column birthdate date;
UPDATE hr
set birthdate = case
	when birthdate like '%/%' then date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
	when birthdate like '%-%' then date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
else null
end;

SELECT birthdate from hr;

-- modify the hore-date column to this format YYYY-MM-DD
UPDATE hr
set hire_date = case
	when hire_date like '%/%' then date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
	when hire_date like '%-%' then date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
else null
end;

-- convert the hire_date as date
alter table hr
modify column hire_date DATE;

SELECT hire_date from hr;

-- set the date in column termdate to have dates and fill out areas where the date is null or 
-- incorrect format
UPDATE hr
SET termdate = date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL AND termdate !=' ';


SELECT termdate from hr;

-- convert the termdate as date
alter table hr
modify column termdate DATE;

ALTER TABLE hr ADD column age INT;

SELECT * FROM hr;

-- find the age of employees based on their birth date and subtract from the current date
UPDATE hr
SET age = timestampdiff(YEAR, birthdate, CURDATE());

SELECT birthdate, age FROM hr;

SELECT MIN(age) as youngest, MAX(age) as oldest from hr;

SELECT COUNT(*) FROM hr where age < 18;
SELECT COUNT(*) FROM hr where termdate = '0000-00-00';

-- 1. What is the gender breakdown of employees in the company?
SELECT gender, COUNT(*) AS COUNT
FROM hr
where age >= 18 and termdate = '0000-00-00'
GROUP BY gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?
SELECT race, COUNT(*) as COUNT from hr
where age >= 18 and termdate = '0000-00-00'
GROUP BY race ORDER BY COUNT(*) DESC;

-- 3. What is the age distribution of employees in the company?
SELECT MIN(age) as YOUNGEST, MAX(age) as OLDEST 
from hr where age >= 18 and termdate = '0000-00-00';

SELECT 
	CASE 
		WHEN age >= 18 and age <=24 THEN '18-24'
        WHEN age >= 25 and age <=34 THEN '25-34'
        WHEN age >= 35 and age <=44 THEN '35-44'
        WHEN age >= 45 and age <=54 THEN '45-54'
        WHEN age >= 55 and age <=64 THEN '55-64'
        ELSE '65+'
	END AS age_group,
    count(*) as count
FROM hr
where age >= 18 and termdate = '0000-00-00'
GROUP BY age_group
ORDER BY age_group;

SELECT 
	CASE 
		WHEN age >= 18 and age <=24 THEN '18-24'
        WHEN age >= 25 and age <=34 THEN '25-34'
        WHEN age >= 35 and age <=44 THEN '35-44'
        WHEN age >= 45 and age <=54 THEN '45-54'
        WHEN age >= 55 and age <=64 THEN '55-64'
        ELSE '65+'
	END AS age_group, gender,
    count(*) as count
FROM hr
where age >= 18 and termdate = '0000-00-00'
GROUP BY age_group, gender
ORDER BY age_group, gender;

-- 4. How many employees work at headquarters versus remote locations?
SELECT location, COUNT(*) from hr where age >= 18 and termdate = '0000-00-00'
GROUP BY location;

-- 5. What is the average length of employment for employees who have been terminated?
SELECT round(avg(datediff(termdate, hire_date))/365,0) as term from hr where termdate <= curdate() and  age >= 18 and termdate <> '0000-00-00';

-- 6. How does the gender distribution vary across departments and job titles?
SELECT gender, department, count(*) as count from hr where
age >= 18 and termdate = '0000-00-00'
group by gender, department
order by department
;

-- 7. What is the distribution of job titles across the company?
SELECT jobtitle, count(*) as count from hr where age >= 18 and termdate = '0000-00-00'
group by jobtitle
order by jobtitle desc
;

-- 8. Which department has the highest turnover rate?
SELECT department,
	total_count,
    terminated_count,
    terminated_count/total_count as termination_rate
FROM (
	SELECT department,
    count(*) AS total_count,
    SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminated_count
    FROM hr
    where age >= 18
    GROUP BY department)
    AS subquery
ORDER BY termination_rate DESC;

-- 9. What is the distribution of employees across locations by city and state?

SELECT location_state, count(*) as count from hr where age >= 18 and termdate = '0000-00-00'
group by location_state
order by count desc;

-- 10. How has the company's employee count changed over time based on hire and term dates?

SELECT 
	year,
    hires, 
    terminations,
    hires-terminations as net_change,
    round((hires-terminations)/hires * 100, 2) as net_change_percent
FROM (
	SELECT YEAR(hire_date) as year,
    count(*) as hires,
    SUM(CASE WHEN termdate <> '0000-00-00' AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminations
    FROM hr
    where age >= 18
    GROUP BY YEAR(hire_date)
	) as subquery
order by year ASC;

-- 11. What is the tenure distribution for each department?
SELECT department, round(avg(datediff(termdate, hire_date)/365),0) as avg_tenure
FROM hr
WHERE termdate <> '0000-00-00' AND termdate <= curdate() AND age >= 18
Group by department;