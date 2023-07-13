Create Database hr;

USE hr;
SELECT * From hr;

-- cleaning and pre-processing the dataset
describe hr;

alter table hr
change column ï»¿id emp_id varchar(20) Null;

set sql_safe_updates =0;


-- changing the date format of birthdate, termdate and hire_date
update hr
Set birthdate = CASE
     WHEN birthdate like "%/%" then date_format(str_to_date(birthdate, "%m/%d/%Y"),"%Y-%m-%d")
     WHEN birthdate like "%-%" then date_format(str_to_date(birthdate, "%m-%d-%Y"),"%Y-%m-%d")
     else null
end;     
alter table hr	
Modify column birthdate date;

update hr
SET hire_date = CASE
    WHEN hire_date like "%/%" then date_format(str_to_date(hire_date,"%m/%d/%Y"),"%Y-%m-%d")
    WHEN hire_date like "%-%" then date_format(str_to_date(hire_date,"%m-%d-%Y"),"%Y-%m-%d")
    else null
end;
alter table hr
modify column hire_date date ;
    
update hr
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
where termdate is not null and termdate != '';
update hr
set termdate = NULL
where termdate = '';
alter table hr
modify column termdate date;


-- create new column age 
alter table hr
add column age int;
update hr
set age = timestampdiff(Year,birthdate,curdate());

Select min(age) , max(age) from hr ;

-- Let us frame some questions so as to find the answers and get some insights from the data using MS Power Bi software.

-- 1. What is the gender breakdown of the employees in the company
select gender , count(*) as Count
from hr
where termdate is null
group by gender;

-- 2. What is the race breakdown of the employees in the company
select race, count(*) as Count
from hr
where termdate is null
group by race;

-- 3. What is the age distribution of the employees in the company
select 
      CASE
          when age >=18 and age<= 24 then "18-24"
          when age >=25 and age<= 34 then "25-34"
          when age >=35 and age<= 44 then "35-44"
          when age >=45 and age<= 54 then "45-54"
          when age >=55 and age<= 64 then "55-64"
          else "65+"
	  end as age_group,
             count(*) as count
from hr
where termdate is null
group by age_group
order by age_group;
       
-- 4. How many employees work from the HQ and how many remotely
select location, Count(*) as Count
from hr
where termdate is null
group by location;

-- 5. What is the average length of employement of the employees who have been terminated
select round(Avg(year(termdate) - year(hire_date)),0) as avg_length_of_employement
from hr
where termdate is not null and termdate <= curdate();

-- 6. How does the gender distribution vary across dept and job titles
select gender, jobtitle, department, count(*) as Count 
from hr
where termdate is not null
group by gender, jobtitle, department
order by count desc;

-- 7. What is the distribution of job titles across the company
Select jobtitle, count(*) as Count
from hr
where termdate is not null
group by jobtitle
order by count desc;

-- 8. Which dept has the higher termination rate
select department,
	   count(*) as total_count,
       Count( CASE
			  When termdate is not null and termdate <= curdate() then 1
			  end) as termination_count,
	    Round((count(CASE
					 WHen termdate is not null and termdate <= curdate() then 1
					 end)/Count(*))*100,2) as termination_rate
from hr
group by department
order by termination_rate desc;
 
 -- 9.What is the dist of employees across location's state and city
Select location_state, count(*) as Count
from hr
where termdate is null
group by location_state
order by count desc;

Select location_city, count(*) as Count
from hr
where termdate is null
group by location_city
order by count desc;

-- 10. How much has the employee count changed from hire date to termination date
Select * from hr;
Select year,
       hires,
       terminations,
       hires - terminations AS net_change,
       (terminations/hires)*100 AS change_percent
	From(
       Select year(hire_date) as year,
       count(*) as hires,
       sum(CASE
               when termdate is not null and termdate <= curdate() then 1 
			end) as terminations
        from hr
	    group by year(hire_date) ) as subquery
group by year
order by year ;

-- 11. What is the tenure distribution for each dept
select department, round(avg(datediff(termdate,hire_date)/365),0) as avg_tenure
from hr
where termdate is not null and termdate <= curdate()
group by department;

-- 12(a). Termination and hire breakdown gender wise
Select gender, total_hires, total_terminations,
round((total_terminations/total_hires)*100,2) as termination_rate
     from(
          Select gender,
				Count(*) as total_hires,
				Count(CASE
                      When termdate is not null and termdate <= curdate() then 1
	 end) as total_terminations
	 from hr
     group by gender) AS SUBQUERY
group by gender;
    
-- 12(b). Termination and hire breakdown age wise
Select age, total_hires, total_terminations,
round((total_terminations/total_hires)*100,2) as termination_rate
     from(
          Select age,
				Count(*) as total_hires,
				Count(CASE
                      When termdate is not null and termdate <= curdate() then 1
	 end) as total_terminations
	 from hr
     group by age) AS SUBQUERY
group by age;
    
-- 12(c). Termination and hire breakdown department wise
Select department, total_hires, total_terminations,
round((total_terminations/total_hires)*100,2) as termination_rate
     from(
          Select department,
				Count(*) as total_hires,
				Count(CASE
                      When termdate is not null and termdate <= curdate() then 1
	 end) as total_terminations
	 from hr
     group by department) AS SUBQUERY
group by department;
    
-- 12(d). Termination and hire breakdown race wise
Select race, total_hires, total_terminations,
round((total_terminations/total_hires)*100,2) as termination_rate
     from(
          Select race,
				Count(*) as total_hires,
				Count(CASE
                      When termdate is not null and termdate <= curdate() then 1
	 end) as total_terminations
	 from hr
     group by race) AS SUBQUERY
group by race;