#!/bin/bash

##################################################################
# Created by Christian Haitian for use to easily update          #
# various standalone emulators, libretro cores, and other        #
# various programs for the RK3566 platform for various Linux     #
# based distributions.                                           #
# See the LICENSE.md file at the top-level directory of this     #
# repository.                                                    #
##################################################################

cur_wd="$PWD"
bitness="$(getconf LONG_BIT)"

	# dolphin Standalone build
	if [[ "$var" == "dolphinsa" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd

	  # Now we'll start the clone and build of dolphin standalone
	  if [ ! -d "dolphin/" ]; then
		git clone --recursive https://github.com/rtissera/dolphin.git -b egldrm

		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the dolphin standalone git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/dolphinsa-patch* dolphin/.
	  else
		echo " "
		echo "A dolphin standalone subfolder already exists.  Stopping here to not impact anything in the folder that may be needed.  If not needed, please remove the dolphin standalone folder and rerun this script."
		echo " "
		exit 1
	  fi

	 cd dolphin
	 
	 dolphin_patches=$(find *.patch)
	 
	 if [[ ! -z "$dolphin_patches" ]]; then
	  for patching in dolphinsa-patch*
	  do
		   patch -Np1 < "$patching"
		   if [[ $? != "0" ]]; then
			echo " "
			echo "There was an error while applying $patching.  Stopping here."
			exit 1
		   fi
		   rm "$patching"
	  done
	  fi

           if [ ! -d "build" ]; then
             mkdir build
             cd build

             cmake -DENABLE_HEADLESS=ON \
             -DENABLE_EGL=ON \
             -DENABLE_EVDEV=ON \
             -DLINUX_LOCAL_DEV=ON \
             -DOpenGL_GL_PREFERENCE=GLVND \
             -DENABLE_TESTS=OFF \
             -DENABLE_LLVM=OFF \
             -DENABLE_ANALYTICS=OFF \
             -DENABLE_X11=OFF \
             -DENABLE_LTO=ON \
             -DENABLE_QT=OFF \
             -DENCODE_FRAMEDUMPS=OFF ..

             if [[ $? != "0" ]]; then
		       echo " "
		       echo "There was an error that occured while verifying the necessary dependancies to build the newest dolphin standalone.  Stopping here."
               exit 1
             fi
           fi

           make -j$(nproc)
           if [[ $? != "0" ]]; then
		     echo " "
		     echo "There was an error that occured while making the dolphin standalone.  Stopping here."
             exit 1
           fi
           strip Binaries/dolphin-emu-nogui

           if [ ! -d "../../dolphinsa$bitness/" ]; then
		     mkdir -v ../../dolphinsa$bitness
	       fi

	       cp Binaries/dolphin-emu-nogui ../../dolphinsa$bitness/dolphin-emu-nogui

	       echo " "
	       echo "The dolphin standalone executable has been created and has been placed in the rk3566_core_builds/dolphinsa$bitness subfolder"

	fi
