#!/bin/bash
powershell -File make_db_init.ps1
sqlite3 movies_rating.db < db_init.sql