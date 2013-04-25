#!/bin/bash

echo "$0" | grep -q bash
if [ $? -eq 0 ] || [ "${buildbot}" = "Y" ]; then
	cd ~/Downloads/cm10-fxp-extended
else
	cd "`dirname \"$0\"`"
fi

#Prerequisites

#bash
if [ ! -n "$BASH" ]; then
	echo "Try again with a bash shell"
	return
fi

#lz4
which lz4 > /dev/null
if [ $? -ne 0 ]; then
	echo "Install lz4:"
	echo ""
	echo "cd ~/Downloads"
	echo "svn checkout -r 91 http://lz4.googlecode.com/svn/trunk/ lz4"
	echo "cd lz4 && make && cp lz4demo ~/bin/lz4"
	echo ""
	return
fi

#Configuration

patches=`pwd`
repo=`which repo`
tmp=/tmp
android=~/android/system
devices="coconut iyokan mango smultron"
init=N
updates=N
onecorebuild=N
debug=N

if [ "$1" = "init" ]; then
	init=Y
fi

#Linaro

linaro_name=arm-eabi-4.7-linaro
linaro_file=android-toolchain-eabi-4.7-daily-linux-x86.tar.bz2
linaro_url=https://android-build.linaro.org/jenkins/view/Toolchain/job/linaro-android_toolchain-4.7-bzr/lastSuccessfulBuild/artifact/build/out/${linaro_file}

#bootimage

kernel3=Y
kernel_mods=Y
kernel_linaro=Y
kernel_xtended_perm=Y
kernel_wifi_range=Y
kernel_displaylink=Y

bootlogo=Y
bootlogoh=logo_H_extended.png
bootlogom=logo_M_extended.png

pin=Y

#ROM

cellbroadcast=Y
openpdroid=Y
nano=Y
terminfo=Y
emptydrawer=Y
massstorage=Y
xsettings=Y
wifiautoconnect=Y
eba=Y
ssh=Y
layout=Y
mvolume=Y
qcomdispl=Y
boost_pulse=Y
iw=Y
mmsfix=Y
apn_cm10_1=Y
trebuchet_cm10_1=Y
deskclock_cm10_1=Y
superuser_koush=Y
superuser_embed=Y
busybox_cm10_1=Y
cmfilemanager_cm10_1=Y
apollo_cm10_1=Y
cwm_cm10_1=Y

#Local configuration
if [ -f ~/.cm10xtended ]; then
	. ~/.cm10xtended
fi

#Say hello
echo ""
echo "CM/FXP extended ROM/kernel"
echo "Copyright (c) 2012-2013 Marcel Bokhorst (M66B)"
echo "http://blog.bokhorst.biz/about/"
echo ""
echo "GNU GENERAL PUBLIC LICENSE Version 3"
echo ""
echo "Patches: ${patches}"
echo "Repo: ${repo}"
echo "Tmp: ${tmp}"
echo "Android: ${android}"
echo "Devices: ${devices}"
echo "Init: ${init}"
echo "Updates: ${updates}"
echo ""

#Prompt
if [[ $- == *i* ]]
then
	read -p "Press [ENTER] to continue" dummy
	echo ""
fi

#Helper functions
do_replace() {
	sed -i "s/$1/$2/g" $3
	grep -q "$2" $3
	if [ $? -ne 0 ]; then
		echo "!!! Error replacing '$1' by '$2' in $3"
		exit
	fi
	if [ "${debug}" = "Y" ]; then
		echo "Replaced '$1' by '$2' in $3"
	fi
}

do_patch() {
	if [ -f ${patches}/$1 ]; then
		patch -p1 --forward -r- --no-backup-if-mismatch <${patches}/$1
		if [ $? -ne 0 ]; then
			echo "!!! Error applying patch $1"
			exit
		fi
	else
		echo "!!! Patch $1 not found"
		exit
	fi
}

do_patch_reverse() {
	if [ -f ${patches}/$1 ]; then
		patch -p1 --reverse -r- --no-backup-if-mismatch <${patches}/$1
		if [ $? -ne 0 ]; then
			echo "!!! Error applying reverse patch $1"
			exit
		fi
	else
		echo "!!! Patch $1 not found"
		exit
	fi
}

do_append() {
	if [ -f $2 ]; then
		echo "$1" >>$2
		if [ "${debug}" = "Y" ]; then
			echo "Appended '$1' to $2"
		fi
	else
		echo "!!! Error appending '$1' to $2"
		exit
	fi
}

do_deldir() {
	if [ -d "$1" ]; then
		chmod -R 777 $1
		rm -R $1
	else
		if [ "${debug}" = "Y" ]; then
			echo "--- $1 does not exist"
		fi
	fi
}

#Headless
mkdir -p ~/Downloads

#Cleanup
echo "*** Cleanup ***"

#OpenPDroid
do_deldir ${android}/out/target/common/obj/JAVA_LIBRARIES/framework_intermediates
do_deldir ${android}/out/target/common/obj/JAVA_LIBRARIES/framework2_intermediates
do_deldir ${android}/out/target/common/obj/APPS/TelephonyProvider_intermediates

for device in ${devices}
do
	#ROM
	if [ -d "${android}/out/target/product/${device}/system" ]; then
		rm -f ${android}/out/target/product/${device}/system/build.prop
		rm -f ${android}/out/target/product/${device}/system/lib/modules/*
		rm -f ${android}/out/target/product/${device}/system/xbin/su
	fi

	#kernel
	do_deldir ${android}/out/target/product/${device}/obj/KERNEL_OBJ/
	if [ -d "${android}/out/target/product/${device}" ]; then
		cd ${android}/out/target/product/${device}/
		rm -f ./kernel ./*.img ./*.cpio ./*.fs
	fi

	#recovery
	do_deldir ${android}/out/target/product/${device}/obj/EXECUTABLES/recovery_intermediates
	do_deldir ${android}/out/target/product/${device}/obj/RECOVERY_EXECUTABLES
	do_deldir ${android}/out/target/product/${device}/obj/STATIC_LIBRARIES/libcrecovery_intermediates
	do_deldir ${android}/out/target/product/${device}/recovery/root
done

#Replaced projects
if [ "${init}" = "Y" ]; then
	do_deldir ${android}/system/su
	do_deldir ${android}/packages/apps/Superuser
	do_deldir ${android}/packages/apps/Trebuchet
	do_deldir ${android}/packages/apps/DeskClock
	do_deldir ${android}/packages/apps/CMUpdater
	do_deldir ${android}/packages/apps/CMFileManager
	do_deldir ${android}/packages/apps/Apollo
	do_deldir ${android}/bootable/recovery
	do_deldir ${android}/external/busybox
	do_deldir ${android}/kernel/semc/msm7x30

	do_deldir ${android}/.repo/projects/system/su.git
	do_deldir ${android}/.repo/projects/packages/apps/Superuser.git
	do_deldir ${android}/.repo/projects/packages/apps/Trebuchet.git
	do_deldir ${android}/.repo/projects/packages/apps/DeskClock.git
	do_deldir ${android}/.repo/projects/packages/apps/CMUpdater.git
	do_deldir ${android}/.repo/projects/packages/apps/CMFileManager.git
	do_deldir ${android}/.repo/projects/packages/apps/Apollo.git
	do_deldir ${android}/.repo/projects/bootable/recovery.git
	do_deldir ${android}/.repo/projects/external/busybox.git
	do_deldir ${android}/.repo/projects/kernel/semc/msm7x30.git
fi

#Local manifest
echo "*** Local manifest ***"
mkdir -p ${android}/.repo/local_manifests
cp ${patches}/cmxtended.xml ${android}/.repo/local_manifests/cmxtended.xml
if [ "${init}" = "Y" ]; then
	${repo} sync
fi

#kernel
if [ "${kernel3}" = "Y" ]; then
	echo "--- Kernel 3.0"
	sed -i "/msm7x30-2.6.32.x-nAa/d" ${android}/.repo/local_manifests/cmxtended.xml
else
	echo "--- Kernel 2.6.32"
	sed -i "/msm7x30-3.0.x-nAa/d" ${android}/.repo/local_manifests/cmxtended.xml
fi

#su koush
if [ "${superuser_koush}" = "Y" ]; then
	echo "--- Superuser koush"
	if [ "${superuser_embed}" = "Y" ]; then
		sed -i "/koush/d" ${android}/.repo/local_manifests/cmxtended.xml
	fi
else
	sed -i "/koush/d" ${android}/.repo/local_manifests/cmxtended.xml
	sed -i "/android_system_su/d" ${android}/.repo/local_manifests/cmxtended.xml
	sed -i "/android_packages_apps_Superuser/d" ${android}/.repo/local_manifests/cmxtended.xml
fi

#Trebuchet CM10.1
if [ "${trebuchet_cm10_1}" = "Y" ]; then
	echo "--- Trebuchet CM10.1"
else
	sed -i "/android_packages_apps_Trebuchet/d" ${android}/.repo/local_manifests/cmxtended.xml
fi

#DeskClock CM10.1
if [ "${deskclock_cm10_1}" = "Y" ]; then
	echo "--- DeskClock CM10.1"
else
	sed -i "/android_packages_apps_DeskClock/d" ${android}/.repo/local_manifests/cmxtended.xml
fi

#busybox CM10.1
if [ "${busybox_cm10_1}" = "Y" ]; then
	echo "--- busybox CM10.1"
else
	sed -i "/android_external_busybox/d" ${android}/.repo/local_manifests/cmxtended.xml
fi

#CMFileManager CM10.1
if [ "${cmfilemanager_cm10_1}" = "Y" ]; then
	echo "--- CMFileManager CM10.1"
else
	sed -i "/android_packages_apps_CMFileManager/d" ${android}/.repo/local_manifests/cmxtended.xml
fi

if [ "${iw}" = "Y" ]; then
	echo "--- iw"
else
	sed -i "/dickychiang/d" ${android}/.repo/local_manifests/cmxtended.xml
fi

#Apollo CM10.1
if [ "${apollo_cm10_1}" = "Y" ]; then
	echo "--- Apollo CM10.1"
else
	sed -i "/android_packages_apps_Apollo/d" ${android}/.repo/local_manifests/cmxtended.xml
fi

#CWM CM10.1
if [ "${cwm_cm10_1}" = "Y" ]; then
	echo "--- CWM CM10.1"
else
	sed -i "/android_bootable_recovery/d" ${android}/.repo/local_manifests/cmxtended.xml
fi

#CMUpdater
if [ "${updates}" != "Y" ]; then
	sed -i "/android_packages_apps_CMUpdater/d" ${android}/.repo/local_manifests/cmxtended.xml
fi

#Synchronize
echo "*** Repo sync ***"
cd ${android}
${repo} forall -c "git reset --hard && git clean -df"
if [ $? -ne 0 ]; then
	exit
fi
${repo} sync
if [ $? -ne 0 ]; then
	exit
fi

#Linaro toolchain
if [ "${kernel_linaro}" = "Y" ]; then
	echo "*** Linaro toolchain: ${linaro_name} ***"
	linaro_dir=${android}/prebuilt/linux-x86/toolchain/${linaro_name}/
	if [ ! -d "${linaro_dir}" ]; then
		linaro_dl=~/Downloads/${linaro_file}
		if [ ! -f "${linaro_dl}" ]; then
			wget -O ${linaro_dl} ${linaro_url}
			if [ $? -ne 0 ]; then
				exit
			fi
		fi
		echo "--- Extracting"
		cd ${tmp}
		if [ -d "./android-toolchain-eabi/" ]; then
			chmod 777 ./android-toolchain-eabi/
			rm -R ./android-toolchain-eabi/
		fi
		tar -jxf ${linaro_dl}
		mkdir ${linaro_dir}
		echo "--- Installing"
		cp -R ./android-toolchain-eabi/* ${linaro_dir}
	fi
fi

#Prebuilts
if [ "${openpdroid}" = "Y" ]; then
	do_append "curl -L -o ${android}/vendor/cm/proprietary/PDroid_Manager.apk -O -L https://github.com/wsot/pdroid_manager_build/blob/master/PDroid_Manager_latest.apk?raw=true" ${android}/vendor/cm/get-prebuilts
	do_append "PRODUCT_COPY_FILES += vendor/cm/proprietary/PDroid_Manager.apk:system/app/PDroid_Manager.apk" ${android}/vendor/cm/config/common.mk
fi

if [ "${updates}" = "Y" ]; then
	do_append "curl -L -o ${android}/vendor/cm/proprietary/GooManager.apk -O -L https://github.com/solarnz/GooManager_prebuilt/blob/master/GooManager.apk?raw=true" ${android}/vendor/cm/get-prebuilts
	do_append "PRODUCT_COPY_FILES += vendor/cm/proprietary/GooManager.apk:system/app/GooManager.apk" ${android}/vendor/cm/config/common.mk
fi

if [ "${superuser_embed}" = "Y" ]; then
	do_append "curl -L -o ${android}/vendor/cm/proprietary/Superuser.apk -O -L http://download.clockworkmod.com/apks/Superuser.apk" ${android}/vendor/cm/get-prebuilts
	do_append "unzip -o -d ${android}/vendor/cm/proprietary ${android}/vendor/cm/proprietary/Superuser.apk assets/armeabi/*" ${android}/vendor/cm/get-prebuilts
	do_append "PRODUCT_COPY_FILES += vendor/cm/proprietary/Superuser.apk:system/app/Superuser.apk" ${android}/vendor/cm/config/common.mk
	do_append "PRODUCT_COPY_FILES += vendor/cm/proprietary/assets/armeabi/su:system/xbin/su" ${android}/vendor/cm/config/common.mk
else
	do_append "SUPERUSER_PACKAGE := com.m66b.superuser" ${android}/device/semc/msm7x30-common/BoardConfigCommon.mk
fi

${android}/vendor/cm/get-prebuilts
if [ $? -ne 0 ]; then
	exit
fi

#APN's CM10.1
if [ "${apn_cm10_1}" = "Y" ]; then
	cd ${android}/vendor/cm/prebuilt/common/etc
	wget -N https://raw.github.com/CyanogenMod/android_vendor_cm/cm-10.1/prebuilt/common/etc/apns-conf.xml
fi

#One core build
if [ "${onecorebuild}" = "Y" ]; then
	echo "*** One core build"
	cd ${android}/build
	do_patch onecore.patch
fi

#--- kernel ---

#Linaro
if [ "${kernel_linaro}" = "Y" ]; then
	echo "*** Kernel Linaro toolchain"
	cd ${android}/device/semc/msm7x30-common
	do_patch linaro.patch
	for device in ${devices}
	do
		do_replace "arm-eabi-4.4.3" "${linaro_name}" ${android}/device/semc/${device}/BoardConfig.mk
	done
fi

#nAa msm7x30 kernel
#caf 2.6.32: M7630AABBQMLZA41601050
#caf 3.0.8: M7630AABBQMLZA404033I
if [ "${kernel_mods}" = "Y" ]; then
	echo "*** Kernel ***"
	cd ${android}/kernel/semc/msm7x30/

	if [ "${kernel3}" != "Y" ]; then
		if [ "${kernel_xtended_perm}" = "Y" ]; then
			echo "--- Xtended permissions"
			do_patch kernel_smartass_perm.patch
			do_patch kernel_autogroup_perm.patch
		fi

		if [ "${kernel_wifi_range}" = "Y" ]; then
			echo "--- Wi-Fi range"
			do_patch kernel_wifi_range.patch
		fi

		if [ "${kernel_displaylink}" = "Y" ]; then
			echo "--- DisplayLink"
			do_patch kernel_fbudl.patch
			for device in ${devices}
			do
				kconfig=${android}/kernel/semc/msm7x30/arch/arm/configs/cyanogen_${device}_defconfig
				if [ -f ${kconfig} ]; then
					do_replace "# CONFIG_FB_UDL is not set" "CONFIG_FB_UDL=m" ${kconfig}
					#do_replace "CONFIG_USB_OTG_WHITELIST=y" "CONFIG_USB_OTG_WHITELIST=n" ${kconfig}
				fi
			done
		fi
	fi

	if [ "${kernel3}" = "Y" ]; then
		#cp ${patches}/nAa3_iyokan_defconfig arch/arm/configs/nAa_iyokan_defconfig
		do_patch kernel3_iyokan_adds.patch
		do_patch kernel3_iyokan_mods.patch
	fi

	for device in ${devices}
	do
		if [ -f arch/arm/configs/nAa_${device}_defconfig ]; then
			echo "--- Config ${device}"
			cp arch/arm/configs/nAa_${device}_defconfig arch/arm/configs/cm_${device}_defconfig
			do_replace "# CONFIG_SCHED_AUTOGROUP is not set" "CONFIG_SCHED_AUTOGROUP=y" arch/arm/configs/cm_${device}_defconfig
		else
			echo "--- No kernel config for ${device}"
		fi
	done
fi

#Boot logo
if [ "${bootlogo}" = "Y" ]; then
	echo "*** Boot logo ***"
	gcc -O2 -Wall -Wno-unused-parameter -Wno-unused-result -o ${tmp}/to565 ${android}/build/tools/rgb2565/to565.c

	if [ ! -f ${tmp}/logo_H_new.raw ]; then
		convert -depth 8 ${patches}/bootlogo/${bootlogoh} -fill grey -gravity south -draw "text 0,10 '`date -R`'" rgb:${tmp}/logo_H_new.raw
		if [ $? -ne 0 ]; then
			echo "imagemagick not installed?"
			exit
		fi
	fi
	${tmp}/to565 -rle <${tmp}/logo_H_new.raw >${android}/device/semc/msm7x30-common/prebuilt/logo_H.rle

	if [ ! -f ${tmp}/logo_M_new.raw ]; then
		convert -depth 8 ${patches}/bootlogo/${bootlogom} -fill grey -gravity south -draw "text 0,10 '`date -R`'" rgb:${tmp}/logo_M_new.raw
		if [ $? -ne 0 ]; then
			echo "imagemagick not installed?"
			exit
		fi
	fi
	${tmp}/to565 -rle <${tmp}/logo_M_new.raw >${android}/device/semc/msm7x30-common/prebuilt/logo_M.rle
fi

#pincode
if [ "${pin}" = "Y" ]; then
	echo "*** Pincode"
	cd ${android}/bootable/recovery
	do_patch recovery_check_pin.patch
	cd ${android}/device/semc/msm7x30-common
	do_patch msm7x30_check_pin.patch
	cd ${android}/device/semc/mogami-common
	do_patch mogami_check_pin.patch
	for device in ${devices}
	do
		initrc=${android}/device/semc/${device}/recovery/init.rc
		do_replace "    restart adbd" "    #restart adbd" ${initrc}
	done
fi

if [ "${kernel3}" = "Y" ]; then
	echo "*** Kernel 3.x ***"

	#recovery key check
	cd ${android}/device/semc/msm7x30-common
	do_patch msm7x30_kernel3.patch

	#boot logo
	do_replace "logo.rle" "initlogo.rle" ${android}/device/semc/msm7x30-common/custombootimg.mk
	for device in ${devices}
	do
		do_replace "logo.rle" "initlogo.rle" ${android}/device/semc/${device}/${device}.mk
	done

	#Wi-Fi
	cp /lib/firmware/ti-connectivity/wl127x-fw-5-sr.bin ${android}/device/semc/mogami-common/prebuilt/wl127x-fw-5-sr.bin
	do_append "PRODUCT_COPY_FILES += device/semc/mogami-common/prebuilt/wl127x-fw-5-sr.bin:root/firmware/wl127x-fw-5-sr.bin" ${android}/device/semc/mogami-common/mogami.mk
	do_replace "wl12xx_sdio.ko" "wlcore_sdio.ko" ${android}/device/semc/mogami-common/prebuilt/wifiload
fi

#--- ROM ---

#Cell broadcast
if [ "${cellbroadcast}" = "Y" ]; then
	echo "*** Cell broadcast ***"
	do_append "PRODUCT_PACKAGES += CellBroadcastReceiver" ${android}/build/target/product/core.mk
	#do_append "PRODUCT_PROPERTY_OVERRIDES += ro.cellbroadcast.emergencyids=0-65534" ${android}/build/target/product/core.mk
	cd ${android}/device/semc/mogami-common
	do_patch cb_settings.patch
fi

#OpenPDroid
if [ "${openpdroid}" = "Y" ]; then
	echo "*** OpenPDroid ***"
	cd ~/Downloads
	if [ ! -d "OpenPDroidPatches" ]; then
		git clone git://github.com/OpenPDroid/OpenPDroidPatches.git
	fi
	cd OpenPDroidPatches
	git checkout 4.1.2-cm
	git pull

	cd ${android}/build
	patch -p1 --forward -r- <~/Downloads/OpenPDroidPatches/openpdroid_4.1.2-cm_build.patch
	cd ${android}/libcore
	patch -p1 --forward -r- <~/Downloads/OpenPDroidPatches/openpdroid_4.1.2-cm_libcore.patch
	cd ${android}/packages/apps/Mms
	patch -p1 --forward -r- <~/Downloads/OpenPDroidPatches/openpdroid_4.1.2-cm_packages_apps_Mms.patch
	cd ${android}/frameworks/base
	patch -p1 --forward -r- <~/Downloads/OpenPDroidPatches/openpdroid_4.1.2-cm_frameworks_base.patch
	do_patch openpdroid_network_location.patch

	mkdir -p ${android}/privacy
	cp ~/Downloads/OpenPDroidPatches/PDroid.jpeg ${android}/privacy
	do_append "PRODUCT_COPY_FILES += privacy/PDroid.jpeg:system/media/PDroid.jpeg" ${android}/vendor/cm/config/common.mk
fi

#nano
if [ "${nano}" = "Y" ]; then
	echo "*** Nano enter key ***"
	cd ${android}/external/nano
	do_patch nano.patch
fi

#terminfo
if [ "${terminfo}" = "Y" ]; then
	echo "*** Terminfo ***"
	terminfo_dl=~/Downloads/termtypes.master.gz
	if [ ! -f "${terminfo_dl}" ]; then
		wget -O ${terminfo_dl} http://catb.org/terminfo/termtypes.master.gz
		if [ $? -ne 0 ]; then
			exit
		fi
	fi

	echo "--- Extracting"
	gunzip <${terminfo_dl} >${tmp}/termtypes.master
	echo "--- Converting"
	tic -o ${android}/vendor/cm/prebuilt/common/etc/terminfo/ ${tmp}/termtypes.master
	if [ $? -ne 0 ]; then
		exit
	fi
	echo "--- Installing"
	do_append "PRODUCT_COPY_FILES += \\" ${android}/vendor/cm/config/common.mk
	cd ${android}/vendor/cm/prebuilt/common
	find etc/terminfo -type f -exec echo "    vendor/cm/prebuilt/common/{}:system/{} \\" >>${android}/vendor/cm/config/common.mk \;

	cd ${android}/vendor/cm/prebuilt/common/etc
	do_patch mkshrc.patch
fi

#Empty drawer
if [ "${emptydrawer}" = "Y" ]; then
	echo "*** Empty drawer ***"
	cd ${android}/bionic
	do_patch drawer.patch
fi

#Mass storage
if [ "${massstorage}" = "Y" ]; then
	echo "*** Mass storage ***"
	cd ${android}/device/semc/msm7x30-common
	do_patch mass_storage.patch
fi

#Xtended settings
if [ "${xsettings}" = "Y" ]; then
	echo "*** Xtended settings ***"
	cd ${android}/packages/apps/Settings
	do_patch xsettings.patch
	cd ${android}/device/semc/mogami-common
	do_patch mogami_xtended.patch
fi

#Wi-Fi auto connect option
if [ "${wifiautoconnect}" = "Y" ]; then
	echo "*** Wi-Fi auto connect option ***"
	cd ${android}/frameworks/base
	do_patch wifi_auto_connect1.patch
	cd ${android}/packages/apps/Settings
	do_patch wifi_auto_connect2.patch
fi

#Electron beam animation
if [ "${eba}" = "Y" ]; then
	echo "*** Electron beam animation ***"
	cd ${android}/frameworks/base
	do_patch eba.patch
	do_patch eba_frameworks.patch
	cd ${android}/packages/apps/Settings
	do_patch eba_settings.patch
fi

#ssh
if [ "${ssh}" = "Y" ]; then
	echo "*** sftp-server ***"
	cd ${android}/external/openssh
	do_patch sftp-server.patch
	#needs extra 'mmm external/openssh'
fi

#Layout fixes
if [ "${layout}" = "Y" ]; then
	echo "*** Enabled expanded desktop ***"
	cd ${android}/device/semc/msm7x30-common
	do_patch layout_desktop.patch

	echo "*** Clear all button layout ***"
	cd ${android}/frameworks/base
	do_patch clear_all_button.patch
fi

#Music volume
if [ "${mvolume}" = "Y" ]; then
	echo "*** Finer music volume ***"
	cd ${android}/frameworks/base
	do_patch music_volume.patch
fi

#qcom display
if [ "${qcomdispl}" = "Y" ]; then
	echo "*** qcom display ***"
	cd ${android}/hardware/qcom/display
	do_patch qcom_display_heap.patch
	do_patch qcom_display_ioctl.patch
fi

#Smartass boost pulse
if [ "${boost_pulse}" = "Y" ]; then
	echo "*** Enable Smartass boost pulse ***"
	cd ${android}/device/semc/msm7x30-common
	do_patch power_boost_pulse.patch
fi

#goo.im
if [ "${updates}" = "Y" ]; then
	echo "*** goo.im ***"
	do_append "PRODUCT_PROPERTY_OVERRIDES += \\" ${android}/device/semc/msm7x30-common/msm7x30.mk
	do_append "    ro.goo.developerid=M66B \\" ${android}/device/semc/msm7x30-common/msm7x30.mk
	do_append "    ro.goo.rom=Xtended \\" ${android}/device/semc/msm7x30-common/msm7x30.mk
	do_append "    ro.goo.version=\$(shell date +%s)" ${android}/device/semc/msm7x30-common/msm7x30.mk
fi

#iw
if [ "${iw}" = "Y" ]; then
	echo "*** iw ***"
	cd ${android}/external/iw
	do_patch iw.patch
	cd ${android}/vendor/semc
	do_patch vendor_semc_iw.patch
fi

#MMS fix
if [ "${mmsfix}" = "Y" ]; then
	echo "*** MMS fix ***"
	cd ${android}/packages/apps/Mms
	do_patch mms_cursor.patch
	do_patch mms_cursor2.patch
fi

#Trebuchet CM10.1
if [ "${trebuchet_cm10_1}" = "Y" ]; then
	echo "*** Trebuchet CM10.1 ***"
	if [ -f ${android}/vendor/cm/overlay/common/packages/apps/Trebuchet/res/values/config.xml ];
	then
		rm ${android}/vendor/cm/overlay/common/packages/apps/Trebuchet/res/values/config.xml
	echo "config.xml removed"
	fi
	cd ${android}/packages/apps/Trebuchet
	do_patch trebuchet_port.patch
	do_patch trebuchet_fix_build.patch
fi

#DeskClock CM10.1
if [ "${deskclock_cm10_1}" = "Y" ]; then
	echo "*** DeskClock CM10.1 ***"
	cd ${android}/packages/apps/DeskClock
	do_patch deskclock_cm_10_1.patch
fi

#Superuser Koush
if [ "${superuser_koush}" = "Y" ] && [ "${superuser_embed}" != "Y" ]; then
	echo "*** Superuser Koush"
	cd ${android}/external/koush/Superuser
	do_patch superuser_koush_superuser.patch
	cd ${android}/external/koush/Widgets
	do_patch superuser_koush_widgets.patch
fi

#CMFileManager CM10.1
if [ "${cmfilemanager_cm10_1}" = "Y" ]; then
	echo "*** CMFileManager CM10.1 ***"
	cd ${android}/packages/apps/CMFileManager
	do_patch cmfilemanager_cm10_1.patch
fi

#Apollo CM10.1
if [ "${apollo_cm10_1}" = "Y" ]; then
	echo "*** Apollo CM10.1 ***"
	cd ${android}/packages/apps/Apollo
	do_patch apollo_cm_10_1.patch
fi

#CWM CM10.1
if [ "${cwm_cm10_1}" = "Y" ]; then
	echo "*** CWM CM10.1 ***"
	cd ${android}/bootable/recovery
	do_patch recovery_cm10_1.patch
	cd ${android}/system/core
	do_patch system_core_libsparse.patch
fi

#Custom patches
if [ -f ~/.cm10xtended.sh ]; then
	. ~/.cm10xtended.sh
fi

#Environment
echo "*** Setup environment ***"
cd ${android}
. build/envsetup.sh

#Say whats next
echo ""
echo "*** Done ***"
echo ""
echo "brunch <device name>"
echo ""
echo "or"
echo ""
echo "lunch cm_<device name>-userdebug"
echo "make bootimage"
echo ""
