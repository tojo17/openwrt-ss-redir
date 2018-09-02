#!/bin/sh
basepath=$(cd `dirname $0`; pwd)
while :
do
    sleep 2s
    if [ -n "$(ps | grep /etc/shadowsocks.json | grep -v grep)" ]; then
        echo 1 > /sys/class/leds/gl-ar300m:lan/brightness
        echo on
    else
        echo 0 > /sys/class/leds/gl-ar300m:lan/brightness
        echo off
    fi
done
