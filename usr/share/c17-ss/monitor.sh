#!/bin/sh
while :
do
    sleep 2s
    # get ss config ip
    echo "getting ss config ip..."
    ssip=$(cat /var/etc/shadowsocks.*.json | grep \"server\" |awk -F ":" '{gsub(",", "", $2); gsub(" ", "", $2); gsub("\"", "", $2);print $2}')
    echo "ss ip is: $ssip"
    # get real ip
    echo "getting real ip..."
    realip=$(curl -s -m 5 ifconfig.me)
    echo "real ip is: $realip"
    if [ "$ssip" == "$realip" ]; then
        echo 1 > /sys/class/leds/gl-ar300m:green:lan/brightness
        echo on
    else
        echo 0 > /sys/class/leds/gl-ar300m:green:lan/brightness
        echo off
    fi
done
