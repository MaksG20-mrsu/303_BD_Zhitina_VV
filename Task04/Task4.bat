chcp 65001

.\sqlite3 movies_rating.db < db_init.sql

echo "1. Найти всех пар пользователей, наблюдавших один и тот же фильм. Устранить дубликаты, проверить отсутствие пар с самим собой. Для каждой пары должны быть указаны имена пользователей и название фильма, который они оценили. В списке оставить первые 100 записей."
echo --------------------------------------------------
.\sqlite3 movies_rating.db -box -echo "SELECT DISTINCT u1.name AS user1, u2.name AS user2, m.title FROM ratings r1 JOIN ratings r2 ON r1.movie_id = r2.movie_id AND r1.user_id < r2.user_id JOIN users u1 ON r1.user_id = u1.id JOIN users u2 ON r2.user_id = u2.id JOIN movies m ON r1.movie_id = m.id LIMIT 100;"
echo " "

echo "2. Найдите 10 самых последних оценок от разных пользователей, выведите название фильмов, имена пользователей, оценку, отметки отзыва в формате ГГГГ-ММ-ДД."
echo --------------------------------------------------
.\sqlite3 movies_rating.db -box -echo "SELECT m.title, u.name, r.rating, strftime('%Y-%m-%d', r.timestamp, 'unixepoch') AS date FROM ratings r JOIN users u ON r.user_id = u.id JOIN movies m ON r.movie_id = m.id GROUP BY r.user_id ORDER BY r.timestamp DESC LIMIT 10;"
echo " "

echo "3. Выведите в один список все фильмы с максимальным рейтингом и все фильмы с высоким рейтингом. Общий список отсортировать по году выпуска и названию фильма. В зависимости от рейтинга в колонке «Рекомендуем» для фильмов должно быть написано «Да» или «Нет»."
echo --------------------------------------------------
.\sqlite3 movies_rating.db -box -echo "WITH MaxRatings AS (SELECT movie_id, MAX(rating) as max_r FROM ratings GROUP BY movie_id) SELECT m.title, m.year, mr.max_r, CASE WHEN mr.max_r >= 4.5 THEN 'Да' ELSE 'Нет' END as 'Рекомендуем' FROM movies m JOIN MaxRatings mr ON m.id = mr.movie_id WHERE mr.max_r = (SELECT MAX(rating) FROM ratings) OR mr.max_r >= 4.5 ORDER BY m.year ASC, m.title ASC LIMIT 50;"
echo " "

echo "4. Вычислить количество оценок и более высокую оценку, которые дали фильмам пользователи-женщины в период с 2010 по 2012 год."
echo --------------------------------------------------
.\sqlite3 movies_rating.db -box -echo "SELECT COUNT(*) as count_ratings, MAX(r.rating) as max_rating FROM ratings r JOIN users u ON r.user_id = u.id WHERE u.gender = 'F' AND strftime('%Y', r.timestamp, 'unixepoch') BETWEEN '2010' AND '2012';"
echo " "

echo "5. Составить список фильмов с указанием их средней оценки и места в рейтинге средней категории. Полученный список отсортировать по году выпуска и названиям фильмов. В списке оставить первые 20 записей."
echo --------------------------------------------------
.\sqlite3 movies_rating.db -box -echo "WITH AvgRatings AS (SELECT movie_id, AVG(rating) as avg_r FROM ratings GROUP BY movie_id) SELECT m.title, m.year, ar.avg_r, RANK() OVER (ORDER BY ar.avg_r DESC) as rank FROM movies m JOIN AvgRatings ar ON m.id = ar.movie_id ORDER BY m.year ASC, m.title ASC LIMIT 20;"
echo " "

echo "6. Вывести список из 10 последних зарегистрированных пользователей в формате 'Имя Фамилия|Регистрация данных' (сначала фамилия, потом имя)."
echo --------------------------------------------------
.\sqlite3 movies_rating.db -box -echo "SELECT SUBSTR(name, INSTR(name, ' ') + 1) || ' ' || SUBSTR(name, 1, INSTR(name, ' ') - 1) || '|' || register_date AS 'Формат' FROM users ORDER BY register_date DESC LIMIT 10;"
echo " "

echo "7. С помощью рекурсивного CTE таблицы умножения чисел от 1 до 10. Должен получиться один столбец следующего вида:"
echo --------------------------------------------------
.\sqlite3 movies_rating.db -box -echo "WITH RECURSIVE mult(a, b) AS (SELECT 1, 1 UNION ALL SELECT CASE WHEN b < 10 THEN a ELSE a + 1 END, CASE WHEN b < 10 THEN b + 1 ELSE 1 END FROM mult WHERE a <= 10) SELECT a || 'x' || b || '=' || (a * b) AS result FROM mult WHERE a <= 10 LIMIT 100;"
echo " "

echo "8. С помощью рекурсивного CTE выделить все жанры фильмов, заведя в таблицу фильмы (каждый жанр в отдельной строке)."
echo --------------------------------------------------
.\sqlite3 movies_rating.db -box -echo "WITH RECURSIVE split(movie_id, genre, rest) AS (SELECT id, '', genres || '|' FROM movies UNION ALL SELECT movie_id, SUBSTR(rest, 0, INSTR(rest, '|')), SUBSTR(rest, INSTR(rest, '|') + 1) FROM split WHERE rest <> '') SELECT movie_id, genre FROM split WHERE genre <> '' LIMIT 40;"
echo " "