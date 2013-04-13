#!/bin/bash
{
	full=N
	devices="coconut iyokan mango smultron"
	target=/home/M66B/public_html/test

	echo "Cleanup"
	cd ~/android/system
	if [ "${full}" = "Y" ]; then
		for device in ${devices}
		do
			echo "-- ${device}"
			rm -R out/target/product/${device}
		done
	fi

	echo "Xtended"
	cd ~/Downloads/cm10-fxp-extended
	git pull
	buildbot=Y
	source ~/Downloads/cm10-fxp-extended/update.sh

	echo "Environment"
	. build/envsetup.sh

	echo "Build"
	for device in ${devices}
	do
		echo "-- ${device}"
		if [ "${full}" = "Y" ]; then
			brunch cm_${device}-userdebug
			mmm external/openssh
		fi
		brunch cm_${device}-userdebug
		rom="$(ls -t1 out/target/product/${device}/cm-10-*-UNOFFICIAL-${device}.zip | head -n1)"
		echo "-- ${rom} --> ${target}/${device}"
		scp -P 2222 ${rom} M66B@upload.goo.im:${target}/${device}/
	done
} >~/xtended.log 2>&1
