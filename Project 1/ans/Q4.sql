---  student, course, grade, mark
-- select distinct grade, mark 
-- from course_enrolments
-- where mark is null;  ---空值表达法

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
---大于平均值的人数
create or replace view q4(num_student) AS
select count(h.student)
from HDnum_of_each_stu h, avg_HDnum av
where h.numHD >= av.HD_avg;
