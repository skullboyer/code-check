#!/bin/bash
# Copyright © 2022 <copyright skull.gu@gmail.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software
# and associated documentation files (the “Software”), to deal in the Software without
# restriction, including without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all copies or
# substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
# BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

TARGET_FOLDER=$1

find $TARGET_FOLDER -iname "*.c" -o -iname "*.cpp" -o -iname "*.h" > file_list.txt

rm lint.txt
echo "Checking ..."
lint_file_number=`sed -n '$=' file_list.txt`
index=1
cat file_list.txt | while read line
do
  /c/Program\ Files/Cppcheck/cppcheck.exe --enable=all --inconclusive --xml --xml-version=2 ${line} 2>> cppcheck.xml
  echo "[Lint:${index}/${lint_file_number}]  $line"
  ./../exe/lint.exe  ${line} 1> out.txt 2> err.txt
  cat out.txt err.txt >> lint.txt
  ((index++))
done

touch cpplint.num
sh format_cpplint.sh lint.txt cpplint.num

cppcheck_num=`grep '<\/error>' <cppcheck.xml|wc -l`
cpplint_num=`cat cpplint.num`
cat <<SKULL
********************
*    Check Done    *
* cppcheck issues: $cppcheck_num
* Lint issues: $cpplint_num
********************
SKULL

rm out.txt err.txt cpplint.num file_list.txt
