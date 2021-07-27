#!/bin/sh
OPERATION_TYPE=$2
OPERATION_OBJ=$1
IS_DEBUG=0

if [ $# -ne 2 ]; then
  echo "Error:Expect param size not equal input size!"
  exit
fi

function start() {
  COUNT=$(ps -fe|grep java|grep $OPERATION_OBJ|grep -v grep |wc -l)
  if [ $COUNT -lt 1 ]; then
    if [ $IS_DEBUG -eq 0 ]; then
      nohup java -Xms2g -Xmx2g -XX:PermSize=512M -XX:MaxPermSize=512M -jar $OPERATION_OBJ > process.log  2>&1 &
    else
      nohup java -Xms2g -Xmx2g  -XX:PermSize=512M -XX:MaxPermSize=512M -Xdebug -Xnoagent -Djava.compiler=NONE 	-Xrunjdwp:transport=dt_socket,address=18875,server=y,suspend=n -jar $OPERATION_OBJ > process.log 2>&1 &
    fi
    echo "server starting successfully!"
  else
    echo "server has running already!"
  fi
  return 0;
}

function stop() {
  PID=($(ps -ef | grep java | grep $OPERATION_OBJ |awk '{print $2}'))
  len=${#PID[*]}
  if [ $len -gt 0 ]; then
    for (( i=0; i<"$len"; i=i+1 ))
      do
        CID=${PID[$i]}
        kill -9 $CID
        echo "Server [pid=$CID] has killed successfully!"
      done
  else
    echo "No server running!"
  fi
  return 0;
}

if [ $OPERATION_TYPE == "start" ]; then
  start
elif [ $OPERATION_TYPE == "debug" ]; then
  IS_DEBUG=1
  start
elif [ $OPERATION_TYPE == "stop" ]; then
  stop
elif [ $OPERATION_TYPE == "restart" ]; then
  stop
  start
elif [ $OPERATION_TYPE == "r-debug" ]; then
  stop
  IS_DEBUG=1
  start
else
  echo "Params error!"
fi