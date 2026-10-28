chcp 65001
.\sqlite3 movies_rating.db < db_init.sql
echo "1. Составить список фильмов..."
echo --------------------------------------------------
.\sqlite3 movies_rating.db -box -echo "SELECT DISTINCT m.title, m.year FROM movies m JOIN ratings r ON m.id = r.movie_id ORDER BY m.year ASC, m.title ASC LIMIT 10;"
echo " "
echo "2. Вывести список всех пользователей..."
echo --------------------------------------------------
.\sqlite3 movies_rating.db -box -echo "SELECT name, register_date FROM users WHERE name LIKE 'A%%' OR name LIKE '%% A%%' ORDER BY register_date ASC LIMIT 5;"
echo " "
echo "3. Напишите запрос..."
echo --------------------------------------------------
.\sqlite3 movies_rating.db -box -echo "SELECT u.name, m.title, m.year, r.rating, strftime('%%Y-%%m-%%d', r.timestamp, 'unixepoch') AS date FROM ratings r JOIN users u ON r.user_id = u.id JOIN movies m ON r.movie_id = m.id ORDER BY u.name ASC, m.title ASC, r.rating ASC LIMIT 50;"
echo " "
echo "4. Вывести список фильмов с тегами..."
echo --------------------------------------------------
.\sqlite3 movies_rating.db -box -echo "SELECT m.title, m.year, t.tag FROM tags t JOIN movies m ON t.movie_id = m.id ORDER BY m.year ASC, m.title ASC, t.tag ASC LIMIT 40;"
echo " "
echo "5. Вывести список самых свежих фильмов..."
echo --------------------------------------------------
.\sqlite3 movies_rating.db -box -echo "SELECT title, year FROM movies WHERE year = (SELECT MAX(year) FROM movies);"
echo " "
echo "6. Найти все комедии..."
echo --------------------------------------------------
.\sqlite3 movies_rating.db -box -echo "SELECT m.title, m.year, MAX(r.rating) as max_rating FROM movies m JOIN ratings r ON m.id = r.movie_id JOIN users u ON r.user_id = u.id WHERE m.year > 2000 AND m.genres LIKE '%%omedy%%' AND u.gender = 'M' AND r.rating >= 4.5 GROUP BY m.id;"
echo " "
echo "7. Провести анализ популярности..."
echo --------------------------------------------------
.\sqlite3 movies_rating.db -box -echo "SELECT occupation, COUNT(*) as visits FROM users GROUP BY occupation ORDER BY visits DESC;"
echo " "
