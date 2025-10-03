select * from employees
where hire_date>=add_months(sysdate,-12*20)
and salary>(select avg(salary) from employees);


select e.* from employees e
where e.salary*1.2+500 in (select round(avg(salary)) from employees
                           group by department_id);

      select emp.first_name,
             emp.last_name,
             his.end_date
        from employees emp 
	join job_history his
        using(employee_id,job_id);

 select emp.first_name,
             emp.last_name,
             his.end_date
        from employees emp 
	join job_history his
    on emp.employee_id=his.employee_id
    and emp.job_id=his.job_id;
    

select c.country_name, sum(e.salary) from employees e
join departments d 
on e.department_id=d.department_id
join locations l
on l.location_id=d.location_id
join countries c
on l.country_id=c.country_id
where e.salary between 2000 and 6000
group by c.country_name
fetch first 2 rows with ties;


	*Əgər işçinin maaşı öz departamentinin ortalama maaşının 35%-dən azdırsa, maaşı ikiqat artırılacaq.
	*Əgər işçinin maaşı öz departamentinin ortalama maaşının 35%-dən yuxarı 90%-dən aşağıdırsa, maaşı 50% artırılacaq.
	*Əgər işçinin maaşı öz departamentinin ortalama maaşının 90%-dən yuxarıdırsa, maaşı olduğu kimi qalacaq.  
select e.employee_id,e.salary,d.avg_salary,
       case when e.salary<d.avg_salary*0.35 then  e.salary*2
            when e.salary<d.avg_salary*0.35 and e.salary<d.avg_salary*0.9 then  e.salary*1.5
            else e.salary
       end as yeni_maash
from employees e
join(select department_id,avg(salary) as avg_salary
     from employees
     group by department_id )d 
     on e.department_id=d.department_id;
     
select e.employee_id,e.salary,e.department_id from employees e;
       case when salary<(select avg(salary) from employees where department_id=e.department_id)*0.35 then salary*2
            when salary>=(select avg(salary) from employees where department_id=e.department_id)*0.35
                and salary<(select avg(salary) from employees where department_id=e.department_id)*0.9 then salary*1.5
            else salary
       end as yeni_maash;
       
       


