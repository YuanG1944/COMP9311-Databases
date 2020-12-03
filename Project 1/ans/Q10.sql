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

---unswid,longname,num,rank
create or replace view q10 as 
select distinct b.unswid, b.longname, a.num, a.rank
from lecture_theatre_num2 a
left join 
    q10_class_room b
on a.room = b.room
order by num desc;

