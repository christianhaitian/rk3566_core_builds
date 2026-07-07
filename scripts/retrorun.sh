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

	# Retrorun build
	if [[ "$var" == "retrorun" ]]; then
	 cd $cur_wd
	  if [ ! -d "retrorun/" ]; then
		git clone --recursive https://github.com/navy1978/retrorun.git
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "There was an error while cloning the retrorun git.  Is Internet active or did the git location change?  Stopping here."
		  exit 1
		fi
		cp patches/retrorun-patch* retrorun/.
	  fi
	fi

	 cd retrorun/

	 retrorun_patches=$(find *.patch)
	 
	 if [[ ! -z "$retrorun_patches" ]]; then
	  for patching in retrorun-patch*
	  do
	        if [[ $patching == *"miniloong"* ]]; then
	          echo " "
	          echo "Skipping the $patching for now and making a note to apply that later"
	          sleep 3
	          retrorun_miniloongpatch="yes"
	        else
		   patch -Np1 < "$patching"
		   if [[ $? != "0" ]]; then
			echo " "
			echo "There was an error while applying $patching.  Stopping here."
			exit 1
		   fi
		   rm "$patching" 
		fi
	  done
	 fi

	 make config=release -j$(nproc)

	 if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the newest retrorun.  Stopping here."
		exit 1
	 fi

	 strip retrorun

	 if [ ! -d "../retrorun-$bitness/" ]; then
		mkdir -v ../retrorun-$bitness
	 fi

	 cp retrorun ../retrorun-$bitness/retrorun

	 if [[ "$bitness" == "32" ]]; then
		mv ../retrorun-$bitness/retrorun ../retrorun-$bitness/retrorun32
	 fi

	 echo " "
	 if [[ "$bitness" == "32" ]]; then
		echo "retrorun32 has been created and has been placed in the rk3566_core_builds/retrorun-$bitness subfolder"
	 else
		echo "retrorun has been created and has been placed in the rk3566_core_builds/retrorun-$bitness subfolder"
	 fi

          if [[ $retrorun_miniloongpatch == "yes" ]]; then
    	      for patching in retrorun-patch*
      	      do
       	        patch -Np1 < "$patching"
       		    if [[ $? != "0" ]]; then
       		      echo " "
       		      echo "There was an error while applying $patching.  Stopping here."
       		      exit 1
       		    fi
       		    rm "$patching"
       	      done

	      make -j$(nproc)

	      if [[ $? != "0" ]]; then
		    echo " "
		    echo "There was an error while building the newest retrorun with the miniloong  patch.  Stopping here."
		    exit 1
	      fi

	      strip retrorun

             if [ ! -d "../retrorun-$bitness/" ]; then
                    mkdir -v ../retrorun-$bitness
             fi

             cp retrorun ../retrorun-$bitness/retrorun-miniloong

             if [[ "$bitness" == "32" ]]; then
                    mv ../retrorun-$bitness/retrorun ../retrorun-$bitness/retrorun32-miniloong
             fi

             echo " "
             if [[ "$bitness" == "32" ]]; then
                    echo "retrorun32-miniloong has been created and has been placed in the rk3566_core_builds/retrorun-$bitness subfolder"
             else
                    echo "retrorun-miniloong has been created and has been placed in the rk3566_core_builds/retrorun-$bitness subfolder"
             fi
          fi
