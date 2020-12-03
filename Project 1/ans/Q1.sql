create or replace view Q1 AS
SELECT DISTINCT r.unswid, r.longname 
FROM rooms r, facilities f, room_facilities rf
WHERE f.description = 'Air-conditioned' and
      rf.room = r.id and
      rf.facility = f.id;
