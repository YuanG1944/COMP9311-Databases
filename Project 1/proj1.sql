-- comp9311 19T3 Project 1
--
-- MyMyUNSW Solutions


-- Q1:
create or replace view Q1(unswid, longname) as
SELECT DISTINCT r.unswid, r.longname 
FROM rooms r, facilities f, room_facilities rf
WHERE f.description = 'Air-conditioned' and
      rf.room = r.id and
      rf.facility = f.id;
--... SQL statements, possibly using other views/functions defined by you ...

-- Q2:
create or replace view Hemma_courses AS
select c.id 
from courses c, course_enrolments ce
where ce.course = c.id and
      ce.student =
      (select id from people where name = 'Hemma Margareta');

create or replace view Q2(unswid,name) as
select distinct p.unswid, p.name
from course_staff cs, people p, Hemma_courses h
where h.id = cs.course and
      cs.staff = p.id;
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q3:
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
create or replace view stu_31_hd_id as
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

create or replace view Q3(unswid, name) as
select unswid, name
from 
    ((select *
        from stu_24_hd_id)
    intersect 
    (select * 
        from stu_31_hd_id)) as a1;

--... SQL statements, possibly using other views/functions defined by you ...

-- Q4:
---每个学生的HD数量
create or replace view HDnum_of_each_stu(student, numHD) AS     
select student, count(grade) 
from course_enrolments
where grade = 'HD'  
group by student;

---至少有一门课有分的学生的数量
create or replace view havegrade_stu AS
select distinct student 
      from course_enrolments 
      where mark is not null;
---总表
create or replace view total_stu as
select h.student, hd.numHD
from havegrade_stu h
        left join HDnum_of_each_stu hd
            on h.student = hd.student;

--------update total_stu set numHD = COALESCE(NULLIF(numhd, null), 0);
---拿HD的平均值
create or replace view avg_HDnum(HD_avg) AS 
select (select sum(numHD) 
        from total_stu) / (select count(student) 
                           from total_stu) as HD_avg;

create or replace view Q4(num_student) as
select count(h.student)
from HDnum_of_each_stu h, avg_HDnum av
where h.numHD >= av.HD_avg;
--... SQL statements, possibly using other views/functions defined by you ...

--Q5:
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

create or replace view Q5(code, name, semester) as
select code, s_name, sem_name
from semester_lowest;


--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q6:
---先选local students
create or replace view local_student AS
select distinct p.id 
from people p, students s 
where s.stype = 'local' and
      p.id = s.id;

---做programs, streams的连表
create or replace view ps_jion AS
select perl.student, perl.semester, s.name, s.offeredby as s_offeredby, p.offeredby as p_offeredby

from ((Stream_enrolments setl
        inner join program_enrolments perl
            on perl.id = setl.partof)
                inner join Streams s
                    on setl.stream = s.id)
                        inner join programs p
                            on p.id = perl.program;
     
---在10s1选了management的local students     
create or replace view course_manage as
select distinct ps.student 
from ps_jion ps, local_student l
where ps.semester = 
                (select id from semesters where year = 2010 and term = 'S1') and
      ps.name = 'Management' and
      l.id = ps.student;

---所有在Faculty of Engineering 上过课的学生
create or replace view course_offeredby as
select distinct crl.student
from (courses c
        inner join course_enrolments crl
            on c.id = crl.course)
                inner join subjects s
                    on c.subject = s.id
where s.offeredby = (select id from OrgUnits where name = 'Faculty of Engineering');

create or replace view Q6(num) as
select count(a.*)
from 
((select distinct student
from course_manage)
except
(select student
from course_offeredby)) as a;

--... SQL statements, possibly using other views/functions defined by you ...

-- Q7:
---连表
create or replace view courses_with_mark_sem as
select crl.student, crl.course, c.subject, s.name, crl.mark, sem.id, sem.term, sem.year
from ((courses c
        inner join course_enrolments crl
            on c.id = crl.course)
                inner join subjects s
                    on c.subject = s.id)
                        inner join semesters sem
                              on c.semester = sem.id
where crl.mark is not null and
      s.name = 'Database Systems';
create or replace view Q7(year, term, average_mark) as
select year, term, cast(avg(mark) as numeric(4,2))
from courses_with_mark_sem
group by year, term;
--... SQL statements, possibly using other views/functions defined by you ...

-- Q8: 
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

create or replace view Q8(zid, name) as
select CONCAT('z',p.unswid), p.name
from both_fial b,
     people p
where b.student = p.id;
--... SQL statements, possibly using other views/functions defined by you ...
;

-- Q9:
create or replace view q9_s_course as
select crl.student, crl.course, crl.mark, sem.id, sem.term, sem.year, c.subject, s.uoc
from ((courses c
        inner join course_enrolments crl
            on c.id = crl.course)
                    inner join semesters sem
                        on c.semester = sem.id)
                            inner join subjects s
                                on s.id = c.subject
where crl.mark is not null and
      sem.year < 2011;

create or replace view q9_s_program as
select distinct pr.student, pr.program, p.uoc, sem.id as p_sem
from ((program_enrolments pr
    inner join semesters sem 
        on sem.id = pr.semester)
            inner join program_degrees pd
                on pd.program = pr.program)
                    inner join programs p
                        on p.id = pr.program
where pd.abbrev = 'BSc' and
      sem.year < 2011;

create or replace view q9stu_1 as 
select distinct b.student
from (select distinct student
      from q9_s_course
      where year = 2010 and
            term = 'S2' and
            mark >= 50) as a
inner join q9_s_program b
on b.student = a.student;

create or replace view q9stu_2 as
select distinct a.*
from q9stu_1 b,
     q9_s_course a
where a.student = b.student and
      mark >= 50;

create or replace view q9_student_pass2 as
select distinct q.*
from 
    (select student, round(avg(mark), 2) as avg_mark
    from q9stu_2
    group by student
    having avg(mark) >= 80) as a,
    q9stu_2 q
where a.student = q.student;

create or replace view q9_student_pass3 as
select distinct a.*
from q9_s_program a,
     q9_student_pass2 b
where a.student = b.student;

create or replace view q9_student_pass4 as
select a.*, b.p_sem, b.program
from q9_student_pass2 a,
     q9_student_pass3 b
where a.student = b.student and
      a.id = b.p_sem;


create or replace view q9_student_uoc as
select distinct student, sum(uoc) as sum_uoc, program
from q9_student_pass4
group by student, program;

create or replace view stu_id as
select distinct a.student, a.sum_uoc, b.uoc, b.program
from q9_student_uoc a,
     q9_s_program b
where a.student = b.student and 
      a.program = b.program
order by student;

create or replace view stu_finish as
select distinct b.student
from
    (select student, count(program) as c1
    from stu_id
    where sum_uoc >= uoc
    group by student) as a,
    (select student, count(program) as c2
    from stu_id
    group by student) as b
where a.c1 = b.c2 and
      a.student = b.student;

create or replace view Q9(unswid, name) as
select p.unswid, p.name
from stu_finish a,
     people p
where a.student = p.id;
--... SQL statements, possibly using other views/functions defined by you ...

-- Q10:
---连表
create or replace view q10_class_room0 as
select cs.course, cs.room, cs.id as class
FROM 
(classes cs
    INNER JOIN courses c
        ON cs.course = c.id) 
            INNER JOIN semesters sem
                ON sem.id = c.semester
where 
      sem.year = 2011 and
      sem.term = 'S1';

---所有lecture theatre
create or replace view lecture_theatre as
select distinct r.id as room, r.unswid, r.longname
from rooms r
 INNER JOIN room_types ry 
    ON ry.id = r.rtype
where ry.description = 'Lecture Theatre';

create or replace view q10_class_room as
select l.* , q.course, q.class
from lecture_theatre l
 left JOIN q10_class_room0 q
    ON l.room = q.room;


create or replace view lecture_theatre_num as
select distinct a.room, coalesce(b.num,0) as num
from lecture_theatre a
left join 
    (select room, count(class) as num
    from q10_class_room 
    group by room) as b
on a.room = b.room
order by num desc;

create or replace view lecture_theatre_num2 as
select 
    room,
    num,
    Rank() over(order by num desc) as rank
    from
    lecture_theatre_num;

create or replace view Q10(unswid, longname, num, rank) as
select distinct b.unswid, b.longname, a.num, a.rank
from lecture_theatre_num2 a
left join 
    q10_class_room b
on a.room = b.room
order by num desc;
--... SQL statements, possibly using other views/functions defined by you ...
