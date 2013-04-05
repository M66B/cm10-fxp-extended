#!/bin/sh

cd "`dirname \"$0\"`"
patches=`pwd`

#Configuration
android=~/android/system
devices="anzu coconut haida hallon iyokan mango satsuma smultron urushi"
debug=N
cleanall=N
updates=N
if [ "`hostname`" = "ALGEIBA" ] || [ "`hostname`" = "HTPC" ]; then
	updates=Y
fi
if [ "$1" = "clean" ]; then
	cleanall=Y
fi
onecorebuild=N
if [ "`hostname`" = "ALGEIBA" ]; then
	onecorebuild=Y
fi

linaro_name=arm-eabi-4.7-linaro
linaro_file=android-toolchain-eabi-4.7-daily-linux-x86.tar.bz2
linaro_url=https://android-build.linaro.org/jenkins/view/Toolchain/job/linaro-android_toolchain-4.7-bzr/lastSuccessfulBuild/artifact/build/out/${linaro_file}

#Building TWRP with 32 bits toolchain fails
toolchain_32bit=N

#--- bootimage ---

kernel_mods=Y
kernel_linaro=Y
kernel_naa=Y
kernel_cpugovernors=Y
kernel_smartass2_boost=Y
kernel_smartass3_boost=Y
kernel_ioschedulers=Y
kernel_voltage=Y
kernel_autogroup=Y
kernel_wifi_range=Y
kernel_rcutiny=Y
kernel_displaylink=Y
kernel_videodriver=Y
kernel_binder60=Y
kernel_whisper=N
kernel_hdmi=N
kernel_misc=Y

bootlogo=Y
bootlogoh=logo_H_extended.png
bootlogom=logo_M_extended.png

#TWRP known issues: http://forum.xda-developers.com/showpost.php?p=38834687&postcount=4
twrp=N

#--- ROM ---

cellbroadcast=Y
datallowed=Y
openpdroid=Y
nano=Y
terminfo=Y
emptydrawer=Y
massstorage=Y
enable720p=N
xsettings=Y
wifiautoconnect=Y
eba=Y
ssh=Y
layout=Y
mvolume=Y
qcomdispl=Y
iw=Y
mmsfix=Y
trebuchet_cm10_1=Y
deskclock_cm10_1=Y
superuser_cm10_1=N
superuser_koush=Y
browser_cm10_1=N    #unfinished
busybox_cm10_1=Y

#Say hello
echo ""
echo "CM/FXP extended ROM/kernel"
echo "Copyright (c) 2012-2013 Marcel Bokhorst (M66B)"
echo "http://blog.bokhorst.biz/about/"
echo ""
echo "GNU GENERAL PUBLIC LICENSE Version 3"
echo ""
echo "Patches: ${patches}"
echo "Android: ${android}"
echo "Devices: ${devices}"
echo "Clean: ${cleanall}"
echo ""
read -p "Press [ENTER] to continue" dummy
echo ""

#Define helper functions
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
do_deldir ${android}/out/target/common/obj/JAVA_LIBRARIES/framework_intermediates
do_deldir ${android}/out/target/common/obj/JAVA_LIBRARIES/framework2_intermediates
do_deldir ${android}/out/target/common/obj/APPS/TelephonyProvider_intermediates
do_deldir ${android}/hardware/somc/dash

for device in ${devices}
do
	#ROM
	if [ -d "${android}/out/target/product/${device}/system" ]; then
		rm -f ${android}/out/target/product/${device}/system/build.prop
		rm -f ${android}/out/target/product/${device}/system/lib/modules/*
	fi

	#kernel
	do_deldir ${android}/out/target/product/${device}/obj/KERNEL_OBJ/
	if [ -d "${android}/out/target/product/${device}" ]; then
		cd ${android}/out/target/product/${device}/
		rm -f ./kernel ./*.img ./*.cpio ./*.fs
		rm -f ./root/filler*
	fi

	#recovery
	do_deldir ${android}/out/target/product/${device}/obj/EXECUTABLES/recovery_intermediates
	do_deldir ${android}/out/target/product/${device}/obj/RECOVERY_EXECUTABLES
	do_deldir ${android}/out/target/product/${device}/obj/STATIC_LIBRARIES/libcrecovery_intermediates
	do_deldir ${android}/out/target/product/${device}/recovery/root
done

if [ "${cleanall}" = "Y" ]; then
	do_deldir ${android}/bootable/recovery
	do_deldir ${android}/system/su
	do_deldir ${android}/packages/apps/Superuser
	do_deldir ${android}/packages/apps/Trebuchet
	do_deldir ${android}/packages/apps/DeskClock
	do_deldir ${android}/packages/apps/Browser
	do_deldir ${android}/packages/apps/CMUpdater
	do_deldir ${android}/external/webkit
	do_deldir ${android}/external/skia
	do_deldir ${android}/external/webp
	do_deldir ${android}/external/webrtc
	do_deldir ${android}/external/icu4c
	do_deldir ${android}/external/chromium
	do_deldir ${android}/external/chromium-trace
	do_deldir ${android}/external/v8
	do_deldir ${android}/external/koush
	do_deldir ${android}/external/busybox
	do_deldir ${android}/kernel/semc/msm7x30

	do_deldir ${android}/.repo/projects/bootable/recovery.git
	do_deldir ${android}/.repo/projects/system/su.git
	do_deldir ${android}/.repo/projects/packages/apps/Superuser.git
	do_deldir ${android}/.repo/projects/packages/apps/Trebuchet.git
	do_deldir ${android}/.repo/projects/packages/apps/DeskClock.git
	do_deldir ${android}/.repo/projects/packages/apps/Browser.git
	do_deldir ${android}/.repo/projects/packages/apps/CMUpdater.git
	do_deldir ${android}/.repo/projects/external/webkit.git
	do_deldir ${android}/.repo/projects/external/skia.git
	do_deldir ${android}/.repo/projects/external/webp.git
	do_deldir ${android}/.repo/projects/external/webrtc.git
	do_deldir ${android}/.repo/projects/external/icu4c.git
	do_deldir ${android}/.repo/projects/external/chromium.git
	do_deldir ${android}/.repo/projects/external/chromium-trace.git
	do_deldir ${android}/.repo/projects/external/v8.git
	do_deldir ${android}/.repo/projects/external/busybox.git
	do_deldir ${android}/.repo/projects/kernel/semc/msm7x30.git
fi

#Local manifest
echo "*** Local manifest ***"
mkdir -p ${android}/.repo/local_manifests
cp ${patches}/cmxtended.xml ${android}/.repo/local_manifests/cmxtended.xml


#Kernel nobodyAtall
if [ "${kernel_naa}" = "Y" ]; then
	echo "--- kernel nobodyAtall"
	#svn checkout http://lz4.googlecode.com/svn/trunk/ lz4
	#cd lz4 && make && cp lz4demo ~/bin/lz4
	#caf: M7630AABBQMLZA41601050
else
	sed -i "/remove-project.*semc-kernel-msm7x30/d" ${android}/.repo/local_manifests/cmxtended.xml
	sed -i "/nobodyAtall/d" ${android}/.repo/local_manifests/cmxtended.xml
fi

#twrp
if [ "${twrp}" = "Y" ]; then
	echo "--- TWRP"
else
	sed -i "/bootable/d" ${android}/.repo/local_manifests/cmxtended.xml
fi

#su
if [ "${superuser_cm10_1}" = "Y" ]; then
	echo "--- Superuser CM10.1"
else
	if [ "${superuser_koush}" != "Y" ]; then
		sed -i "/android_system_su/d" ${android}/.repo/local_manifests/cmxtended.xml
		sed -i "/android_packages_apps_Superuser/d" ${android}/.repo/local_manifests/cmxtended.xml
	fi
fi
if [ "${superuser_koush}" = "Y" ]; then
	echo "--- Superuser koush"
	sed -i "/system\/su/d" ${android}/.repo/local_manifests/cmxtended.xml
	sed -i "/packages\/apps\/Superuser/d" ${android}/.repo/local_manifests/cmxtended.xml
	do_append "SUPERUSER_PACKAGE := com.m66b.superuser" ${android}/device/semc/msm7x30-common/BoardConfigCommon.mk
else
	sed -i "/koush/d" ${android}/.repo/local_manifests/cmxtended.xml
fi

#Trebuchet
if [ "${trebuchet_cm10_1}" = "Y" ]; then
	echo "--- Trebuchet CM10.1"
else
	sed -i "/android_packages_apps_Trebuchet/d" ${android}/.repo/local_manifests/cmxtended.xml
fi

#DeskClock
if [ "${deskclock_cm10_1}" = "Y" ]; then
	echo "--- DeskClock CM10.1"
else
	sed -i "/android_packages_apps_DeskClock/d" ${android}/.repo/local_manifests/cmxtended.xml
fi

#Browser
if [ "${browser_cm10_1}" = "Y" ]; then
	echo "--- Browser/webkit CM10.1"
else
	sed -i "/android_packages_apps_Browser/d" ${android}/.repo/local_manifests/cmxtended.xml
	sed -i "/android_external_webkit/d" ${android}/.repo/local_manifests/cmxtended.xml
	sed -i "/android_external_skia/d" ${android}/.repo/local_manifests/cmxtended.xml
	sed -i "/android_external_webp/d" ${android}/.repo/local_manifests/cmxtended.xml
	sed -i "/android_external_webrtc/d" ${android}/.repo/local_manifests/cmxtended.xml
	sed -i "/android_external_icu4c/d" ${android}/.repo/local_manifests/cmxtended.xml
	sed -i "/android_external_chromium/d" ${android}/.repo/local_manifests/cmxtended.xml
	sed -i "/android_external_v8/d" ${android}/.repo/local_manifests/cmxtended.xml
fi

#busybox
if [ "${busybox_cm10_1}" = "Y" ]; then
	echo "--- busybox CM10.1"
else
	sed -i "/android_external_busybox/d" ${android}/.repo/local_manifests/cmxtended.xml
fi

if [ "${iw}" = "Y" ]; then
	echo "--- iw"
else
	sed -i "/dickychiang/d" ${android}/.repo/local_manifests/cmxtended.xml
fi

#Toolchain
if [ "${toolchain_32bit}" != "Y" ]; then
	sed -i "/androideabi/d" ${android}/.repo/local_manifests/cmxtended.xml
else
	echo "--- 32 bit toolchain"
fi

#CMUpdater
if [ "${updates}" != "Y" ]; then
	sed -i "/android_packages_apps_CMUpdater/d" ${android}/.repo/local_manifests/cmxtended.xml
fi

echo "*** Repo sync ***"
cd ${android}
repo forall -c "git reset --hard && git clean -df"
if [ $? -ne 0 ]; then
	exit
fi
repo sync
if [ $? -ne 0 ]; then
	exit
fi

#Linaro toolchain
if [ "${linaro}" = "Y" ] || [ "${kernel_linaro}" = "Y" ]; then
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
		cd /tmp
		if [ -d "./android-toolchain-eabi/" ]; then
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
${android}/vendor/cm/get-prebuilts
if [ $? -ne 0 ]; then
	exit
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

#msm7x30 kernel
if [ "${kernel_mods}" = "Y" ]; then
	echo "*** Kernel ***"
	cd ${android}/kernel/semc/msm7x30/
	if [ "${kernel_naa}" = "Y" ]; then
		echo "--- nobodyAtall"
		for device in ${devices}
		do
			if [ -f arch/arm/configs/nAa_${device}_defconfig ]; then
				cp arch/arm/configs/nAa_${device}_defconfig arch/arm/configs/cm_${device}_defconfig
			else
				echo "--- No kernel config for ${device}"
			fi
		done
	fi

	if [ "${kernel_linaro}" = "Y" ] && [ "${kernel_naa}" != "Y" ]; then
		echo "--- Linaro"
		do_patch kernel_linaro_head.patch
		do_patch kernel_linaro_boot.patch
	fi

	if [ "${kernel_cpugovernors}" = "Y" ]; then
		echo "--- CPU governors"
		if [ "${kernel_naa}" != "Y" ]; then
			do_patch kernel_cpugovernor.patch
			do_patch kernel_underclock.patch
			do_patch kernel_cpuminmax.patch
		fi

		if [ "${kernel_naa}" != "Y" ]; then
			for device in ${devices}
			do
				kconfig=${android}/kernel/semc/msm7x30/arch/arm/configs/cyanogen_${device}_defconfig

				do_append "CONFIG_CPU_FREQ_GOV_SMARTASS=y" ${kconfig}
				do_append "CONFIG_CPU_FREQ_GOV_SCARY=y" ${kconfig}
				do_append "CONFIG_CPU_FREQ_GOV_MINMAX=y" ${kconfig}
				do_append "CONFIG_CPU_FREQ_GOV_LAGFREE=y" ${kconfig}
				do_append "CONFIG_CPU_FREQ_GOV_INTERACTIVEX=y" ${kconfig}
				do_append "CONFIG_CPU_FREQ_GOV_SAVAGEDZEN=y" ${kconfig}
				do_append "CONFIG_CPU_FREQ_GOV_SMARTASS2=y" ${kconfig}
				do_append "CONFIG_CPU_FREQ_GOV_SMOOTHASS=y" ${kconfig}
				do_append "CONFIG_CPU_FREQ_GOV_BRAZILIANWAX=y" ${kconfig}

				do_append "CONFIG_CPU_FREQ_GOV_LAZY=y" ${kconfig}
				do_append "CONFIG_CPU_FREQ_GOV_BADASS=y" ${kconfig}
				do_append "CONFIG_CPU_FREQ_GOV_INTELLIDEMAND=y" ${kconfig}
				do_append "CONFIG_CPU_FREQ_GOV_LULZACTIVE=y" ${kconfig}
				do_append "CONFIG_CPU_FREQ_GOV_SUPERBAD=y" ${kconfig}
				do_append "CONFIG_CPU_FREQ_GOV_VIRTUOUS=y" ${kconfig}
				do_append "CONFIG_CPU_FREQ_GOV_DARKSIDE=y" ${kconfig}
				do_append "CONFIG_CPU_FREQ_GOV_LIONHEART=y" ${kconfig}
				do_append "CONFIG_CPU_FREQ_GOV_ONDEMANDX=y" ${kconfig}
				do_append "CONFIG_CPU_FREQ_GOV_INTELLIDEMAND2=y" ${kconfig}

				do_append "CONFIG_CPU_FREQ_GOV_SMARTASSH3=y" ${kconfig}
			done
		fi

		if [ "${kernel_smartass2_boost}" = "Y" ] && [ "${kernel_naa}" != "Y" ]; then
			echo "--- SmartassV2/H3 boost pulse"
			do_patch kernel_smartass2_boost.patch
			do_patch kernel_smartass3_boost.patch
		fi
		if [ "${kernel_smartass2_boost}" = "Y" ] || [ "${kernel_smartass3_boost}" = "Y" ]; then
			do_patch kernel_smartass_perm.patch
		fi
	fi

	if [ "${kernel_ioschedulers}" = "Y" ]; then
		echo "--- I/O schedulers"
		if [ "${kernel_naa}" != "Y" ]; then
			do_patch kernel_iosched.patch
		fi

		do_patch kernel_sio_params.patch

		if [ "${kernel_naa}" != "Y" ]; then
			for device in ${devices}
			do
				kconfig=${android}/kernel/semc/msm7x30/arch/arm/configs/cyanogen_${device}_defconfig
				do_replace "# CONFIG_IOSCHED_AS is not set" "CONFIG_IOSCHED_AS=y" ${kconfig}
				do_replace "# CONFIG_IOSCHED_CFQ is not set" "CONFIG_IOSCHED_CFQ=y" ${kconfig}
				do_append "CONFIG_IOSCHED_VR=y" ${kconfig}
				do_append "CONFIG_IOSCHED_SIO=y" ${kconfig}
			done
		fi
	fi

	if [ "${kernel_voltage}" = "Y" ] && [ "${kernel_naa}" != "Y" ]; then
		echo "--- Undervolt"
		do_patch kernel_board_config.patch
		for device in ${devices}
		do
			kconfig=${android}/kernel/semc/msm7x30/arch/arm/configs/cyanogen_${device}_defconfig
			if [ -f ${kconfig} ]; then
				do_append "CONFIG_CPU_FREQ_VDD_LEVELS=y" ${kconfig}
				if [ "${device}" = "iyokan" ]; then
					do_replace "CONFIG_MOGAMI_VIBRATOR_ON_VOLTAGE=2800" "CONFIG_MOGAMI_VIBRATOR_ON_VOLTAGE=2700" ${kconfig}
				elif [ "${device}" = "mango" ]; then
					do_replace "CONFIG_MOGAMI_VIBRATOR_ON_VOLTAGE=2700" "CONFIG_MOGAMI_VIBRATOR_ON_VOLTAGE=2600" ${kconfig}
				elif [ "${device}" = "smultron" ]; then
					do_replace "CONFIG_MOGAMI_VIBRATOR_ON_VOLTAGE=2900" "CONFIG_MOGAMI_VIBRATOR_ON_VOLTAGE=2800" ${kconfig}
				fi
			fi
		done
	fi

	if [ "${kernel_autogroup}" = "Y" ]; then
		echo "--- autogroup"
		if [ "${kernel_naa}" = "Y" ]; then
			do_patch kernel_autogroup_perm.patch
		else
			do_patch kernel_autogroup.patch
		fi
		for device in ${devices}
		do
			kconfig=${android}/kernel/semc/msm7x30/arch/arm/configs/cyanogen_${device}_defconfig
			if [ -f ${kconfig} ]; then
				sed -i "/CONFIG_SCHED_AUTOGROUP/d" ${kconfig}
				do_append "CONFIG_SCHED_AUTOGROUP=y" ${kconfig}
			fi
		done
	fi

	if [ "${kernel_wifi_range}" = "Y" ]; then
		echo "--- Wi-Fi range"
		do_patch kernel_wifi_range.patch
	fi

	if [ "${kernel_rcutiny}" = "Y" ] && [ "${kernel_naa}" != "Y" ]; then
		echo "--- RCU tiny"
		do_patch kernel_rcutiny.patch
		for device in ${devices}
		do
			kconfig=${android}/kernel/semc/msm7x30/arch/arm/configs/cyanogen_${device}_defconfig
			do_append "CONFIG_TINY_RCU=y" ${kconfig}
			do_replace "CONFIG_TREE_RCU=y" "# CONFIG_TREE_RCU is not set" ${kconfig}
		done
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

	if [ "${kernel_videodriver}" = "Y" ] && [ "${kernel_naa}" != "Y" ]; then
		echo "-- Video driver"
		do_patch kernel_videodriver.patch
	fi

	if [ "${kernel_binder60}" = "Y" ] && [ "${kernel_naa}" != "Y" ]; then
		echo "-- Android binder .60"
		do_patch kernel_binder60.patch
	fi

	if [ "${kernel_whisper}" = "Y" ]; then
		echo "-- Whisper yaffs"
		do_patch kernel_whisper.patch
		for device in ${devices}
		do
			kconfig=${android}/kernel/semc/msm7x30/arch/arm/configs/cyanogen_${device}_defconfig
			if [ -f ${kconfig} ]; then
				do_replace "# CONFIG_CRYPTO_GF128MUL is not set" "CONFIG_CRYPTO_GF128MUL=y" ${kconfig}
				do_replace "# CONFIG_CRYPTO_XTS is not set" "CONFIG_CRYPTO_XTS=y" ${kconfig}
			fi
		done
	fi

	if [ "${kernel_hdmi}" = "Y" ]; then
		echo "-- HDMI"
		#do_patch kernel_hdmi.patch
		#do_append "obj-\$(CONFIG_HDMI_SI9022) += hdmi/si9022/" ${android}/kernel/semc/msm7x30/drivers/video/Makefile
		#do_append "obj-\$(CONFIG_HDMI_EP932) += hdmi/ep932/" ${android}/kernel/semc/msm7x30/drivers/video/Makefile
		kconfig=${android}/kernel/semc/msm7x30/arch/arm/configs/cyanogen_iyokan_defconfig
		do_replace "# CONFIG_FB_MSM_HDMI_COMMON is not set" "CONFIG_FB_MSM_HDMI_COMMON=y" ${kconfig}
		do_replace "# CONFIG_FB_MSM_HDMI_MSM_PANEL is not set" "CONFIG_FB_MSM_HDMI_MSM_PANEL=y" ${kconfig}
		do_replace "# CONFIG_FB_MSM_HDMI_SII9024A_PANEL is not set" "CONFIG_FB_MSM_HDMI_SII9024A_PANEL=y" ${kconfig}
		do_replace "# CONFIG_FB_MSM_DTV is not set" "CONFIG_FB_MSM_DTV=y" ${kconfig}
		#do_append "CONFIG_HDMI_SI9022=y" ${kconfig}
		do_append "PRODUCT_PROPERTY_OVERRIDES += com.qc.hdmi_out=true" ${android}/device/semc/msm7x30-common/msm7x30.mk
		#modified: drivers/video/msm/mdp4.h
		#drivers/video/msm/external_common.h
		#drivers/video/msm/hdmi_msm.h
	fi

	if [ "${kernel_naa}" != "Y" ]; then
		echo "-- iyokan touch precision"
		do_patch kernel_iyokan_touch.patch
	fi

	if [ "${enable720p}" != "Y" ] && [ "${kernel_naa}" != "Y" ]; then
		echo "-- 720p disabled: free memory"
		do_patch kernel_disable_720p.patch
	fi

	if [ "${kernel_misc}" = "Y" ] && [ "${kernel_naa}" != "Y" ]; then
		echo "-- Misc"
		do_patch kernel_lowmem.patch
		do_patch kernel_oom_nokill.patch
		do_patch kernel_sysfs.patch
		do_patch kernel_readahead.patch

		for device in ${devices}
		do
			kconfig=${android}/kernel/semc/msm7x30/arch/arm/configs/cyanogen_${device}_defconfig
			do_replace "# CONFIG_IKCONFIG_PROC is not set" "CONFIG_IKCONFIG_PROC=y" ${kconfig}
			do_replace "CONFIG_SLAB=y" "# CONFIG_SLAB is not set" ${kconfig}
			do_replace "# CONFIG_SLUB is not set" "CONFIG_SLUB=y" ${kconfig}
		done
	fi
fi

#Boot logo
if [ "${bootlogo}" = "Y" ]; then
	echo "*** Boot logo ***"
	gcc -O2 -Wall -Wno-unused-parameter -Wno-unused-result -o /tmp/to565 ${android}/build/tools/rgb2565/to565.c

	convert -depth 8 ${patches}/bootlogo/${bootlogoh} rgb:/tmp/logo_H_new.raw
	if [ $? -ne 0 ]; then
		echo "imagemagick not installed?"
		exit
	fi
	/tmp/to565 -rle </tmp/logo_H_new.raw >${android}/device/semc/msm7x30-common/prebuilt/logo_H.rle

	convert -depth 8 ${patches}/bootlogo/${bootlogom} rgb:/tmp/logo_M_new.raw
	if [ $? -ne 0 ]; then
		echo "imagemagick not installed?"
		exit
	fi
	/tmp/to565 -rle </tmp/logo_M_new.raw >${android}/device/semc/msm7x30-common/prebuilt/logo_M.rle
fi

#twrp
if [ "${twrp}" = "Y" ]; then
	echo "*** Team Win Recovery Project ***"
	cd ${android}/bootable/recovery
	do_patch twrp.patch

	for device in ${devices}
	do
		resolution="320x480"
		if [ "${device}" = "anzu" ] || [ "${device}" = "hallon" ] || [ "${device}" = "haida" ] || [ "${device}" = "iyokan" ] || [ "${device}" = "urushi" ]; then
			resolution="480x854"
		fi
		echo "${device}: ${resolution}"

		cd ${android}/device/semc/${device}
		sed -i "s|export PATH /sbin|export PATH /sbin\n    export LD_LIBRARY_PATH .:/sbin|g" ${android}/device/semc/${device}/recovery/init.rc

		do_append "DEVICE_RESOLUTION := ${resolution}" ${android}/device/semc/${device}/BoardConfig.mk
		do_append "RECOVERY_GRAPHICS_USE_LINELENGTH := true" ${android}/device/semc/${device}/BoardConfig.mk
		do_append "TARGET_RECOVERY_PIXEL_FORMAT := \"RGB_565\"" ${android}/device/semc/${device}/BoardConfig.mk

		do_append "TW_HAS_NO_RECOVERY_PARTITION := true" ${android}/device/semc/${device}/BoardConfig.mk
		do_append "TW_HAS_NO_BOOT_PARTITION := true" ${android}/device/semc/${device}/BoardConfig.mk
		do_append "TW_NO_BATT_PERCENT := true" ${android}/device/semc/${device}/BoardConfig.mk
		#do_append "TW_INCLUDE_JB_CRYPTO := true" ${android}/device/semc/${device}/BoardConfig.mk
		#do_append "TW_NO_EXFAT_FUSE := true" ${android}/device/semc/${device}/BoardConfig.mk
	done
fi

#--- ROM ---

#Cell broadcast
if [ "${cellbroadcast}" = "Y" ]; then
	echo "*** Cell broadcast ***"
	do_append "PRODUCT_PACKAGES += CellBroadcastReceiver" ${android}/build/target/product/core.mk
	cd ${android}/device/semc/mogami-common
	do_patch cb_settings.patch
fi

#Data allowed
if [ "${datallowed}" = "Y" ]; then
	echo "*** Data allowed ***";
	cd ${android}/frameworks/base
	do_patch data_allowed.patch
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
	gunzip <${terminfo_dl} >/tmp/termtypes.master
	echo "--- Converting"
	tic -o ${android}/vendor/cm/prebuilt/common/etc/terminfo/ /tmp/termtypes.master
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

#720p
if [ "${enable720p}" = "Y" ]; then
	echo "*** Enable 720p ***"
	cd ${android}/device/semc/msm7x30-common
	do_patch enable_720p.patch
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
	do_patch qcom_display_glfinish.patch
	do_patch qcom_display_heap.patch
	do_patch qcom_display_ioctl.patch
fi

#SmartassV2 boost pulse
if [ "${kernel_smartass2_boost}" = "Y" ] || [ "${kernel_smartass3_boost}" = "Y" ]; then
	echo "*** Enable SmartassV2 boost pulse ***"
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

#Browser CM10.1
if [ "${browser_cm10_1}" = "Y" ]; then
	echo "*** Browser CM10.1 ***"
	cd ${android}/external/webkit
	do_patch webkit.patch
	cd ${android}/frameworks/base
	do_patch framework_base_webkit_jni.patch
fi

#Superuser Koush
if [ "${superuser_koush}" = "Y" ]; then
	echo "*** Superuser Koush"
	cd ${android}/external/koush/Superuser
	do_patch superuser_koush_superuser.patch
	cd ${android}/external/koush/Widgets
	do_patch superuser_koush_widgets.patch
fi

#Say whats next
echo "*** Done ***"
echo ""
echo "cd ${android}"
echo ". build/envsetup.sh"
echo ""
echo "brunch <device name>"
echo ""
echo "or"
echo ""
echo "lunch cm_<device name>-userdebug"
echo "make bootimage"
echo ""
