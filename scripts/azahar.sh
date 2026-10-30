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
# Azahar 2126.2 with GammaOS's azahar-nano changes (patches/azahar-patch-000,
# from GammaOSNextDistribution-14 8d68e5ecaab, made on 2126.1.2 and rebased
# onto 2126.2's run loop), and ours on top (001 layout, 002-005 to build and run them here, 006-008
# what azahar-nano has on GammaOS from its Android build and its frontend,
# and the layout's buffer at the panel's size). 009 is GammaOS's three
# azahar-nano commits of 2026-10-20 after 8d68e5ecaab (frame pacing, right-eye
# skip), 010 upstream's SIMD texture codec (9ee6bc70f); the profile was made
# before them and still fits (same fps). 011 moves the screen swap from L3, the
# switch under the RG52 Mini's left stick, to the Back key. 012 streams the save
# states RetroArch makes through zstd and makes one per frame (a save 1.4 s
# instead of about 27). 013 turns GammaOS's stereo switches on for Castlevania:
# Lords of Shadow - Mirror of Fate and leaves out texture copies out of the right
# eye's target, never drawn with them (its intro: 9 fps before, 20 after). 014
# makes the two switches core options, at Auto on for the titles that need them.
# 015 is GammaOS's e842af2339c: an offscreen draw is never left out while its
# pipeline compiles (a texture composed once stayed wrong with a cold cache).
# 016 makes realtime audio a core option (on by default); 017 gives RetroArch's cheat
# menu the cheats of a folder shared with GammaOS (ROMs/cheats/3ds/azahar) and its
# database. 018 starts GammaOS's GPU timer (timestamps around every pass) only when
# asked for, not in every game (Castlevania 50.1 -> 48.7 ms a frame on libmali).
# 019 is GammaOS's 1feeb9c2d16: a framebuffer the cache drops is destroyed once
# the GPU is done with it, not while a queued render pass still uses it
# (Monster Hunter 3 Ultimate crashed in the driver). 020 is GammaOS's e62a0042457: the
# right eye disabler tells the eyes apart by framebuffer, so Castlevania's intro and
# cutscenes no longer flicker; with stereo_skip on, the right transfer goes on to the
# rasterizer, which learns the right eye's target from it. 021-026 are upstream master's
# after 2126.2: the vertex shader JIT's masked writes (847d329ee), zero-area render passes
# skipped (d260a99e2, 4034f6c16), null descriptors for null surfaces (7e77ca648), shadows in
# the SPIR-V fragment shader generator (56d991979; it changes the shader cache's key, so
# every game compiles its shaders once more) and nearest-neighbour scaling blits (d433dfded).
TAG="2126.2"
NANO="8d68e5ecaab"
# Profile for clang's profile-guided optimisation: Super Mario 3D Land played
# on an RG52 Mini with an instrumented build of this recipe (2026-10-20),
# merged with GammaOS's own for azahar-nano (21714041b96, 2026-10-13: Kirby,
# Senran Kagura, Metroid, Pokemon Sun, Mario Kart 7 and Super Mario 3D Land
# save states), ours weighted 2 so both carry about the same total count.
# Theirs alone fits this build badly: made on Android (libc++, the NDK's
# clang 18), 44% of its counts are on functions whose code differs here, and
# clang drops those. Ours names file-local functions by the path of their
# source, so its paths are those of this tree in the image build's chroot,
# /home/ark/rk3562_core_builds/azahar (they carry 6% of the merged counts;
# with the training tree's paths a chroot build lost them). A new profile
# changes this line, so the recipe's cache key changes with it.
PGO="pgo/azahar-nano-merged-20261020.profdata.gz"
PGO_SHA256="6709d16b1345ec79ce3a91b842b6cf435093f530c93fd592a755cd5a61888df0"

	# Libretro Azahar (Nintendo 3DS) build
	if [[ "$var" == "azahar" ]] && [[ "$bitness" == "64" ]]; then
	 cd $cur_wd
	  if [ "$(sha256sum ${PGO} | cut -c1-64)" != "${PGO_SHA256}" ]; then
		echo " "
		echo "The azahar PGO profile ${PGO} is missing or not the one this recipe names.  Stopping here."
		exit 1
	  fi
	  # clang reads the profile (llvm-profdata 19 made it; Debian trixie's clang is 19)
	  if ! dpkg -s clang &>/dev/null; then
		apt-get -y update && apt-get -y install clang
		if [[ $? != "0" ]]; then
		  echo " "
		  echo "Could not install clang.  Stopping here."
		  exit 1
		fi
	  fi
	  rm -rf azahar/
	  git clone --recursive --depth=1 --shallow-submodules -b ${TAG} https://github.com/azahar-emu/azahar.git azahar
	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while cloning the azahar git.  Is Internet active or did the git location change?  Stopping here."
		exit 1
	  fi
	  cp patches/azahar-patch* azahar/.
	  gunzip -c ${PGO} > azahar/azahar.profdata

	  cd azahar
	  for patching in azahar-patch*
	  do
		   patch -Np1 < "$patching"
		   if [[ $? != "0" ]]; then
			echo " "
			echo "There was an error while applying $patching.  Stopping here."
			exit 1
		   fi
		   rm "$patching"
	  done

	  mkdir build
	  cd build
	  # OpenGL is off by default on aarch64 Linux. RetroArch here runs the gl
	  # driver on GLES (KMS), so build it, and have the core ask for a GLES 3
	  # context: USING_GLES, which upstream sets only for Android. Vulkan too,
	  # for the vulkan driver, which is the one RetroArch uses for this core.
	  # clang with the profile. On the RG52 Mini (Super Mario 3D Land, 1-1,
	  # CPU capped at 816 MHz) azahar-nano ran at 24.7 fps without one, 24.8
	  # with GammaOS's alone and at 30 with this one; with the CPU at 1008 MHz
	  # 2126.2 ran at 24 fps, this core at 30. 30 was the GPU's limit then, half
	  # the game's speed; patches 006-008 brought it to the full 60. Upstream's LTO
	  # is off: it added nothing on top of a profile here and would need lld.
	  # CLANG_CC/CLANG_CXX: dArkOS's image build hands in the amd64 build of
	  # this clang, mounted into its arm64 chroot, which runs without qemu
	  # (its xtool.sh); the same compiler, so the same core.
	  pgo_flags="-fprofile-use=$cur_wd/azahar/azahar.profdata -Wno-profile-instr-unprofiled -Wno-profile-instr-out-of-date -Wno-backend-plugin"
	  cmake .. -G Ninja \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_C_COMPILER=${CLANG_CC:-/usr/bin/clang} \
		-DCMAKE_CXX_COMPILER=${CLANG_CXX:-/usr/bin/clang++} \
		-DENABLE_LIBRETRO=ON \
		-DENABLE_OPENGL=ON \
		-DENABLE_VULKAN=ON \
		-DENABLE_TESTS=OFF \
		-DENABLE_LTO=OFF \
		-DCITRA_WARNINGS_AS_ERRORS=OFF \
		-DCMAKE_C_FLAGS="${pgo_flags}" \
		-DCMAKE_CXX_FLAGS="-DUSING_GLES ${pgo_flags}"
	  ninja -j$(nproc) citra_libretro

	  if [[ $? != "0" ]]; then
		echo " "
		echo "There was an error while building the azahar libretro core.  Stopping here."
		exit 1
	  fi

	  strip bin/Release/azahar_libretro.so

	  if [ ! -d "../../cores64/" ]; then
		mkdir -v ../../cores64
	  fi

	  cp bin/Release/azahar_libretro.so ../../cores64/.

	  echo ${TAG}+azahar-nano-${NANO} > ../../cores64/azahar_libretro.so.commit

	  echo " "
	  echo "azahar_libretro.so has been created and has been placed in the rk3566_core_builds/cores64 subfolder"
	fi
