CM10/FXP extended ROM/kernel


BUILDING

0. Make sure you have at least 25 GB of free disk space
1a. Setup the build environment as explained here: http://forum.xda-developers.com/showthread.php?t=1807505,
1b. Follow the instuctions until the second 'repo sync'
1c. Delete the following folders:

	~/android/system/system/su
	~/android/system/packages/apps/Superuser
	~/android/system/packages/apps/Trebuchet
	~/android/system/.repo/projects/system/su.git
	~/android/system/.repo/projects/packages/apps/Superuser.git
	~/android/system/.repo/projects/packages/apps/Trebuchet.git

2. Run the command: cd ~/Downloads && git clone https://github.com/M66B/cm10-fxp-extended.git
3. Run the command: sh ~/Downloads/cm10-fxp-extended/update.sh
4. Start the build as explained in the setup guide from step #1

The script resets your build environment to pristine state and applies the provided patches for the extended ROM/kernel.

*** USE AT YOUR OWN RISK !!! ***


LICENSE

GNU General Public License version 3

Copyright (c) 2012-2013 Marcel Bokhorst http://blog.bokhorst.biz/about/

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
