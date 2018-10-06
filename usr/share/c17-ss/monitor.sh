#!/bin/sh
while :
do
    sleep 2s
    if [ -n "$(ps | grep ss-redir | grep -v grep)" ]; then
        echo 1 > /sys/class/leds/gl-ar300m:green:lan/brightness
        echo on
    else
        echo 0 > /sys/class/leds/gl-ar300m:green:lan/brightness
        echo off
    fi
done
