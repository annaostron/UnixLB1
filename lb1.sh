#!/bin/bash
read -p "Please enter date (yyyy-mm-dd): " new_date
if [[ $new_date = $(date -d "$new_date" +%Y-%m-%d) ]]; then
d=$(date -d "$new_date" +%Y-%m-%d) 
touch ./dateFiles/$d.txt
date "+%T" > ./dateFiles/$d.txt
else echo "Wrong date format"
fi


