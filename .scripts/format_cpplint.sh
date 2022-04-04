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

# 因cpplint没有windows解析其扫描结果的工具，所以借助cppcheck的windows工具
# 本程序就是按照cppcheck.xml格式进行cpplint扫描结果的转化

CPPLINT_RESULT=$1
ERROR_TOTAL=$2

function percentage_progress()
{
  progress=$(($1*100/$2))

  if [ $progress -lt 10 ];then
    echo -e "${progress}%\b\b\c"
  elif [ $progress -lt 100 ];then
    echo -e "${progress}%\b\b\b\c"
  else
    echo -e "${progress}%\c"
  fi
}

function format_cpplint_to_cppcheck()
{
  echo "Converting ..."
  local error_statistic=0
  # 提取错误信息行到新文件
  grep -n "Total errors found:" $CPPLINT_RESULT > error_number.txt

  # 获取错误信息所在行和本文件的错误数
  error_statistics_line=(`awk -F "[:]" '{print $1}' error_number.txt`)
  # echo "error_statistics_line: ${error_statistics_line[@]}"
  error_statistics_number=(`awk -F "[:]" '{print $3}' error_number.txt`)
  # echo "error_statistics_number: ${error_statistics_number[@]}"

# 写入xml头
cat>lint.xml<<EOF
<?xml version="1.0" encoding="UTF-8"?>
<results version="2">
    <cppcheck version="2.6"/>
    <errors>
EOF

  local file_index=0
  # 遍历有问题的文件
  for line_base in ${error_statistics_line[@]}
  do
    local index=1;
    # 遍历问题行
    for ((; index <= ${error_statistics_number[file_index]}; index++))
    do
      # 提取指定行内容
      line=`sed -n "$((line_base + index))p" $CPPLINT_RESULT`
      # 为什么不用awk命令直接拆，是因为message中也会有':'
      file_path=${line%%:*}
      temp=${line#*:}
      code_line=${temp%%:*}
      # 文件名不合规时需要转换
      if [[ "$code_line" == "name" ]];then
        code_line=0
      fi
      temp=${line#*:}
      error_message=${temp#*:}
      # cppcheck解析机对结果文件xml中的一些符号敏感，如'\"' -> '\'', '<|>' -> '(|)', '&' -> '[and]'
      error_message=${error_message//\"/\'}
      error_message=${error_message//</(}
      error_message=${error_message//>/)}
      error_message=${error_message//&/[and]}
      # 设置问题序号，如1/8
      issue_number=`echo "${index}/${error_statistics_number[file_index]}"`
      # 组合cppcheck的xml格式信息
      echo "        <error id=\"lint\" severity=\"style\" msg=\"${error_message}.\" verbose=\"No.${issue_number}&#x000A;Message:${error_message}.\" file0=\"$file_path\">" >> lint.xml
      echo "            <location file=\"$file_path\" line=\"$code_line\" column=\"0\"/>" >> lint.xml
      echo "        </error>" >> lint.xml
      percentage_progress $index ${error_statistics_number[file_index]}
    done
    ((error_statistic+=${error_statistics_number[file_index]}))
    ((file_index++))
    echo "  The [$file_index/${#error_statistics_line[@]}] file is processed --------------------------"
  done
  echo $error_statistic > $ERROR_TOTAL

# 写入xml尾
cat>>lint.xml<<EOF
    </errors>
</results>
EOF
}

rm lint.xml
format_cpplint_to_cppcheck
rm error_number.txt
