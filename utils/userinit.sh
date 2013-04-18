#!/system/xbin/ash

#chmod 755 /data/local/userinit.sh
#chown root:root /data/local/userinit.sh

#Disable aGPS
mount -o remount,rw /system
sed -i '/ro.ril.def.agps.mode/d' /system/build.prop
sed -i '/ro.ril.def.agps.feature/d' /system/build.prop
echo "ro.ril.def.agps.mode=0" >>/system/build.prop
echo "ro.ril.def.agps.feature=1" >>/system/build.prop
mount -o remount,ro /system
log -p i -t userinit.sh "Disabled aGPS"

#Wifi scan interval
setprop wifi.supplicant_scan_interval 180
log -p i -t userinit.sh "Modified scan interval"

#echo 512 >/sys/devices/virtual/bdi/179:0/read_ahead_kb

#sshd
/system/bin/sshd
log -p i -t userinit.sh "Started sshd"
