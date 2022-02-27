#!/bin/bash

docker kill $(docker ps -q)

IFS=$'\n' read -d '' -r -a lines < ./resources.txt

for i in "${lines[@]}"
do
   echo "$i"
   export URL=$i
    if [ -n "$1" ]
    then
    docker run --platform linux/amd64 -d  alpine/bombardier -c $1 -d 60000h -l $URL
    else
    docker run --platform linux/amd64 -d  alpine/bombardier -c 300 -d 60000h -l $URL
    fi
 done
