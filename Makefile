fix_termux_env:
	@if [ ! -f edk2/.termux_patched ]; then \
		echo "Applying Termux patches only once to preserve timestamps..."; \
		cp -r ./Conf ./edk2/ 2>/dev/null || true; \
		mkdir -p edk2/BaseTools/Tests; \
		printf "all:\n\t@echo 'Skipped Tests'\ntest:\n\t@echo 'Skipped Tests'\nclean:\n\t@echo 'Skipped Tests'\n" > edk2/BaseTools/Tests/GNUmakefile; \
		sed -i 's/\.isSet()/.is_set()/g' edk2/BaseTools/Source/Python/build/build.py || true; \
		sed -i 's/\.getName()/.name/g' edk2/BaseTools/Source/Python/build/build.py || true; \
		sed -i 's/-Werror//g' edk2/Conf/tools_def.txt 2>/dev/null || true; \
		sed -i 's/-Werror//g' edk2/BaseTools/Conf/tools_def.template 2>/dev/null || true; \
		sed -i 's/-fuse-ld=[a-zA-Z0-9_/().]*ld\.lld/-fuse-ld=lld/g' edk2/Conf/tools_def.txt 2>/dev/null || true; \
		sed -i 's/-fuse-ld=[a-zA-Z0-9_/().]*ld\.lld/-fuse-ld=lld/g' edk2/BaseTools/Conf/tools_def.template 2>/dev/null || true; \
		touch edk2/.termux_patched; \
	else \
		echo "Environment already patched, skipping to preserve compilation progress."; \
	fi

clean:
	rm -rf edk2/Build || true
	rm -rf edk2/Conf || true
	rm -rf edk2/.termux_patched || true
	rm -rf edk2/QcomModulePkg/Include/Library/ABL.h || true
	rm -rf tools/patch_abl || true
	rm -rf dist || true
	rm -rf extracted || true
	mkdir -p dist

patch:
	gcc -O2 -o ./tools/extractfv ./tools/extractfv.c -llzma
	./tools/extractfv ./images/abl.img -o ./dist
	rm ./tools/extractfv
	mv ./extracted/LinuxLoader.efi ./dist/ABL_original.efi
	gcc -o tools/patch_abl tools/patch_abl.c
	./tools/patch_abl ./dist/ABL_original.efi ./dist/ABL.efi > ./dist/patch_log.txt
	rm tools/patch_abl
	cat ./dist/patch_log.txt

build: patch fix_termux_env
	xxd -i dist/ABL.efi > edk2/QcomModulePkg/Include/Library/ABL.h
	bash -c 'export PYTHONWARNINGS="ignore" && export MAX_CONCURRENT_THREAD_NUMBER=1 && cd edk2 && . ./edksetup.sh && make BOARD_BOOTLOADER_PRODUCT_NAME=canoe TARGET_ARCHITECTURE=AARCH64 TARGET=RELEASE \
  		CLANG_BIN=/data/data/com.termux/files/usr/bin/ CLANG_PREFIX= VERIFIED_BOOT_ENABLED=1 \
  		VERIFIED_BOOT_LE=0 AB_RETRYCOUNT_DISABLE=0 TARGET_BOARD_TYPE_AUTO=0 \
  		BUILD_USES_RECOVERY_AS_BOOT=0 DISABLE_PARALLEL_DOWNLOAD_FLASH=0 PVMFW_BCC_ENABLED=-DPVMFW_BCC\
  		REMOVE_CARVEOUT_REGION=1 QSPA_BOOTCONFIG_ENABLE=1 USER_BUILD_VARIANT=0 \
  		PREBUILT_HOST_TOOLS="BUILD_CC=clang BUILD_CXX=clang++ LDPATH=-fuse-ld=lld BUILD_AR=llvm-ar"' || true
	if [ ! -f edk2/Build/RELEASE_CLANG35/AARCH64/LinuxLoader.efi ]; then \
		echo "Build failed"; \
		exit 1; \
	fi
	cp edk2/Build/RELEASE_CLANG35/AARCH64/LinuxLoader.efi ./dist/ABL_with_superfastboot.efi
	cat ./dist/patch_log.txt
	ls -l ./dist

dist: build
	mkdir -p release
	zip -r release/$(DIST_NAME).zip dist

build_superfbonly: fix_termux_env
	bash -c 'export PYTHONWARNINGS="ignore" && export MAX_CONCURRENT_THREAD_NUMBER=1 && cd edk2 && . ./edksetup.sh && make BOARD_BOOTLOADER_PRODUCT_NAME=canoe TARGET_ARCHITECTURE=AARCH64 TARGET=RELEASE \
  		CLANG_BIN=/data/data/com.termux/files/usr/bin/ CLANG_PREFIX= VERIFIED_BOOT_ENABLED=1 \
  		VERIFIED_BOOT_LE=0 AB_RETRYCOUNT_DISABLE=0 TARGET_BOARD_TYPE_AUTO=0 \
  		BUILD_USES_RECOVERY_AS_BOOT=0 DISABLE_PARALLEL_DOWNLOAD_FLASH=0 PVMFW_BCC_ENABLED=-DPVMFW_BCC\
  		REMOVE_CARVEOUT_REGION=1 QSPA_BOOTCONFIG_ENABLE=1 USER_BUILD_VARIANT=0 TEST_ADAPTER=1 \
  		PREBUILT_HOST_TOOLS="BUILD_CC=clang BUILD_CXX=clang++ LDPATH=-fuse-ld=lld BUILD_AR=llvm-ar"' || true
	if [ ! -f edk2/Build/RELEASE_CLANG35/AARCH64/LinuxLoader.efi ]; then \
		echo "Build failed"; \
		exit 1; \
	fi
	cp edk2/Build/RELEASE_CLANG35/AARCH64/LinuxLoader.efi ./dist/superfastboot.efi
	ls -l ./dist

build_generic: fix_termux_env
	bash -c 'export PYTHONWARNINGS="ignore" && export MAX_CONCURRENT_THREAD_NUMBER=1 && cd edk2 && . ./edksetup.sh && make BOARD_BOOTLOADER_PRODUCT_NAME=canoe TARGET_ARCHITECTURE=AARCH64 TARGET=RELEASE \
  		CLANG_BIN=/data/data/com.termux/files/usr/bin/ CLANG_PREFIX= VERIFIED_BOOT_ENABLED=1 \
  		VERIFIED_BOOT_LE=0 AB_RETRYCOUNT_DISABLE=0 TARGET_BOARD_TYPE_AUTO=0 \
  		BUILD_USES_RECOVERY_AS_BOOT=0 DISABLE_PARALLEL_DOWNLOAD_FLASH=0 PVMFW_BCC_ENABLED=-DPVMFW_BCC\
  		REMOVE_CARVEOUT_REGION=1 QSPA_BOOTCONFIG_ENABLE=1 USER_BUILD_VARIANT=0 AUTO_PATCH_ABL=1 DISABLE_PRINT=1\
  		PREBUILT_HOST_TOOLS="BUILD_CC=clang BUILD_CXX=clang++ LDPATH=-fuse-ld=lld BUILD_AR=llvm-ar"' || true
	if [ ! -f edk2/Build/RELEASE_CLANG35/AARCH64/LinuxLoader.efi ]; then \
		echo "Build failed"; \
		exit 1; \
	fi
	cp edk2/Build/RELEASE_CLANG35/AARCH64/LinuxLoader.efi ./dist/generic_superfastboot.efi
	ls -l ./dist

build_patcher_android:
	aarch64-linux-android-clang tools/patch_abl.c -o dist/patch_abl_android
	clang -O2 -o dist/extractfv_android ./tools/extractfv.c -llzma

build_module: build_patcher_android
	mv dist/patch_abl_android magisk_module/bin/patch_abl
	mv dist/extractfv_android magisk_module/bin/extractfv
	mkdir -p release || true
	cd magisk_module && zip -r ../release/fake_relock_ota.zip ./
	rm magisk_module/bin/patch_abl
	rm magisk_module/bin/extractfv

test_exploit:
	@echo "This script is used to test the ABL exploit. Please make sure you tested before ota."
	@echo Please enter the Builtin Fastboot in the project. And put abl.img in the images folder. Press Enter to continue.
	@bash -c read -n 1 -s
	@python tools/extractfv.py ./images/abl.img ./ABL_original.efi
	@fastboot boot ./ABL_original.efi
	@echo 'If the exploit existed in the new abl image, the device will show two lines of "Press Volume Down key to enter Fastboot mode, waiting for 5 seconds into Normal mode..."'
	@echo 'If the exploit does not exist in the new abl image, the device will show red state screen'
	@rm ./ABL_original.efi

test_boot: build
	fastboot boot ./dist/ABL_with_superfastboot.efi

test:
	bash ./tests/runall.sh
