#!/bin/bash -e
# 解析json中的地址数据并从远端下载图片转存到s3

# 解析 json 数组
list=$(aws s3 ls s3://slope-fs-pd/icon/bn --recursive|awk '{print $4}')
# 按行循环 json 数组
for i in $list;
do
    # 获取远端文件名称，并且组装成新的文件名
    s3_file_name="https://slope-fs-pd.s3.ap-east-1.amazonaws.com/$i"
    # 下载远端文件到指定目录，-x 自动创建目录，-N 忽略已下载文件， -O 保持到指定文件路径中 
    wget -x -N -O ${i##*/} $s3_file_name 
    # 如果下载不到文件中途退出
    if [ ! -f ${i##*/} ];then
        echo "---------------------->文件 $s 不存在"
        exit
        else
        # 保存已下载文件名
        echo $s3_file_name >> up.txt
    fi
done