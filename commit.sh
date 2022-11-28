#!/bin/bash
if test $# -eq 0 
then
	echo "commit.sh: Meteme el mensaje para el comit entre comillas dobles \"\" "
	exit
else	
	if test $# -gt 1
		then
			echo "demasiados argumentos"
			exit
	fi
fi

echo $1
#git add -A
#git commit -m $1
#git branch -M main
#git remote add origin https://github.com/vendul0g/xv6.git
#git push -u origin main
