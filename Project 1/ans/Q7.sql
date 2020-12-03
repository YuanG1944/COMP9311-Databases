---course_enrolments  student, course, mark, grade, stueval
---courses id, subject, semester, homepage
---semesters  id, unswid, year, term, name, longname, starting, ending
---subjects  id, code, name

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

create or replace view q7(year, term, average_mark) as
select year, term, cast(avg(mark) as numeric(4,2))
from courses_with_mark_sem
group by year, term;