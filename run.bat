@echo off

set "PROJECT_DIR=%cd%"

set "CONTAINER_NAME=nba-container"

docker rm -f "%CONTAINER_NAME%" > nul 2>&1

docker build -t nba-image .

docker run -it -v "%PROJECT_DIR%:/app" --name "%CONTAINER_NAME%" nba-image
