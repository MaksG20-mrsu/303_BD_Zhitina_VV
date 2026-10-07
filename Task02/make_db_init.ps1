$outFile = "db_init.sql"
if (Test-Path $outFile) { Remove-Item $outFile }

function Escape-Sql($str) {
    if ($null -eq $str) { return "" }
    return $str -replace "'", "''"
}

$header = @"
DROP TABLE IF EXISTS movies;
DROP TABLE IF EXISTS ratings;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS users;

CREATE TABLE movies (id INTEGER PRIMARY KEY, title TEXT, year INTEGER, genres TEXT);
CREATE TABLE ratings (id INTEGER PRIMARY KEY, user_id INTEGER, movie_id INTEGER, rating REAL, timestamp INTEGER);
CREATE TABLE tags (id INTEGER PRIMARY KEY, user_id INTEGER, movie_id INTEGER, tag TEXT, timestamp INTEGER);
CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, email TEXT, gender TEXT, register_date TEXT, occupation TEXT);
"@
$header | Out-File -FilePath $outFile -Encoding utf8

Write-Host "Processing movies.csv..."
$movies = Import-Csv "movies.csv"
$counter = 1
foreach ($row in $movies) {
    $year = 0
    if ($row.title -match '\((\d{4})\)') { $year = $matches[1] }
    $t = Escape-Sql $row.title
    $g = Escape-Sql $row.genres
    "INSERT INTO movies (id, title, year, genres) VALUES ($counter, '$t', $year, '$g');" | Out-File -FilePath $outFile -Append -Encoding utf8
    $counter++
}

Write-Host "Processing ratings.csv..."
$ratings = Import-Csv "ratings.csv"
$counter = 1
foreach ($row in $ratings) {
    "INSERT INTO ratings (id, user_id, movie_id, rating, timestamp) VALUES ($counter, $($row.userId), $($row.movieId), $($row.rating), $($row.timestamp));" | Out-File -FilePath $outFile -Append -Encoding utf8
    $counter++
}

Write-Host "Processing tags.csv..."
$tags = Import-Csv "tags.csv"
$counter = 1
foreach ($row in $tags) {
    $t = Escape-Sql $row.tag
    "INSERT INTO tags (id, user_id, movie_id, tag, timestamp) VALUES ($counter, $($row.userId), $($row.movieId), '$t', $($row.timestamp));" | Out-File -FilePath $outFile -Append -Encoding utf8
    $counter++
}

Write-Host "Processing users.txt..."
Get-Content "users.txt" | ForEach-Object {
    if ([string]::IsNullOrWhiteSpace($_)) { return }
    $parts = $_ -split '\|'
    if ($parts.Count -lt 6) { return }
    $n = Escape-Sql $parts[1]
    $e = Escape-Sql $parts[2]
    $o = Escape-Sql $parts[5]
    "INSERT INTO users (id, name, email, gender, register_date, occupation) VALUES ($($parts[0]), '$n', '$e', '$($parts[3])', '$($parts[4])', '$o');" | Out-File -FilePath $outFile -Append -Encoding utf8
}

Write-Host "Done! File $outFile created."