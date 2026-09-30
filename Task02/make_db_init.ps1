$outFile = "db_init.sql"

if (Test-Path $outFile) { Remove-Item $outFile }

$header = @"
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS ratings;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS users;

CREATE TABLE movies (
    id INTEGER PRIMARY KEY,
    title TEXT,
    year INTEGER,
    genres TEXT
);

CREATE TABLE ratings (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    movie_id INTEGER,
    rating REAL,
    timestamp INTEGER
);

CREATE TABLE tags (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    movie_id INTEGER,
    tag TEXT,
    timestamp INTEGER
);

CREATE TABLE users (
    id INTEGER PRIMARY KEY,
    name TEXT,
    email TEXT,
    gender TEXT,
    register_date TEXT,
    occupation TEXT
);
"@
$header | Out-File -FilePath $outFile -Encoding utf8

# Функция для экранирования одинарных кавычек
function Escape-Sql($str) {
    return $str -replace "'", "''"
}

# --- Обработка movies.csv ---
Write-Host "Processing movies.csv..."
$lines = Get-Content "movies.csv"
for ($i = 1; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $parts = $line -split ','
    $id = $parts[0]
    $title = Escape-Sql $parts[1]
    $year = 0
    if ($parts[1] -match '\((\d{4})\)') { $year = $matches[1] }
    $genres = Escape-Sql ($parts[2..($parts.Count-1)] -join ',')
    "INSERT INTO movies (id, title, year, genres) VALUES ($id, '$title', $year, '$genres');" | Out-File -FilePath $outFile -Append -Encoding utf8
}

Write-Host "Processing ratings.csv..."
$lines = Get-Content "ratings.csv"
for ($i = 1; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $parts = $line -split ','
    $sql = "INSERT INTO ratings (id, user_id, movie_id, rating, timestamp) VALUES ($($parts[0]), $($parts[1]), $($parts[2]), $($parts[3]), $($parts[4]));"
    $sql | Out-File -FilePath $outFile -Append -Encoding utf8
}

Write-Host "Processing tags.csv..."
$lines = Get-Content "tags.csv"
for ($i = 1; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $parts = $line -split ','
    $tag = Escape-Sql $parts[3]
    $sql = "INSERT INTO tags (id, user_id, movie_id, tag, timestamp) VALUES ($($parts[0]), $($parts[1]), $($parts[2]), '$tag', $($parts[4]));"
    $sql | Out-File -FilePath $outFile -Append -Encoding utf8
}

Write-Host "Processing users.txt..."
$lines = Get-Content "users.txt"
for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    $parts = $line -split '\|'
    if ($parts.Count -lt 6) { continue }
    $name = Escape-Sql $parts[1]
    $email = Escape-Sql $parts[2]
    $occ = Escape-Sql $parts[5]
    $sql = "INSERT INTO users (id, name, email, gender, register_date, occupation) VALUES ($($parts[0]), '$name', '$email', '$($parts[3])', '$($parts[4])', '$occ');"
    $sql | Out-File -FilePath $outFile -Append -Encoding utf8
}

Write-Host "Done! File $outFile created."