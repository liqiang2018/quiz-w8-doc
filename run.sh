#!/bin/bash
# 查找脚本所在路径，并进入
DIR="$( cd "$( dirname "$0"  )" && pwd  )"
cd $DIR
echo current dir is $PWD

# 设置目录，避免module找不到的问题
export PYTHONPATH=$PYTHONPATH:$DIR:$DIR/slim:$DIR/object_detection

# 定义各目录
train_dir=/output/train  # 训练目录
checkpoint_dir=$train_dir  # 训练目录
eval_dir=/output/eval  # 验证目录

config_src=/data/ai100/quiz-w8/ssd_mobilenet_v1_pets.config  #pipline config文件源文件路径
config_dst=/output/ssd_mobilenet_v1_pets.config  #运行中使用的pipline config文件

pipeline_config_path=$config_dst  # 传入训练脚本的config文件路径

cp $config_src $config_dst  #复制源文件，因为dataset中的文件是不允许修改的，所以复制一份/到output里面

for i in {0..4}  # for循环中的代码循环执行5次。这里左右边界都包含，也就是训练会执行500个step，每100个step验证一次。
do
    echo "############" $i "runnning #################"
    last=$[$i*100]
    current=$[($i+1)*100]
    sed -i "s/^  num_steps: $last$/  num_steps: $current/g" $config_dst  # 通过num_steps控制一次训练最多100个step
    python object_detection/train.py --train_dir=$train_dir --pipeline_config_path=$pipeline_config_path  # 启动训练
    python object_detection/eval.py --checkpoint_dir=$checkpoint_dir --eval_dir=$eval_dir --pipeline_config_path=$pipeline_config_path  #启动验证
done
