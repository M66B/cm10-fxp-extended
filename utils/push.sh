#!/bin/sh
if [ "$1" = "" ]; then
	echo "Please specify device"
	exit
fi
if [ "$2" = "" ]; then
	echo "Please specify date YYYYMMDD"
	exit
fi
android=~/android/system
adb push ${android}/out/target/product/$1/cm-10-$2-UNOFFICIAL-$1.zip /sdcard/
