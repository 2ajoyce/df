#!/bin/bash

echo Building Docker Image
docker build . -t df 

echo Initializing the docker image
docker run -it --name df df

echo Restarting the docker image
docker start df

echo Copying local save file into docker container
docker cp data/ df:/opt/dwarffortress/df_linux/

echo "Exec into the container to start playing (run ./df)"
winpty docker exec -it df bash