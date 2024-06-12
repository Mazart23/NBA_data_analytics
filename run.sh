#!/bin/bash

PROJECT_DIR=$(pwd)

CONTAINER_NAME="nba-container"

docker rm -f "$CONTAINER_NAME" > /dev/null 2>&1

docker build -t nba-image .

docker run -it -v "$PROJECT_DIR:/app" --name "$CONTAINER_NAME" nba-image