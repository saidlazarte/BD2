-- Pregunta 1
SELECT id, title
 FROM movie
 WHERE yr=1962;
-- Pregunta 2
SELECT yr
FROM movie
WHERE title = 'Citizen Kane';
-- Pregunta 3
select id, title, yr
From movie
where  title like 'Star Trek%'
order by yr;
-- Pregunta 4
select id 
from actor 
where name='Glenn Close';
-- Pregunta 5
 select id 
from movie
where title = 'Casablanca';
-- Pregunta 6
select a.name
from casting c left join actor a on c.actorid = a.id
where movieid=11768;
-- Pregunta 7
select name
from casting c left join actor a on c.actorid = a.id
where movieid = 10522;
-- Pregunta 8
select title from casting c left join movie m on c.movieid = m.id
where actorid = (select id from actor where name = 'Harrison Ford');
-- Pregunta 9
select m.title
from movie m
join casting c on m.id =c.movieid
join actor a on c.actorid = a.id
where a.name = 'Harrison Ford' and c.ord !=1;
-- Pregunta 10
select m.title, a.name
from movie m
join casting c on m.id =c.movieid
join actor a on c.actorid = a.id
where yr = 1962 and c.ord=1;
-- Pregunta 11
SELECT yr,COUNT(title) FROM
  movie JOIN casting ON movie.id=movieid
        JOIN actor   ON actorid=actor.id
WHERE name='Rock Hudson'
GROUP BY yr
HAVING COUNT(title) > 2;
-- Pregunta 12 
select title, name
from movie join casting on (movieid=movie.id and ord=1)
join actor on (actorid=actor.id)
where movie.id in (
SELECT movieid FROM casting
WHERE actorid IN (
  SELECT id FROM actor
  WHERE name='Julie Andrews'));
-- Pregunta 13
SELECT a.name
FROM actor a
JOIN casting c ON a.id = c.actorid
WHERE c.ord = 1
GROUP BY a.id, a.name
HAVING COUNT(*) >= 15
ORDER BY a.name;
-- Pregunta 14
SELECT m.title,count(c.actorid) AS actor_count
FROM movie m
JOIN casting c ON m.id = c.movieid
WHERE m.yr = 1978
GROUP BY m.id, m.title
ORDER BY  actor_count DESC,m.title ASC;
-- Pregunta 15
select name
from movie join casting on (movieid=movie.id)
join actor on (actorid=actor.id)
where movie.id in (
SELECT movieid FROM casting
WHERE actorid IN (
  SELECT id FROM actor
  WHERE name='Art Garfunkel')
AND name != 'Art Garfunkel');