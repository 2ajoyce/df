#!/bin/bash
# Start a loop that copies the containers save file back to local every minute
while [ 1 -le 10 ]
do
    echo Running docker cp df:/opt/dwarffortress/df_linux/data data/
    docker cp df:/opt/dwarffortress/df_linux/data/ data/
    sleep 1m
done