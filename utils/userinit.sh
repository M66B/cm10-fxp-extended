#!/system/xbin/ash

#chmod 755 /data/local/userinit.sh
#chown root:root /data/local/userinit.sh

mount -o remount,rw /system

#Power collapse
#sed -i '/ro.ril.power.collapse/d' /system/build.prop
#sed -i '/ro.ril.disable.power.collapse/d' /system/build.prop
#echo "ro.ril.disable.power.collapse=1" >>/system/build.prop

#Disable aGPS
sed -i '/ro.ril.def.agps.mode/d' /system/build.prop
sed -i '/ro.ril.def.agps.feature/d' /system/build.prop
echo "ro.ril.def.agps.mode=0" >>/system/build.prop
echo "ro.ril.def.agps.feature=1" >>/system/build.prop

setprop wifi.supplicant_scan_interval 180
setprop pm.sleep_mode 1
setprop sys.mem.max_hidden_apps 10

log -p i -t userinit.sh "Updated properties"

#Dim screen
sed -i 's/1,70,255,52,24,5,80/1,10,255,52,24,5,80/g' /etc/hw_config.sh
log -p i -t userinit.sh "Updated hardware config"

mount -o remount,ro /system

#Undervolt
echo '24576 750' >/sys/devices/system/cpu/cpu0/cpufreq/vdd_levels
echo '61440 775' >/sys/devices/system/cpu/cpu0/cpufreq/vdd_levels
echo '134400 775' >/sys/devices/system/cpu/cpu0/cpufreq/vdd_levels
echo '184320 800' >/sys/devices/system/cpu/cpu0/cpufreq/vdd_levels
echo '192000 800' >/sys/devices/system/cpu/cpu0/cpufreq/vdd_levels
echo '249600 800' >/sys/devices/system/cpu/cpu0/cpufreq/vdd_levels
log -p i -t userinit.sh "Undervolting"

#SmartassV2
echo "smartassV2" >/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo 134400 >/sys/devices/system/cpu/cpufreq/smartass/sleep_wakeup_freq
echo 134400 >/sys/devices/system/cpu/cpufreq/smartass/sleep_ideal_freq
echo 1 >/sys/devices/system/cpu/cpufreq/smartass/boost_enabled
log -p i -t userinit.sh "Setup SmartassV2"

#sshd
/system/bin/sshd
log -p i -t userinit.sh "Started sshd"
