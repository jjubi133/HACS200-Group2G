#!/bin/bash

#argument 1 will be the filename desired for the altered log and argument 2 will be the logfile
touch $1

echo ">>>ALL LINES INCLUDING WGET<<<\n" > $1
grep "wget" $2 >> $1

echo ">>>ALL LINES INCLUDING CURL<<<\n" > $1
grep "curl" $2 >> $1

echo ">>>ALL LINES INCLUDING INSTALL<<<\n" > $1
grep "install" $2 > $1

echo ">>>ALL LINES INCLUDING LS<<<\n" > $1
grep "ls" $2 > $1

echo ">>>ALL LINES INCLUDING CAT<<<\n" > $1
grep "cat" $2 > $1

echo ">>>ALL LINES INCLUDING CD<<<\n" > $1
grep "cd" $2 > $1
 
