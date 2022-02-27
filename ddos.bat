@echo off

docker rm -f $(docker ps -a -q)
docker rmi -f $(docker images -q)

for /f "tokens=*" %%s in (resources.txt) do (
	docker run -d --rm alpine/bombardier -c 300 -d 60000h -l %%s
)
pause
