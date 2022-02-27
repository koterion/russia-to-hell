@echo off
set arg1=%1
for /f "tokens=*" %%s in (resources.txt) do (
	if (%arg1% == '') docker run -d --rm alpine/bombardier -c 300 -d 60000h -l %%s
  else docker run -d --rm alpine/bombardier -c %arg1% -d 60000h -l %%s
)
pause
