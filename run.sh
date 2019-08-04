#!/bin/bash
#####################################
## File name : run.sh
## Create date : 2018-11-26 11:19
## Modified date : 2019-08-04 17:18
## Author : DARREN
## Describe : not set
## Email : lzygzh@126.com
####################################

realpath=$(readlink -f "$0")
basedir=$(dirname "$realpath")
export basedir=$basedir/cmd_sh/
export filename=$(basename "$realpath")
export PATH=$PATH:$basedir
export PATH=$PATH:$basedir/dlbase
export PATH=$PATH:$basedir/dlproc
#base sh file
. dlbase.sh
#function sh file
. etc.sh
#. install_pybase.sh

kill -9 `ps -ef|grep main.py|grep -v grep|awk '{print $2}'`
kill -9 `ps -ef|grep defunct|grep -v grep|awk '{print$3}'`

function create_vir_env(){
    dlfile_check_is_have_dir $env_path

    if [[ $? -eq 0 ]]; then
        bash ./cmd_sh/create_env.sh
    else
        $DLLOG_INFO "$1 virtual env had been created"
    fi
}

create_vir_env

#bash ./cmd_sh/check_code.sh

#   source $env_path/py2env/bin/activate
#   deactivate

source $env_path/py3env/bin/activate
#create_pybase
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade pytorch-pretrained-bert==0.6.1
python run_ner.py --data_dir=data_CoNLL-2003/ --bert_model=./model_dir/bert-base-cased  --task_name=ner --output_dir=out_!x --max_seq_length=128 --do_train --num_train_epochs 5 --do_eval --warmup_proportion=0.4

#python run_ner.py --data_dir=data_CoNLL-2003/ --bert_model=./model_dir/bert-large-cased  --task_name=ner --output_dir=out_!x --max_seq_length=128 --do_train --num_train_epochs 5 --do_eval --warmup_proportion=0.4
#python api.py
deactivate
