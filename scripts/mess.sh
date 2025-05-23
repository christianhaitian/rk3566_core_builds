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

	# Libretro mess build
	if [[ "$var" == "mess" || "$var" == "all" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ ! -d "mess/" ]; then
		git clone https://github.com/libretro/mame.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the libretro git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		 fi
		cp patches/mess-patch* mess/.
	  fi

	 cd mame/
	 
	 mess_patches=$(find *.patch)
	 
	 if [[ ! -z "$mess_patches" ]]; then
	  for patching in mess-patch*
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

      update-alternatives --set gcc "/usr/local/bin/aarch64-linux-gnu-gcc-13"
      update-alternatives --set g++ "/usr/local/bin/aarch64-linux-gnu-g++-13"
      export CPLUS_INCLUDE_PATH=/usr/include/c++/13:/usr/include/c++/13/backward:/usr/local/include/c++/13/aarch64-linux-gnu

	  make clean
	  make -f Makefile.libretro SUBTARGET=mess -j2

	  if [[ $? != "0" ]]; then
		update-alternatives --set gcc "/usr/bin/gcc-8"
		update-alternatives --set g++ "/usr/bin/g++-8"
		unset CPLUS_INCLUDE_PATH
		echo " "
		echo "There was an error while building the newest lr-mess core.  Stopping here."
		exit 1
	  fi

	  update-alternatives --set gcc "/usr/bin/gcc-8"
	  update-alternatives --set g++ "/usr/bin/g++-8"
	  unset CPLUS_INCLUDE_PATH

	  strip mamemess_libretro.so

	  if [ ! -d "../cores$(getconf LONG_BIT)/" ]; then
		mkdir -v ../cores$(getconf LONG_BIT)
	  fi

	  cp mamemess_libretro.so ../cores$(getconf LONG_BIT)/mess_libretro.so

	  gitcommit=$(git log | grep -m 1 commit | cut -c -14 | cut -c 8-)
	  echo $gitcommit > ../cores$(getconf LONG_BIT)/mess_libretro.so.commit

	  echo " "
	  echo "mess_libretro.so has been created and has been placed in the rk3566_core_builds/cores$(getconf LONG_BIT) subfolder"
	fi
