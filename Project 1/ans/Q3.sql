---所有国际学生
create or replace view international_student AS
select id 
from students 
where stype = 'intl';

---学生选课学期成绩表
create or replace view choose_courses AS
select crl.student, crl.grade, crl.mark, s.code, c.semester 
from (courses c
        inner join course_enrolments crl
            on c.id = crl.course)
                inner join subjects s
                    on c.subject = s.id;

---9311拿hd的国际学生的id和学期
create or replace view  stu_31_hd_idS 
select distinct c.student, p.name, p.unswid, c.semester
from choose_courses c, international_student i, people p
where c.code = 'COMP9311' and
      c.grade = 'HD' and
      c.student = i.id and
      p.id = c.student;

---9311拿hd的国际学生的id和学期
create or replace view stu_24_hd_id AS 
select distinct c.student, p.name, p.unswid, c.semester
from choose_courses c, international_student i, people p
where c.code = 'COMP9024' and 
      c.grade = 'HD' and
      c.student = i.id and
      p.id = c.student;

---上9311和9024并拿到HD的国际学生
create or replace Q3 AS
select unswid, name
from 
    ((select *
        from stu_24_hd_id)
    intersect 
    (select * 
        from stu_31_hd_id)) as a1;


---学生 students id stype
---课程主体subjects id, code, name COMP9311 COMP9024
---学期semesters id, unswid, year, term, name, 
---课courses id, subject, semester
---人people id, unswid, name
---注册课程course_enrolments student, courese, mark, grade

---先选国际学生
---在同学期的9311/9024
---在同一学期选9311,9024的学生的id
---俩都考hd学生的unswid和name