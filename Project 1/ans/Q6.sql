---orgunits  id, utype, name, longname, unswid, phone, email, website, starting, ending
---program_enrolments  id, student, semester, program
---programs  id, code, name, uoc, offeredby
---semesters  id, unswid, year, term
---stream_enrolments  partof, stream
---streams id, code, name, offeredby, stype, description

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

---10s1选了management的local students但是没在Faculty of Engineering
create or replace view Q6(num) AS
select count(a.*)
from 
((select distinct student
from course_manage)
except
(select student
from course_offeredby)) as a;



