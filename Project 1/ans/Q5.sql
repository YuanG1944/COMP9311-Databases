---course_enrolments  student, course, mark, grade, stueval
---courses  id, subject (subject id), semester, homepage
---semesters  id, unswid, year, term, name
---subjects  id, code, name

---建表:包含学期的课程表
create or replace view courses_with_mark_withlower as
select c.id, c.subject, crl.mark, s.code, s.name as s_name, sem.name as sem_name 
from ((courses c
        inner join course_enrolments crl
            on c.id = crl.course)
                inner join subjects s
                    on c.subject = s.id)
                        inner join semesters sem
                              on c.semester = sem.id;

---建表:包含学期的课程表(分数>20个)
create or replace view courses_with_mark as
select b.*
from (select id, subject, count(mark) m 
      from courses_with_mark_withlower
      group by id, subject
      having count(mark) >= 20) t,
      courses_with_mark_withlower b
where b.id = t.id;

---每门课每学期最高的分数表大到小排列
create or replace view course_max_mark_order as
select * 
from        
(select * from courses_with_mark where mark is not null order by mark desc) as b
order by b.sem_name;


---每门课每学期最高的分数表
create or replace view course_max_mark as
select distinct b.* 
from (select id, max(mark) m from courses_with_mark where mark is not null GROUP BY id) t,
     courses_with_mark b 
where t.id = b.id and 
      t.m = b.mark
order by sem_name;

---每学期最高分最低的课程的分数表
create or replace view semester_lowest as
select distinct b.*
from (select sem_name, min(mark) m from course_max_mark GROUP BY sem_name) t,
     course_max_mark b
where t.sem_name = b.sem_name and
      t.m = b.mark;

---每学期最高分中最低的课程的code和名字还有学期名
create or replace view q5 as
select code, s_name, sem_name
from semester_lowest;
