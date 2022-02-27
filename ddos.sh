docker rm -f $(docker ps -a -q)
docker rmi -f $(docker images -q)

IFS=$'\n' read -d '' -r -a lines < ./resources.txt

for i in "${lines[@]}"
do
   echo "$i"
   export URL=$i
   docker run --platform linux/amd64 -d  alpine/bombardier -c 300 -d 60000h -l $URL
 done
