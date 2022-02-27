@echo off

docker kill $(docker ps -q)

for /f "tokens=*" %%s in (resources.txt) do (
	docker run -d --rm alpine/bombardier -c 100 -d 60000h -l %%s
)
pause
