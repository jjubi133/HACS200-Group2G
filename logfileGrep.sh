#!/bin/bash

#argument 1 will be the filename for the original log and argument 2 will be the new log
touch $2
echo ">>>ALL LINES INCLUDING WGET<<<\n" >> $2
grep "wget" "$1" >> $2

echo ">>>ALL LINES INCLUDING CURL<<<\n" >> $2
grep "curl" "$1" >> $2

echo ">>>ALL LINES INCLUDING INSTALL<<<\n" >> $2
grep "install" "$1" >> $2

echo ">>>ALL LINES INCLUDING LS<<<\n" >> $2
grep " ls" "$1" >> $2

echo ">>>ALL LINES INCLUDING CAT<<<\n" >> $2
grep " cat" "$1" >> $2

echo ">>>ALL LINES INCLUDING CD<<<\n" >> $2
grep "cd" "$1" >> $2
