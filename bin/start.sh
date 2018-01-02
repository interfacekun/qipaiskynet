#!/bin/sh

export ROOT=$(pwd)
export SKYNET_ROOT=$(pwd)'/cloud/skynet/skynet'

export DAEMON=false
export NODENAME='"test"'
export DEBUG_MODE='"DEBUG"'
export LOG_PATH='"./logs/test/"'
export ETCDHOST='"127.0.0.1:8101"'
export ENV='"dev"'
export API_ENV=false


while getopts "ADKUSn:d:l:e:v:" arg
do
    case $arg in
        D)
            export DAEMON=true
            ;;
        K)
            kill `cat $ROOT/run/skynet-test.pid`
            exit 0;
            ;;
        n)  
            export NODENAME='"'$OPTARG'"'
            ;;
        d)  
            export DEBUG_MODE='"'$OPTARG'"'
            ;;
        l) 
            export LOG_PATH='"'$OPTARG'"'
            ;;
        e) 
            export ETCDHOST='"'$OPTARG'"'
            ;;
        v)  
            export ENV='"'$OPTARG'"'
            ;;
        A)  
            export API_ENV=true
            ;;
        U)
            echo 'start srv_hotfix update' | nc 127.0.0.1 8900
            exit 0;
            ;;
        S)
            echo 'start gate/service/srv_room_sup save' | nc 127.0.0.1 8900
            exit 0;
            ;;

    esac
done



$SKYNET_ROOT $ROOT/config/config.lua

