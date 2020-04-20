#!/bin/bash
#pierwszy argument to nazwa katalogu z programami z rozszerzeniem *.c
#drugi argument to nazwa pliku z wejsciem do programu
#trzeci argument to nazwa pliku z poprawnym wyjsciem
array=()
while IFS= read -r -d $'\0'; do
	array+=($REPLY)
done < <(find "$1" -mindepth 1 -maxdepth 1 -type f -print0)
touch tmpfile
for i in "${array[@]}"
do
	echo $i | cut -d / -f2 | cut -d . -f1>>tmpfile
done
names=()
while IFS= read -r -d $'\n'; do
	names+=($REPLY)
done < <(cat tmpfile)
rm tmpfile
if [ ! -d result ]
then
mkdir result
fi
for i in "${!array[@]}"
do
	gcc "${array[$i]}" -o tmp 2>tmperr
	if [ -s tmperr ]
	then
		echo "compilation error" > result/"${names[$i]}"
	else 
		./tmp < "$2" >tmpresult
		diff -s -y -b -E "$3" tmpresult >result/"${names[$i]}"
		rm tmp
	fi	
done
rm tmpresult
if [ -f tmperr ]
then
rm tmperr
fi
