---建表
create or replace view cwsws as
select c.id as course, c.subject, s.code, sem.id, sem.term, sem.name, sem.year
from (courses c
            join subjects s
                    on c.subject = s.id)
                        join semesters sem
                              on c.semester = sem.id
where s.code like 'COMP93%' and
      sem.starting >= '2004-01-01' and
      sem.ending < '2014-01-01'; 

---2004-2013所有major term
create or replace view courses_sem as
select a.*
from
(select id, year, term, name
from semesters
where starting >= '2004-01-01' and
      ending <= '2013-12-31') as a 
where a.term = 'S1' or
      a.term = 'S2'
order by a.id;

---每学期都有课的comp93 id
create or replace view all_term_comp as
select distinct a.subject
from cwsws a
where not exists
((select c.year, term
        from courses_sem c)
except
(select b.year, term from cwsws b
where b.subject = a.subject)
);

create or replace view all_course_term_comp as
select a.course, a.subject, a.code, a.id
from cwsws a,
     all_term_comp b
where a.subject = b.subject;


---交表出成绩
create or replace view c_and_m as
select crl.student, crl.course, c.subject, c.code, crl.mark
from (all_course_term_comp c
        join course_enrolments crl
            on c.course = crl.course)
where crl.mark is not null and 
      crl.mark < 50;

---两门课都挂科的学生
create or replace view both_fial as
select distinct a.student
from c_and_m a
where not exists
((select c.subject
        from all_term_comp c)
except
(select b.subject from c_and_m b
where b.student = a.student)
);

---学生unswid和姓名
create or replace view Q8(zid, name) as
select CONCAT('z',p.unswid), p.name
from both_fial b,
     people p
where b.student = p.id;