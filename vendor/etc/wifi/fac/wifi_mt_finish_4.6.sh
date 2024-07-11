
#!/bin/sh

LOG_TAG="Wifi_mt"
LOG_NAME="${0}:"
n_check=5

logi ()
{
    /system/bin/log -t $LOG_TAG -p i "$LOG_NAME $@"
}

kill -s 9 `pgrep ftmdaemon`
stop ftmdaemon
if [ "$?" == "0" ]; then
    logi "stop ftmdaemon success"
else
    logi "stop ftmdaemon failed."
fi

echo 0 > /sys/module/qca6490/parameters/con_mode
if [ "$?" == "0" ]; then
    logi "stop con_mode success."
else
    logi "stop con_mode failed"
fi


setprop wifi.mt.status stopped

while(($n_check>0))
do
    rmmod wlan
    if [ "$?" == "0" ]; then
        logi "rmmod wlan success"
    else
        logi "rmmod wlan failed."
    fi
    insmod /vendor/lib/modules/qca_cld3_qca6490.ko
    if [ "$?" == "0" ]; then
        logi "insmod wlan success"
        n_check=0
    else
        logi "insmod wlan failed."
        n_check=$(($n_check-1))
    fi
done


