
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

create or replace view q9 as
select p.unswid, p.name
from stu_finish a,
     people p
where a.student = p.id;