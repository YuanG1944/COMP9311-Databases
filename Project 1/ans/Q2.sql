create or replace view Hemma_courses AS
select c.id 
from courses c, course_enrolments ce
where ce.course = c.id and
      ce.student =
      (select id from people where name = 'Hemma Margareta');
      
create or replace view Q2(unswid, name) AS
select distinct p.unswid, p.name
from course_staff cs, people p, Hemma_courses h
where h.id = cs.course and
      cs.staff = p.id;



---staff id
---course_staff course staff role
---people id unswid name

---选出河马这货上的所有课程
---把所有课程的staff选出来