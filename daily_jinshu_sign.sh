#!/bin/bash


LOGFILE='/var/run/daily_report.txt'
if [ -f $LOGFILE ]
then
	echo log file already exit.
else
	echo log file not exit, making one.
	sudo touch $LOGFILE
	sudo chmod 666 $LOGFILE
fi


# from https://www.jb51.net/article/59949.htm
DIR="$( cd "$( dirname "$0"  )" && pwd  )"
cd $DIR

. ./rand.sh

declare -i retval=0

#field_21	地理位置
#field_14  	留校原因		-- removed
#field_13  	暑假去向		-- removed
  ##aYaM		离校
  ##2xo5		留校
#field_12	教研室门牌号		-- removed
#field_11	非全地址
#field_9	11点前？		-- only for full time students
#field_6	姓名
#field_5	学号
#field_7	校区			-- only for full time students
#field_8	住宿地点		-- removed
#field_27  	非全:今年是否在学校周边常住地
  ##CBf4		是
  ##2aLG		否
#field_7	校区
  ##FRjZ		清水河
  ##lFRN		沙河
  ##WeQk		宜宾
#field_23	学生类型
  ##Povx		全日制
  ##r5De		非全
#field_24	今晚的住宿地点
  ##FRjZ		宿舍
  ##eike		其他


#全日制选项只支持住宿地点为宿舍，并且是11点前回到。
#非全选项只支持选在学校周边常住地


#学号  姓名  校区:清水河{Q}or沙河{S}or宜宾{[^QS]}  校外住宿地址  地理位置

: 
data=(
"201821010999" "张三" "Q" "" "`genField_21 103.930$(rand 400 900),30.752$(rand 85 311)`"
"201822010998" "李四" "Yibin" "" "{"latitude":28.6981919,"longitude":104.549108,"address":"四川省宜宾市叙州区柏溪街道南兴大道29号宜宾市叙州区中医医院"}"
"201852010799" "王五" "Q" "龙湖xxx栋xxx号" "`genField_21`"
)


len=${#data[@]}
#echo len=$len

for(( i=0; i<len; i+=5 ))
do


f5=${data[i]}
[ "${f5:4:1}" = "5" ] && f23="r5De" || f23="Povx"
f6=${data[i+1]}
f21=${data[i+4]}
f9="Zda4"
f24="FRjZ"
f27="CBf4"
f11=${data[i+3]}

if [[ ${data[i+2]} == "Q" ]]; then
	f7="FRjZ"
elif [[ ${data[i+2]} == "S" ]]; then
	f7="lFRN"
else
	f7="WeQk"
fi

echo "id: ${f5}, name: ${f6}, isfullTime: $f23, campus: $f7, external addr: $f11, position: ${f21}"

curl -s -H 'Host: jinshuju.net' -H "Cookie: jsj_uid=b1dd3f7a-0ebe-41b1-83ab-d8cf4b7639b8; referer_url=https%3A%2F%2Fjinshuju.net%2Ff%2F2ix4UC;  start_filling_time_9wGVFn=$[`date +%s`-2]" -H 'origin: https://jinshuju.net' -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.163 Safari/537.36' -H 'content-type: application/json;charset=UTF-8' -H 'accept: */*' -H 'sec-fetch-dest: empty' -H 'dnt: 1' -H 'sec-fetch-site: same-origin' -H 'sec-fetch-mode: cors' -H 'referer: https://jinshuju.net/f/9wGVFn' -H 'accept-language: zh-CN,zh;q=0.9,en;q=0.8' --data-binary "{\"operationName\":\"CreatePublishedFormEntry\",\"variables\":{\"input\":{\"formId\":\"9wGVFn\",\"entryAttributes\":{\"field_6\":\"${f6}\",\"field_5\":\"${f5}\",\"field_8\":\"$f8\",\"field_7\":\"$f7\",\"field_11\":\"$f11\",\"field_9\":\"$f9\",\"field_24\":\"$f24\",\"field_23\":\"$f23\",\"field_27\":\"$f27\",\"field_2\":\"\",\"field_10\":\"\",\"field_3\":\"\",\"field_21\":${f21}},\"captchaData\":null,\"weixinAccessToken\":null,\"xFieldWeixinOpenid\":null,\"weixinInfo\":null,\"prefilledParams\":\"\",\"embedded\":false,\"backgroundImage\":false,\"formMargin\":false,\"fillingDuration\":$(rand 5 100)}},\"extensions\":{\"persistedQuery\":{\"version\":1,\"sha256Hash\":\"4cd6a9aef2820b2c3215f6ddfa87093869461f76f3f2016738f4307268a7df98\"}}}" --compressed 'https://jinshuju.net/graphql/f/9wGVFn' | grep "\"errors\":null" > /dev/null 2>&1


if [ $? -eq 0 ]
then
echo "`date +"%Y-%m-%d %X"`: ${data[i+1]} signed ok" >> $LOGFILE
else
echo "`date +"%Y-%m-%d %X"`: ${data[i+1]} failed to sign" >> $LOGFILE
let retval+=1
fi


sleep 3.3



done

exit $(( retval ))
