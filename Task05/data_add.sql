PRAGMA foreign_keys = ON;
-- 1. Добавляем 5 новых пользователей (себя и 4 соседей)
INSERT INTO users (name, email, gender, occupation) VALUES 
('Валерия Житина', 'lera@example.com', 'F', 'student'),
('Иван Иванов', 'ivan@example.com', 'M', 'student'),
('Мария Петрова', 'maria@example.com', 'F', 'student'),
('Алексей Смирнов', 'alex@example.com', 'M', 'student'),
('Екатерина Попова', 'kate@example.com', 'F', 'student');t');

-- 2. Добавляем 3 новых фильма разных жанров
-- Сначала добавим сами жанры в справочник
INSERT INTO genres (name) VALUES ('Action'), ('Comedy'), ('Drama'), ('Sci-Fi');

-- Добавляем фильмы
INSERT INTO movies (title, year) VALUES 
('Новый Боевик', 2024),
('Новая Комедия', 2023),
('Новая Драма', 2022);

-- Связываем фильмы с жанрами (используем подзапросы, чтобы не зависеть от ID)
INSERT INTO movie_genres (movie_id, genre_id) 
SELECT m.id, g.id FROM movies m, genres g WHERE m.title = 'Новый Боевик' AND g.name = 'Action';

INSERT INTO movie_genres (movie_id, genre_id) 
SELECT m.id, g.id FROM movies m, genres g WHERE m.title = 'Новая Комедия' AND g.name = 'Comedy';

INSERT INTO movie_genres (movie_id, genre_id) 
SELECT m.id, g.id FROM movies m, genres g WHERE m.title = 'Новая Драма' AND g.name = 'Drama';

-- 3. Добавляем 3 новых отзыва от СЕБЯ на добавленные фильмы
-- Используем подзапросы, чтобы найти ID себя и ID фильмов (зависимость от идентификаторов исключена)
INSERT INTO ratings (user_id, movie_id, rating, timestamp) 
SELECT u.id, m.id, 5.0, strftime('%s', 'now')
FROM users u, movies m 
WHERE u.email = 'your_email@example.com' AND m.title = 'Новый Боевик';

INSERT INTO ratings (user_id, movie_id, rating, timestamp) 
SELECT u.id, m.id, 4.5, strftime('%s', 'now')
FROM users u, movies m 
WHERE u.email = 'your_email@example.com' AND m.title = 'Новая Комедия';

INSERT INTO ratings (user_id, movie_id, rating, timestamp) 
SELECT u.id, m.id, 3.5, strftime('%s', 'now')
FROM users u, movies m 
WHERE u.email = 'your_email@example.com' AND m.title = 'Новая Драма';