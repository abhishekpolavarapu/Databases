DECLARE
v_pname project.pname%type;
v_pnumber project.pnumber%type;
v_plocation project.plocation%type;
v_dlocation varchar2(35);
v_ptype varchar2(6);
v_emp_type varchar2(15);
v_thours number(6,2);
dlocation varchar2(6);
v_user_name varchar2(15);
v_insert_number number;

cursor proj is
select pname,pnumber,plocation,dlocation from project left join dept_locations on dnum=dnumber and plocation=dlocation;

cursor tcost is
select w.pno ,sum(hours*salary/2000) from employee e,works_on w where e.ssn=w.essn group by pno;

BEGIN
v_insert_number :=1;
open proj;
loop
fetch proj into v_pname,v_pnumber,v_plocation,v_dlocation;
exit when proj%notfound;
if (v_plocation=v_dlocation)then
v_ptype :='LOCAL';
else
v_ptype :='REMOTE';
end if;

for v_num_emp in (select count(w.essn) as local from employee e,works_on w,project p where e.ssn=w.essn and w.pno=p.pnumber and e.address like '%'||p.plocation||'%' and p.pnumber=v_pnumber)
loop
for v_thours in (select sum(hours) as local from employee e,works_on w,project p where e.ssn=w.essn and w.pno=p.pnumber and e.address like '%'||p.plocation||'%' and p.pnumber=v_pnumber)
loop
if v_thours.local IS NULL then
v_thours.local :=0 ;
end if;
for v_tcost in (select sum(hours*salary/2000) as local from employee e,works_on w,project p where e.ssn=w.essn and w.pno=p.pnumber and e.address like '%'||p.plocation||'%' and p.pnumber=v_pnumber)
loop
if v_tcost.local IS NULL then
v_tcost.local := 0;
end if;
v_user_name:='apolavar';
v_emp_type :='LOCAL';
ibl.ins_proj_summary(v_pname,v_pnumber,v_plocation,v_ptype,v_emp_type,v_num_emp.local,v_thours.local,v_tcost.local,v_user_name,v_insert_number);
v_insert_number :=v_insert_number + 1;
end loop;
end loop;
end loop;
for v_num_emp in (select count(w.essn) as nonlocal from employee e,works_on w,project p where e.ssn=w.essn and w.pno=p.pnumber and e.address not like '%'||p.plocation||'%' and p.pnumber=v_pnumber)
loop
for v_thours in (select sum(hours) as nonlocal from employee e,works_on w,project p where e.ssn=w.essn and w.pno=p.pnumber and e.address not like '%'||p.plocation||'%' and p.pnumber=v_pnumber)
loop
if v_thours.nonlocal IS NULL then
v_thours.nonlocal :=0;
end if;
for v_tcost in (select sum(hours*salary/2000) as nonlocal from employee e,works_on w,project p where e.ssn=w.essn and w.pno=p.pnumber and e.address not like '%'||p.plocation||'%' and p.pnumber=v_pnumber)
loop
if v_tcost.nonlocal IS NULL then
v_tcost.nonlocal :=0;
end if;
v_user_name:='apolavar';
v_emp_type :='NON-LOCAL';
ibl.ins_proj_summary(v_pname,v_pnumber,v_plocation,v_ptype,v_emp_type,v_num_emp.nonlocal,v_thours.nonlocal,v_tcost.nonlocal,v_user_name,v_insert_number);
v_insert_number :=v_insert_number + 1;
end loop;
end loop;
end loop;
for v_num_emp in (select count(w.essn) as manager from works_on w inner join (select distinct mgrssn from department)s on s.mgrssn=w.essn where w.pno=v_pnumber)
loop
for v_thours in (select sum(hours) as manager from works_on w inner join (select distinct mgrssn from department)s on s.mgrssn=w.essn where w.pno=v_pnumber)
loop
if v_thours.manager IS NULL then
v_thours.manager :=0;
end if;
for v_tcost in (select sum(hours*salary/2000) as manager from employee e,works_on w inner join (select distinct mgrssn from department)s on s.mgrssn=w.essn where w.pno=v_pnumber and e.ssn=s.mgrssn)
loop
if v_tcost.manager IS NULL then
v_tcost.manager :=0;
end if;
v_user_name:='apolavar';
v_emp_type :='MANAGER';
ibl.ins_proj_summary(v_pname,v_pnumber,v_plocation,v_ptype,v_emp_type,v_num_emp.manager,v_thours.manager,v_tcost.manager,v_user_name,v_insert_number);
v_insert_number :=v_insert_number + 1;
end loop;
end loop;
end loop;
for v_num_emp in (select count(superssn) as supervisor from works_on w inner join (select distinct superssn from employee)s on s.superssn=w.essn where w.pno=v_pnumber)
loop
for v_thours in (select sum(hours) as supervisor from works_on w inner join (select distinct superssn from employee)s on s.superssn=w.essn where w.pno=v_pnumber)
loop
if v_thours.supervisor IS NULL then
v_thours.supervisor :=0;
end if;
for v_tcost in (select sum(hours*salary/2000) as supervisor from employee e,works_on w inner join (select distinct superssn from employee)s on s.superssn=w.essn where w.pno=v_pnumber and e.ssn=s.superssn)
loop
if v_tcost.supervisor IS NULL then
v_tcost.supervisor :=0;
end if;
v_user_name:='apolavar';
v_emp_type :='SUPERVISOR';
ibl.ins_proj_summary(v_pname,v_pnumber,v_plocation,v_ptype,v_emp_type,v_num_emp.supervisor,v_thours.supervisor,v_tcost.supervisor,v_user_name,v_insert_number);
v_insert_number :=v_insert_number + 1;
end loop;
end loop;
end loop;
for v_num_emp in (select count(e.ssn) as dept from employee e ,works_on w ,project p where e.ssn=w.essn and w.pno=p.pnumber and e.dno=p.dnum and p.pnumber=v_pnumber)
loop
for v_thours in (select sum(hours) as dept from employee e ,works_on w ,project p where e.ssn=w.essn and w.pno=p.pnumber and e.dno=p.dnum and p.pnumber=v_pnumber)
loop
if v_thours.dept IS NULL then
v_thours.dept :=0;
end if;
for v_tcost in (select sum(hours*salary/2000) as dept from employee e ,works_on w ,project p where e.ssn=w.essn and w.pno=p.pnumber and e.dno=p.dnum and p.pnumber=v_pnumber)
loop
if v_tcost.dept IS NULL then
v_tcost.dept :=0;
end if;
v_user_name:='apolavar';
v_emp_type:='DEPT';
ibl.ins_proj_summary(v_pname,v_pnumber,v_plocation,v_ptype,v_emp_type,v_num_emp.dept,v_thours.dept,v_tcost.dept,v_user_name,v_insert_number);
v_insert_number :=v_insert_number + 1;
end loop;
end loop;
end loop;
for v_num_emp in(select count(w.essn) as nondept from employee e ,works_on w ,project p where e.ssn=w.essn and w.pno=p.pnumber and e.dno<>p.dnum and p.pnumber=v_pnumber)
loop
for v_thours in (select sum(hours) as nondept from employee e ,works_on w ,project p where e.ssn=w.essn and w.pno=p.pnumber and e.dno<>p.dnum and p.pnumber=v_pnumber)
loop
if v_thours.nondept IS NULL then
v_thours.nondept :=0;
end if;
for v_tcost in (select sum(hours*salary/2000) as nondept from employee e ,works_on w ,project p where e.ssn=w.essn and w.pno=p.pnumber and e.dno<>p.dnum and p.pnumber=v_pnumber)
loop
if v_tcost.nondept IS NULL then
v_tcost.nondept :=0;
end if;
v_user_name:='apolavar';
v_emp_type:='NON-DEPT';
ibl.ins_proj_summary(v_pname,v_pnumber,v_plocation,v_ptype,v_emp_type,v_num_emp.nondept,v_thours.nondept,v_tcost.nondept,v_user_name,v_insert_number);
v_insert_number :=v_insert_number + 1;
end loop;
end loop;
end loop;

end loop;
close proj;
end;
/