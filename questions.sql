rem Authors : Abhishek Polavarapu <apolavar>
rem SQL Assignment, Fall 2015.

rem Question 1. Retrieve the first names of dependents who are
rem dependents of employees who work onany project in Houston.Also show
rem the name of the employee, the name of the employee's department,the
rem number of houston projects the employee works on. Show results in
rem ascending alpha order (by dependent_name and then lname).
rem Column Headings: DEPENDENT_NAME FNAME LNAME DNAME NUM_PROJ
select distinct dependent_name,fname,lname,dname,num_proj
from
(select dependent_name,fname,lname,dname,essn
from department
outer join
(select dependent_name,fname,lname,essn,pno,dno
from employee
outer join
(select essn,dependent_name,pno
from dependent outer join
(select essn ssn,pno from works_on
outer join
(select pnumber from project where plocation='Houston')a
on pno=a.pnumber)b
on essn=b.ssn)c
on ssn=essn)d
on dnumber=d.dno)e,
(select essn,count(pno) num_proj from works_on 
outer join
(select pnumber from project where plocation='Houston')a
on pno=a.pnumber
group by essn)f
where e.essn=f.essn order by dependent_name,lname asc;


rem Question 2. Retrieve the name and number of departments which
rem have employees who do not work on at least one project.Show results
rem in ascending alpha order. (NOTE: a department should appear on this
rem list if it has an employee who does not work on any project at
rem all.) 
rem Column Headings: DNAME DNUMBER
select distinct dname,dnumber from department,
(select ssn,dno,dname as n from employee,department where employee.dno=department.dnumber
minus 
select essn,dnumber,dname from works_on,employee,department where employee.ssn=works_on.essn
and department.dnumber=employee.dno)b
where dnumber=b.dno
order by dname asc;

rem Question 3. For each department, list the department name and
rem the total number of hours assigned to projects controlled by the
rem department (irrespective of the employee to whom they are assigned)
rem and the total number of hours assigned to employees of the
rem department (irrespective of the project involved). Show results in
rem ascending alpha order. 
rem Column Headings: DNAME PROJ_HRS EMP_HRS
select dname,proj_hrs,emp_hrs 
from 
(select dnumber,dname,sum(hours) as proj_hrs 
from ((works_on join project on pno=pnumber)
join department on dnumber=dnum)
group by dnumber,dname)a,
(select dno,sum(hours) emp_hrs 
from ((employee join works_on on ssn=essn)
join department on dnumber=dno)
group by dno)b
where a.dnumber=b.dno order by dname asc;

rem Question 4. Retrieve the first and last names of any employees
rem who work on every company project. Show results in ascending alpha
rem order (by last name and then first name). [Note that an employee
rem should be on the list if and only if he or she works on every
rem project.]
rem Column Headings: FNAME LNAME
select fname,lname from employee,works_on,project where 
employee.ssn=works_on.essn and works_on.pno=project.pnumber group by fname,lname having
count(pnumber)=(select count(pnumber) from project)
order by lname,fname asc;

rem Question 5. Retrieve the first and last names of employees who
rem work on projects which are not controlled by their departments.Also
rem show the names of the projects,the employee's department number,and
rem the number of the project's controlling department. (All of this
rem should be shown in the same result table.) Show results in
rem ascending alpha order (by last name and then first name
rem and then project name). 
rem Column Headings: FNAME LNAME PNAME E_DNUM P_DNUM
select fname,lname,pname,dno as e_dnum,dnum as p_dnum from 
(select fname,lname,pname,dnum,dno from project,
(select * from employee,works_on where employee.ssn=works_on.essn)a
where project.pnumber=a.pno)b where dnum<>dno
order by lname,fname,pname asc;

rem Question 6. Retrieve the name and number of the project which
rem uses the most employees. Also show the total number of employees for
rem that project. If there is more than one project that has attained
rem that maximum, list them all. Show results in ascending alpha order. 
rem Column Headings: PNAME PNUMBER E_TOTAL
select pname,pnumber,count(essn)  E_total 
from project join works_on on pnumber=pno
group by pname,pnumber
having count(essn) = (select max(no_emp) e_total from
(select pname,pnumber,count(essn) no_emp 
from project join works_on on pnumber=pno
group by pnumber,pname)a) order by pname asc;

rem Question 7. Do any departments have a location in which they
rem have no projects? Retrieve the names of departments which have at
rem least one location which is not the same as any of the locations of
rem the department's projects. Show results in ascending alpha order.
rem [This means that one department location is different from every
rem location of every project of that department.] 
rem Column Headings: DNAME
select dname 
from
(select dnumber,dlocation from dept_locations
minus
select dnumber,plocation  dlocation 
from project,dept_locations
where dnumber=dnum)a
join department d on d.dnumber= a.dnumber
order by dname asc;

rem Question 9. List the names of dependents who have the same
rem first name as an employee of whom they are not the dependent.Also
rem show the ssn of the employee with the same first name and the ssnof
rem the employee on whom the dependent is dependent (dependent.essn).
rem (All of this should be shown in the same table.) Show results in
rem ascending alpha order. 
rem Column Headings: DEPENDENT_NAME NON_PATRON PATRON
select dependent_name,ssn non_patron,essn patron
from (employee cross join dependent)
where fname=dependent_name and ssn<>essn order by dependent_name asc;    
   
rem Question 10. Retrieve the first and last names of employees
rem whose supervisor works on any project outside the employee's
rem department. Show results in ascending alpha order (by last name and
rem then first name). [Note that you are to retrieve the employee's
rem name, not the supervisor's.]
rem Column Headings: FNAME LNAME
select distinct fname,lname
from ((employee join works_on on ssn=essn)
join project on pnumber=pno)
where ssn in
(select ssn from employee where superssn<>ssn)
order by lname,fname asc;

rem Question 12. DEPARTMENTS.
rem Write a query of the Oracle data dictionary that will retrieve the
rem column names, data types, and data lengths of the table
rem IBL.DEPARTMENT. You may NOT use 'describe' (or 'desc') for this
rem answer. Your query must begin with SELECT.Show results in ascending
rem alpha order of column name.
rem Column Headings: COLNAME DTYPE DLENGTH
select COLUMN_NAME COLNAME,DATA_TYPE DTYPE,DATA_LENGTH DLENGTH
from ALL_TAB_COLUMNS
where table_name='DEPARTMENT' order by COLNAME asc;

rem Question 13. PRIMARY KEY. Write a query which retrieves the
rem columns in the primary key of IBL.DEPENDENT from the Oracle data
rem dictionary. It will help to know that 'CONSTRAINTS' is sometimes
rem abbreviated 'CONS' in the data dictionary table/view names.NOTE:you
rem query cannot contain the words'essn','ssn',or 'dependent_name'.Show
rem results in ascending alpha order of column name.
rem Column Headings: COLNAME
select COLUMN_NAME COLNAME 
from ALL_CONS_COLUMNS a, ALL_CONSTRAINTS b
where a.TABLE_NAME like 'DEPENDENT'
and b.CONSTRAINT_TYPE = 'P'
and a.CONSTRAINT_NAME = b.CONSTRAINT_NAME order by COLNAME asc;

rem Question 14. FOREIGN KEY.
rem Write a query which retrieves from the Oracle data dictionary the
rem names of all the tables in the IBL account that contain a foreign
rem key pointing to the IBL.DEPARTMENT table. It may help to know that
rem'CONSTRAINTS' is sometimes abbreviated 'CONS' in the data dictionary
rem table/view names. Show results in ascending alpha order by table
rem name.
rem Column Headings: TABLE_NAME
select TABLE_NAME from ALL_CONSTRAINTS
where R_CONSTRAINT_NAME in 
(select CONSTRAINT_NAME from ALL_CONSTRAINTS
where TABLE_NAME ='DEPARTMENT'
and CONSTRAINT_TYPE = 'P')
order by TABLE_NAME asc;

