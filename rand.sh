##!/bin/bash


# from https://www.jb51.net/article/124900.htm
function rand(){
  min=$1
  max=$(($2-$min+1))
  num=$(($RANDOM+1000000000)) #增加一个10位的数再求余
  echo $(($num%$max+$min))
}

#postion="103.9$(rand 25609 37497),30.7$(rand 45502 53542)"
#echo random xy: $postion

function genAddr(){

retval=0
postion=$1

if [ -z $postion ]; then
	# qingshuihe
	postion="103.9$(rand 25609 37497),30.7$(rand 45502 53542)"
fi

optstr=`curl -s -H 'Connection: keep-alive' -H 'DNT: 1' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.163 Safari/537.36' -H 'Sec-Fetch-Dest: document' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9' -H 'Sec-Fetch-Site: none' -H 'Sec-Fetch-Mode: navigate' -H 'Accept-Language: zh-CN,zh;q=0.9,en;q=0.8' --compressed "https://restapi.amap.com/v3/geocode/regeo?key=825d0697d0a22be408d41eb8ef59d5ac&s=rsv3&language=zh_cn&location=${postion}&callback=jsonp_241401_&platform=JS&logversion=2.0&sdkversion=1.4.15"`

real_pos=`echo $optstr | grep -oP '(?<=\"location\":\")\S+?(?=\")'`
name_addr=`echo $optstr | grep -oP '(?<=\"formatted_address\":\")\S+?(?=\")'`	# warn: \"  not included

#echo "pos: $real_pos"
#echo "addr: $name_addr"

longit=`echo $real_pos | grep -oP '^[1-9][0-9\.]+?(?=,)'`
lati=`echo $real_pos | grep -oP '(?<=,)[0-9\.]+$'`

#echo longitude: $longit
#echo latitude: $lati


if [[ -z $lati || -z $longit || -z ${name_addr} ]]; then
	(( retval+=1 ))
	#echo "error"
fi

f21="{\"latitude\":$lati,\"longitude\":$longit,\"address\":\"${name_addr}\"}"

#echo f21: $f21
echo $f21

return $(( retval ))

}
