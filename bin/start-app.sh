#!/bin/bash
########启动Spark streaming流任务########
current_date=`date -d "-1 day" "+%Y%m%d"`
echo "当前日期："$current_date

work_home=/home/oscp/ocsp_distinct
ocsp_home=/home/ocsp/ocsp
echo "脚本执行目录："$work_home

function getJars(){
res=""
filelist=`ls ${work_home}/lib/*.jar`
for file in $filelist
do
        if [ -n "$res" ];then
                res="${res},${work_home}/lib/${file}"
        else
                res="${work_home}/lib/${file}"
        fi
done
echo $res
}

TASK_ID=1
CONF_HOME="${work_home}/conf"
LOG_PATH="${work_home}/logs"
driver_mem="10g"
executor_mem="2g"
num_executors=10
executor_cores=2
queue="ocsp"
jars=`getJars`

#echo "jars: " $jars

cd $CONF_HOME
files="$CONF_HOME/executor-log4j.properties,$CONF_HOME/common.properties"

nohup sudo -u ocsp /usr/hdp/2.6.0.3-8/spark/bin/spark-submit \
--files ${files} \
--conf "spark.executor.extraJavaOptions=-Dlog4j.configuration=executor-log4j.properties"  \
--driver-java-options "-DOCSP_LOG_PATH=${LOG_PATH} -DOCSP_TASK_ID=${TASK_ID} -Dlog4j.configuration=file:${CONF_HOME}/driver-log4j.properties" \
--class com.asiainfo.ocsp.shanghai.StreamApp \
--master yarn --deploy-mode client --driver-memory ${driver_mem} --executor-memory ${executor_mem} --num-executors ${num_executors} --executor-cores ${executor_cores} \
--queue ${queue} \
--jars $jars $work_home/lib/KafkaRowFormat-1.0.jar ${TASK_ID} > $work_home/logs/app_${TASK_ID}_$current_date.log 2>&1 &
