#!/bin/bash -e
# 解析json中的地址数据并从远端下载图片转存到s3

# 解析 json 数组
list=$(jq -c '.[]' data.json)
# 按行循环 json 数组
for i in $list;
do
    # 提取 target 和 source 参数
    # 参数 r 可以提取元数据，否则获取到的字符串会包含 ""
    t=$(jq -r '.target'  <<< $i)
    s=$(jq -r '.source'  <<< $i)
    # 获取远端文件名称，并且组装成新的文件名
    s3_file_name="icon/128x128/$t-${s##*/}"
    # 下载远端文件到指定目录，-x 自动创建目录，-N 忽略已下载文件， -O 保持到指定文件路径中 
    wget -x -N -O $s3_file_name $s
    # 如果下载不到文件中途退出
    if [ ! -f $s3_file_name ];then
        echo "---------------------->文件 $s 不存在"
        exit
        else
        # 保存已下载文件名
        echo $s3_file_name >> up.txt
    fi
    # 上传的 s3 并授予公开读的ACL
    # 注意，aws s3 上传并修改 ACL 需要在存储桶中打开相应的安全开关
    aws s3 cp $s3_file_name s3://bucket/icon/128x128/$s3_file_name --acl public-read
done