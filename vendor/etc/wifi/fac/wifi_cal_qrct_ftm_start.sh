
#!/bin/sh

LOG_TAG="Wifi_qrct_cal"
LOG_NAME="${0}:"

logi ()
{
    /system/bin/log -t $LOG_TAG -p i "$LOG_NAME $@"
}

if [ ! -d /data/misc ]; then
    logi "the directory does not exist"
fi

export CLASSPATH=/system/framework/svc.jar
/system/bin/app_process /system/bin com.android.commands.svc.Svc wifi disable
if [ "$?" == "0" ]; then
    logi "wifi disable success"
else
    logi "wifi disable failed."
fi

setprop wifi.mt.status running

kill -s 9 `pgrep ftmdaemon`
if [ "$?" == "0" ]; then
    logi "stop ftmdaemon success"
else
    logi "stop ftmdaemon failed."
fi

stop wpa_supplicant
if [ "$?" == "0" ]; then
    logi "stop wpa_supplicant success"
else
    logi "stop wpa_supplicant failed."
fi
stop p2p_supplicant
if [ "$?" == "0" ]; then
    logi "stop p2p_supplicant success"
else
    logi "stop p2p_supplicant failed."
fi
ifconfig p2p0 down
ifconfig wlan0 down

ifconfig wlan0 up
if [ "$?" == "0" ]; then
    logi "start wlan0 success."
        sleep 0.5
else
    logi "start wlan0 failed"
fi

echo 5 > /sys/module/qca6490/parameters/con_mode
if [ "$?" == "0" ]; then
    logi "start con_mode success."
    sleep 2
else
    echo 5 > /sys/module/qca6750/parameters/con_mode
    if [ "$?" == "0" ]; then
        logi "start con_mode success."
        sleep 2
    else
        echo 5 >  /sys/module/wlan/parameters/con_mode
        if [ "$?" == "0" ]; then
            logi "start con_mode success."
            sleep 2
        else
            echo 5 >  /sys/module/adrastea/parameters/con_mode
            if [ "$?" == "0" ]; then
                logi "start con_mode success."
                sleep 2
            else
                logi "start con_mode failed"
            fi
        fi
    fi
fi

ftmdaemon -n -dd
if [ "$?" == "0" ]; then
    logi "start ftmdaemon success."
else
    logi "start ftmdaemon failed"
fi