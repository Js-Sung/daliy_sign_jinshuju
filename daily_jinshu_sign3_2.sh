#!/bin/bash

. rand.sh

declare -i retval=0

#field_21	地理位置
#field_14  	留校原因		-- removed
#field_13  	暑假去向		-- removed
##aYaM		离校
##2xo5		留校
#field_12	教研室门牌号	-- removed
#field_11	非全地址
#field_9	11点前？
#field_6	姓名
#field_5	学号
#field_7	校区
#field_8	住宿地点

#只支持选择11点前，校内宿舍或非全校外宿舍
#学号 姓名 今晚您的住宿地点:校内{Y}or非全{N} 您所在的校区:清水河{Y}or沙河{N} 校外住宿地址 地理位置
: 
data=(
"201821010999" "张三" "Y" "Y" "" "`genField_21 103.930$(rand 400 900),30.752$(rand 85 311)`"
"201822010998" "李四" "N" "Y" "龙湖xxx栋xxx号" "{"latitude":28.6981919,"longitude":104.549108,"address":"四川省宜宾市叙州区柏溪街道南兴大道29号宜宾市叙州区中医医院"}"
"201822010799" "王五" "N" "Y" "龙湖xxx栋xxx号" "`genField_21`"
)



len=${#data[@]}
#echo len=$len

for(( i=0; i<len; i+=6 ))
do

[ "${data[i+2]}" = "Y" ] && f8="FRjZ" || f8="7UJ9"
[ "${data[i+2]}" = "Y" ] && f11="" || f11="${data[i+4]}"
[ "${data[i+3]}" = "Y" ] && f7="FRjZ" || f7="lFRN"
#echo "id: ${data[i]}  name: ${data[i+1]} dome: $f8 campus: $f7 addr: $f11 position: ${data[i+5]}"

curl -s -H 'Host: jinshuju.net' -H "Cookie: jsj_uid=b1dd3f7a-0ebe-41b1-83ab-d8cf4b7639b8; referer_url=https%3A%2F%2Fjinshuju.net%2Ff%2F2ix4UC;  start_filling_time_9wGVFn=$[`date +%s`-2]" -H 'origin: https://jinshuju.net' -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.163 Safari/537.36' -H 'content-type: application/json;charset=UTF-8' -H 'accept: */*' -H 'sec-fetch-dest: empty' -H 'dnt: 1' -H 'sec-fetch-site: same-origin' -H 'sec-fetch-mode: cors' -H 'referer: https://jinshuju.net/f/9wGVFn' -H 'accept-language: zh-CN,zh;q=0.9,en;q=0.8' --data-binary "{\"operationName\":\"CreatePublishedFormEntry\",\"variables\":{\"input\":{\"formId\":\"9wGVFn\",\"entryAttributes\":{\"field_6\":\"${data[i+1]}\",\"field_5\":\"${data[i]}\",\"field_8\":\"$f8\",\"field_7\":\"$f7\",\"field_11\":\"$f11\",\"field_9\":\"Zda4\",\"field_2\":\"\",\"field_10\":\"\",\"field_3\":\"\",\"field_21\":${data[i+5]}},\"captchaData\":null,\"weixinAccessToken\":null,\"xFieldWeixinOpenid\":null,\"weixinInfo\":null,\"prefilledParams\":\"\",\"embedded\":false,\"backgroundImage\":false,\"formMargin\":false,\"fillingDuration\":$(rand 5 120)}},\"extensions\":{\"persistedQuery\":{\"version\":1,\"sha256Hash\":\"4cd6a9aef2820b2c3215f6ddfa87093869461f76f3f2016738f4307268a7df98\"}}}" --compressed 'https://jinshuju.net/graphql/f/9wGVFn' | grep "\"errors\":null" > /dev/null 2>&1


if [ $? -eq 0 ]
then
echo "`date +"%Y-%m-%d %X"`: ${data[i+1]} signed ok" #>> /var/run/daily_report.txt
else
echo "`date +"%Y-%m-%d %X"`: ${data[i+1]} failed to signed" #>> /var/run/daily_report.txt
let retval+=1
fi

sleep 1.6



done

exit $(( retval ))
