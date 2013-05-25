#!/bin/bash
{
	export TMPDIR=~/tmp

	goofull=N
	goodevices="iyokan mango coconut smultron"
	gootarget=/home/M66B/public_html/test

	if [ "${goofull}" = "Y" ]; then
		echo "Full"
		cd ~/android/system
		for goodevice in ${goodevices}; do
			echo "-- ${goodevice}"
			rm -R out/target/product/${goodevice}
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
	for goodevice in ${goodevices}; do
		echo "-- ${goodevice}"
		brunch cm_${goodevice}-userdebug
		mmm external/openssh
		brunch cm_${goodevice}-userdebug
		rom="$(ls -t1 out/target/product/${goodevice}/cm-10-*-UNOFFICIAL-${goodevice}.zip | head -n1)"
		echo "-- ${rom} --> ${gootarget}/${goodevice}"
		scp -P 2222 ${rom} M66B@upload.goo.im:${gootarget}/${goodevice}/
	done

	echo "Done"
} >~/x10.log 2>&1
