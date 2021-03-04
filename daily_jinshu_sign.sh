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


#https://jinshuju.net/f/jad489
#
#field_1 姓名
#field_2 学号
#field_3 类型    KsBW=全     Xs6w=非
#field_6 【全】住宿地点      JsBh=校内
#field_4 【全】校区    zBCK=清水河     iLbn=沙河
#field_7 【全】23点前返回     GaXt=是
#field_13  【非全】周边    ZOsG=是
#field_15 【非全】门牌号  
#field_16  地理位置


#全日制选项只支持住宿地点为宿舍，并且是11点前回到。
#非全选项只支持选在学校周边常住地
#学号，姓名，校区:清水河{Q}or沙河{S}or宜宾{[^QS]}，非全校外住宿地址，地理位置
: 
data=(
"201821010999" "张三"   "Q"  "" "`genAddr`"
"201822010998" "李四"   "Q"  "" "`genAddr`"
"201852010799" "王五"   "Q" "龙湖xxx栋xxx号" "`genAddr`"
)


len=${#data[@]}
#echo len=$len

for(( i=0; i<len; i+=5 ))
do

f1=${data[i+1]}		# 姓名
f2=${data[i]}		# 学号
f16=${data[i+4]}	# 坐标
#f3: 日制	f13: 学校周边	f7: 23点前返回	f15: 门牌号	f6: 全日制住宿地点 
[ "${f2:4:1}" = "5" ] && { f3="Xs6w"; f13="\"ZOsG\""; f7="null"; f15="\"${data[i+3]}\""; f6="null"; } || { f3="KsBW"; f13="null"; f7="\"GaXt\""; f15="null"; f6="\"JsBh\""; }

# 全日制校区
if [[ ${data[i+2]} == "Q" ]]; then
	f4="zBCK"
elif [[ ${data[i+2]} == "S" ]]; then
	f4="iLbn"
else
	f4="zBCK"
fi

#echo "id: ${f2}, name: ${f1}, isfullTime: $f3, campus: $f4, external addr: $f15, position: ${f16}"


resp=$(curl 'https://jinshuju.net/graphql/f/jad489' -s -H 'authority: jinshuju.net'   -H 'pragma: no-cache'   -H 'cache-control: no-cache'   -H 'accept: */*'   -H 'dnt: 1'   -H 'x-csrf-token: vP1u+CLjGVD1ibn8XKmqmgVdFtE6sI22xF+YDVI5s8ARxOLVJtvdIVZu/9S+8uv0+MK8ZTboiWJZ3E6PKc8u0w=='   -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36'   -H 'content-type: application/json;charset=UTF-8'   -H 'origin: https://jinshuju.net'   -H 'sec-fetch-site: same-origin'   -H 'sec-fetch-mode: cors'   -H 'sec-fetch-dest: empty'    -H 'accept-language: zh-CN,zh;q=0.9'   -H 'cookie:  filled_form_scene=form'   --data-binary "{\"operationName\":\"CreatePublishedFormEntry\",\"variables\":{\"input\":{\"formId\":\"jad489\",\"entryAttributes\":{\"field_3\":\"$f3\",\"field_6\":$f6,\"field_4\":\"$f4\",\"field_7\":$f7,\"field_10\":null,\"field_13\":$f13,\"field_14\":null,\"field_1\":\"$f1\",\"field_2\":\"$f2\",\"field_15\":$f15,\"field_16\":$f16},\"captchaData\":null,\"weixinAccessToken\":null,\"xFieldWeixinOpenid\":null,\"weixinInfo\":null,\"prefilledParams\":\"\",\"embedded\":false,\"internal\":false,\"backgroundImage\":false,\"formMargin\":false,\"hasPreferential\":false,\"fillingDuration\":$(rand 5 100)}},\"extensions\":{\"persistedQuery\":{\"version\":1,\"sha256Hash\":\"94036a89d6b95dd5c3403503c419aa07b6c6af4ef63d157547f4822aa162a1e1\"}}}" --compressed)

echo $resp | grep "\"errors\":null" > /dev/null 2>&1


if [ $? -eq 0 ]
then
echo "`date +"%Y-%m-%d %X"`: ${f1} signed ok" >> $LOGFILE
echo ${f1} signed ok
else
echo "`date +"%Y-%m-%d %X"`: ${f1} failed to sign" >> $LOGFILE
echo "error: ${f1} failed to sign"
echo $resp
let retval+=1
fi


sleep 1.3



done

exit $(( retval ))
