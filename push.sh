#!/bin/sh

timestamp=`date "+%Y-%m-%d %H:%M:%S"` 
if [ $# == 1 ]
then
  timestamp=$1 
fi
echo "名字：$timestamp"
git add . 
git commit -m "$timestamp" 
git push 

