#!/bin/bash

source /home/centos/instance_info

command=`iostat -x -d /dev/xvda | awk '/xvda/ { print $9}'`

per_host_options="--namespace AWS/EC2 --region us-west-2 --dimensions TestId=$test_id,Instance=$instance"

aws cloudwatch put-metric-data $per_host_options --metric-name ESDiskQueueSize --unit Count --value ${command}
