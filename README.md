## 信通学院研究生晚点名填写6月13日起

本脚本可以帮助你每天自动晚点名签到，原理是定时用curl来提交数据。运行依赖Linux/bash和curl。<br>
需要在全天运行的Linux主机上使用，推荐在树莓派等单板机上使用。

## 特点：
* 支持多人签到，只需要向data数组中添加多个人员信息
* 签到时的地点可以随机（在一定的经纬度范围内）
* 注意：全日制选项只支持住宿地点为宿舍，并且是11点前回到。非全选项只支持选在学校周边常住地。

## 使用方法：
1. 下载daily_jinshu_sign.sh和rand.sh并赋予daily_jinshu_sign.sh以可执行权限；
2. 修改daily_jinshu_sign.sh中的data数组，根据其中的注释，将自己的签到信息写入数组中，可以添加多人，格式如下：
```Bash
data=(
#各字段的含义和格式如下：
#学号 姓名 校区:清水河{Q}or沙河{S}or宜宾{[^QS]} 全日制宿舍/非全校外住宿地址 地理位置 手机号
#学号；姓名；清水河校区；全日制的话填宿舍号，否则填非全校外住宿地址；地理位置的经度范围是103.930400~103.930900，维度范围是30.75285~30.752311
"201821010999" "张三" "Q" "QS99-909" "`genField_21 103.930$(rand 400 900),30.752$(rand 85 311)`" "12345678901"
#你也可以用如下方式直接指定地理位置
"201822010998" "李四" "Yibin" "QS99-909" "{"latitude":28.6981919,"longitude":104.549108,"address":"四川省宜宾市叙州区柏溪街道南兴大道29号宜宾市叙州区中医医院"}" "12345678901"
#函数genField_21不带参数会在清水河校区任选一个地理位置
"201852010799" "王五" "Q" "龙湖xxx栋xxx号" "`genField_21`" "12345678901"
)
```
3. 以每天18:15签到为例，将以下内容加入到crontab之中
```Bash
15 18 * *  * /path/to/your/daily_jinshu_sign.sh
```
4. 完成
