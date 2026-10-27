PRAGMA foreign_keys = ON;

-- Удаляем старые таблицы, если были
DROP TABLE IF EXISTS ratings;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS movie_genres;
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS genres;
DROP TABLE IF EXISTS users;

-- 1. Пользователи (нормализация профессий не нужна, оставляем текстом, но добавляем ограничения)
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL, -- Требование: не может быть двух одинаковых email
    gender TEXT CHECK(gender IN ('M', 'F')), -- Требование: пол только М или Ж
    register_date TEXT DEFAULT (date('now')), -- Значение по умолчанию - текущая дата
    occupation TEXT
);

-- 2. Фильмы
CREATE TABLE movies (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    year INTEGER
);

-- 3. Жанры (Справочник для 3НФ)
CREATE TABLE genres (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL
);

-- 4. Связь фильмов и жанров (многие-ко-многим)
CREATE TABLE movie_genres (
    movie_id INTEGER,
    genre_id INTEGER,
    PRIMARY KEY (movie_id, genre_id),
    FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genres(id) ON DELETE CASCADE
);

-- 5. Оценки (Рейтинги)
CREATE TABLE ratings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    movie_id INTEGER,
    rating REAL CHECK(rating >= 0 AND rating <= 5), -- Требование: рейтинг от 0 до 5
    timestamp INTEGER,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE, -- Требование: удаление пользователя = удаление отзывов
    FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE RESTRICT -- Требование: нельзя удалить фильм, если есть отзывы
);

-- 6. Теги
CREATE TABLE tags (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    movie_id INTEGER,
    tag TEXT,
    timestamp INTEGER,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (movie_id) REFERENCES movies(id) ON DELETE CASCADE
);

-- Создание индексов (Требование: ускорение поиска по фамилиям, названиям и годам)
CREATE INDEX idx_users_name ON users(name);
CREATE INDEX idx_movies_title ON movies(title);
CREATE INDEX idx_movies_year ON movies(year);