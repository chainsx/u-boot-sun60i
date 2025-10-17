CROSS_COMPILE := arm-linux-gnueabi-
CUSTOM_MAKE_DEFINITIONS := DTS_PATH=arch/arm/dts \
	LICHEE_CHIP_CONFIG_DIR=/tmp \
	LICHEE_PLAT_OUT=/tmp \
	TARGETDIR=/tmp \
	EXTRA_CFLAGS="-Wno-attributes \
				  -Wno-array-bounds \
				  -Wno-address-of-packed-member \
				  -Wno-maybe-uninitialized \
				  -Wno-enum-int-mismatch \
				  -Wno-misleading-indentation"
CUSTOM_DEBUILD_ENV := DEB_BUILD_OPTIONS='parallel=1' DEB_CFLAGS_MAINT_SET= DEB_LDFLAGS_MAINT_SET= DEB_OBJCFLAGS_MAINT_SET=

UBOOT_PRODUCTS := 		  radxa-cubie-a7a \
				  radxa-cubie-a7z

#
# Common supporting targets
#

.PHONY: make_tmp_dir
make_tmp_dir:
	mkdir -p /tmp/bin

pre_build: make_tmp_dir

clean: clean_sunxi_challenge clean_pack clean_spl clean_out

.PHONY: clean_sunxi_challenge
clean_sunxi_challenge:
	rm -f src/board/sunxi/sunxi_challenge.c

.PHONY: clean_pack
clean_pack:
	rm -f src/bl31-*.bin src/scp-*.bin src/boot_package-*.cfg src/boot_package-*.fex

.PHONY: clean_spl
clean_spl:
	rm -f device-*/configs/*/sys_config.bin \
		  monitor.fex
	for i in device-*/configs/*/sys_config.fex; do \
		dos2unix -n $$i $$i; \
	done


.PHONY: clean_out
clean_out:
	rm -rf src/sys_partition_nor.bin out/

#
# BOOT0 Config
#

%/sys_config.bin: %/sys_config.fex
	unix2dos -n $< $<
	tools/pack/pctools/linux/mod_update/script $<

%/sys_partition_nor.bin: %/sys_partition_nor.fex
	unix2dos -n $< $<
	tools/pack/pctools/linux/mod_update/script $<

#
# Closed source BOOT0
#

out/radxa-cubie-a7a/boot0_sdcard.bin: device-a733/configs/cubie_a7a/sys_config.bin
	mkdir -p $(shell dirname $@)
	cp device-a733/bin/boot0_sdcard_sun60iw2p1.bin $@
	tools/pack/pctools/linux/mod_update/update_boot0 $@ $< SDMMC_CARD
	ln -sf device-a733/bin/bl31.bin monitor.fex	# needed for update_chip
	LICHEE_OUT_DIR=$$(LICHEE_CHIP_CONFIG_DIR=device-a733 LICHEE_TOOLS_DIR=tools LICHEE_CHIP=sun60iw2p1 LICHEE_IC=a733 awbs/awbs)/out \
	tools/pack/pctools/linux/mod_update/update_chip $@

out/radxa-cubie-a7a/boot0_ufs.bin: device-a733/configs/cubie_a7a/sys_config.bin
	mkdir -p $(shell dirname $@)
	cp device-a733/bin/boot0_ufs_sun60iw2p1.bin $@
	tools/pack/pctools/linux/mod_update/update_boot0 $@ $< UFS
	ln -sf device-a733/bin/bl31.bin monitor.fex	# needed for update_chip
	LICHEE_OUT_DIR=$$(LICHEE_CHIP_CONFIG_DIR=device-a733 LICHEE_TOOLS_DIR=tools LICHEE_CHIP=sun60iw2p1 LICHEE_IC=a733 awbs/awbs)/out \
	tools/pack/pctools/linux/mod_update/update_chip $@

out/radxa-cubie-a7a/boot0_spinor.bin: device-a733/configs/cubie_a7a/sys_config.bin
	mkdir -p $(shell dirname $@)
	cp device-a733/bin/boot0_spinor_sun60iw2p1.bin $@
	tools/pack/pctools/linux/mod_update/update_boot0 $@ $< SPINOR_FLASH
	ln -sf device-a733/bin/bl31.bin monitor.fex	# needed for update_chip
	LICHEE_OUT_DIR=$$(LICHEE_CHIP_CONFIG_DIR=device-a733 LICHEE_TOOLS_DIR=tools LICHEE_CHIP=sun60iw2p1 LICHEE_IC=a733 awbs/awbs)/out \
	tools/pack/pctools/linux/mod_update/update_chip $@

out/radxa-cubie-a7z/boot0_sdcard.bin: device-a733/configs/cubie_a7z/sys_config.bin
	mkdir -p $(shell dirname $@)
	cp device-a733/bin/boot0_sdcard_sun60iw2p1.bin $@
	tools/pack/pctools/linux/mod_update/update_boot0 $@ $< SDMMC_CARD
	ln -sf device-a733/bin/bl31.bin monitor.fex	# needed for update_chip
	LICHEE_OUT_DIR=$$(LICHEE_CHIP_CONFIG_DIR=device-a733 LICHEE_TOOLS_DIR=tools LICHEE_CHIP=sun60iw2p1 LICHEE_IC=a733 awbs/awbs)/out \
	tools/pack/pctools/linux/mod_update/update_chip $@

out/radxa-cubie-a7z/boot0_ufs.bin: device-a733/configs/cubie_a7z/sys_config.bin
	mkdir -p $(shell dirname $@)
	cp device-a733/bin/boot0_ufs_sun60iw2p1.bin $@
	tools/pack/pctools/linux/mod_update/update_boot0 $@ $< UFS
	ln -sf device-a733/bin/bl31.bin monitor.fex	# needed for update_chip
	LICHEE_OUT_DIR=$$(LICHEE_CHIP_CONFIG_DIR=device-a733 LICHEE_TOOLS_DIR=tools LICHEE_CHIP=sun60iw2p1 LICHEE_IC=a733 awbs/awbs)/out \
	tools/pack/pctools/linux/mod_update/update_chip $@

out/radxa-cubie-a7z/boot0_spinor.bin: device-a733/configs/cubie_a7z/sys_config.bin
	mkdir -p $(shell dirname $@)
	cp device-a733/bin/boot0_spinor_sun60iw2p1.bin $@
	tools/pack/pctools/linux/mod_update/update_boot0 $@ $< SPINOR_FLASH
	ln -sf device-a733/bin/bl31.bin monitor.fex	# needed for update_chip
	LICHEE_OUT_DIR=$$(LICHEE_CHIP_CONFIG_DIR=device-a733 LICHEE_TOOLS_DIR=tools LICHEE_CHIP=sun60iw2p1 LICHEE_IC=a733 awbs/awbs)/out \
	tools/pack/pctools/linux/mod_update/update_chip $@

#
# SCP
#

%/scp.bin: 
	cp $(shell dirname $@)/../../bin/scp.bin $@

#
# U-Boot Proper
#

src/bl31-%.bin: device-%/bin/bl31.bin
	cp $< $@

.SECONDEXPANSION:
src/scp-%.bin: device-$$(word 1,$$(subst -, ,$$*))/configs/$$(word 2,$$(subst -, ,$$*))/scp.bin
	cp $< $@

src/boot_package-%.fex: src/boot_package-%.cfg
	cd ./src && ../tools/pack/pctools/linux/openssl/dragonsecboot -pack $(shell basename $<)
	mv src/boot_package.fex $@

src/boot_package-radxa-cubie-a7a.cfg: src/bl31-a733.bin \
									  src/u-boot-sun60iw2p1.bin \
									  src/scp-a733-cubie_a7a.bin
	echo "[package]" > $@
	echo "item=u-boot, u-boot-sun60iw2p1.bin" >> $@
	echo "item=monitor, bl31-a733.bin" >> $@
	echo "item=scp, scp-a733-cubie_a7a.bin" >> $@

src/boot_package-radxa-cubie-a7z.cfg: src/bl31-a733.bin \
									  src/u-boot-sun60iw2p1.bin \
									  src/scp-a733-cubie_a7z.bin
	echo "[package]" > $@
	echo "item=u-boot, u-boot-sun60iw2p1.bin" >> $@
	echo "item=monitor, bl31-a733.bin" >> $@
	echo "item=scp, scp-a733-cubie_a7z.bin" >> $@

#
# Misc
#

# Placeholder to suppress boot warnings
# Does not work with `env save`
src/sys_partition_nor.bin:
	truncate -s 16M /tmp/gpt.img
	sgdisk -o -n 1:-128K:0 -c 1:env /tmp/gpt.img
	dd conv=notrunc,fsync if=/tmp/gpt.img of=$@ bs=512 count=34

#
# Device build targets
#

.PHONY: radxa-cubie-a7a_defconfig
radxa-cubie-a7a_defconfig: clean_config
	$(UMAKE) $@

.PHONY: radxa-cubie-a7a_build
radxa-cubie-a7a_build: radxa-cubie-a7a_defconfig clean_sunxi_challenge
	$(UMAKE) LICHEE_BOARD_CONFIG_DIR=$(CURDIR)/device-a733/configs/cubie_a7a all

.PHONY: radxa-cubie-a7a_pack
radxa-cubie-a7a_pack: radxa-cubie-a7a_build src/boot_package-radxa-cubie-a7a.fex

.PHONY: radxa-cubie-a7a
radxa-cubie-a7a: radxa-cubie-a7a_pack \
				 out/radxa-cubie-a7a/boot0_sdcard.bin \
				 out/radxa-cubie-a7a/boot0_ufs.bin \
				 out/radxa-cubie-a7a/boot0_spinor.bin \
				 src/sys_partition_nor.bin
	mkdir -p out/$@
	cp src/sys_partition_nor.bin out/$@
	cp src/boot_package-radxa-cubie-a7a.fex out/$@/boot_package.fex
	cp setup/u-boot_setup-allwinner-a733.sh out/$@/setup.sh
	cp setup/u-boot_setup-allwinner-a733.ps1 out/$@/setup.ps1

.PHONY: radxa-cubie-a7z_defconfig
radxa-cubie-a7z_defconfig: clean_config
	$(UMAKE) $@

.PHONY: radxa-cubie-a7z_build
radxa-cubie-a7z_build: radxa-cubie-a7z_defconfig clean_sunxi_challenge
	$(UMAKE) LICHEE_BOARD_CONFIG_DIR=$(CURDIR)/device-a733/configs/cubie_a7z all

.PHONY: radxa-cubie-a7z_pack
radxa-cubie-a7z_pack: radxa-cubie-a7z_build src/boot_package-radxa-cubie-a7z.fex

.PHONY: radxa-cubie-a7z
radxa-cubie-a7z: radxa-cubie-a7z_pack \
				 out/radxa-cubie-a7z/boot0_sdcard.bin \
				 out/radxa-cubie-a7z/boot0_ufs.bin \
				 out/radxa-cubie-a7z/boot0_spinor.bin \
				 src/sys_partition_nor.bin
	mkdir -p out/$@
	cp src/sys_partition_nor.bin out/$@
	cp src/boot_package-radxa-cubie-a7z.fex out/$@/boot_package.fex
	cp setup/u-boot_setup-allwinner-a733.sh out/$@/setup.sh
	cp setup/u-boot_setup-allwinner-a733.ps1 out/$@/setup.ps1

UBOOT_FORK ?= boot-aw2501
ARCH ?= arm
CROSS_COMPILE ?= aarch64-linux-gnu-
CUSTOM_ENV_DEFINITIONS ?=
CUSTOM_MAKE_DEFINITIONS ?=
SUPPORT_CLEAN ?= true

UMAKE ?= $(CUSTOM_ENV_DEFINITIONS) $(MAKE) -C "$(SRC-UBOOT)" -j$(shell nproc) \
			$(CUSTOM_MAKE_DEFINITIONS) \
			ARCH=$(ARCH) CROSS_COMPILE=$(CROSS_COMPILE) \
			UBOOTVERSION=$(shell dpkg-parsechangelog -S Version)-$(UBOOT_FORK)

UBOOT_PRODUCTS ?=

#
# Build
#
DIR-OUTPUT := out
SRC-UBOOT := src

$(DIR-OUTPUT):
	mkdir -p $@

.PHONY: build
build: $(DIR-OUTPUT) $(SRC-UBOOT) pre_build $(UBOOT_PRODUCTS) post_build

#
# Clean
#
.PHONY: clean_config
clean_config:
	rm -f $(SRC-UBOOT)/.config

.PHONY: distclean
distclean: clean
	if [ "$(SUPPORT_CLEAN)" = "true" ]; then $(UMAKE) distclean; fi

.PHONY: clean
clean: clean-deb
	if [ "$(SUPPORT_CLEAN)" = "true" ]; then $(UMAKE) clean; fi

.PHONE: clean-build
clean-build:
	rm -rf debian/u-boot-*/

.PHONY: clean-deb
clean-deb: clean-build

PROJECT ?= u-boot-aw2501
CUSTOM_DEBUILD_ENV ?= DEB_BUILD_OPTIONS='parallel=1'

.DEFAULT_GOAL := all
.PHONY: all
all: build

#
# Test
#
.PHONY: test
test:

#
# Build
#
.PHONY: build
build: pre_build main_build post_build

.PHONY: pre_build
pre_build:
	# Fix file permissions when created from template
	chmod +x debian/rules

.PHONY: main_build
main_build:

.PHONY: post_build
post_build:

#
# Documentation
#
.PHONY: serve
serve:
	mdbook serve

.PHONY: serve_zh-CN
serve_zh-CN:
	MDBOOK_BOOK__LANGUAGE=zh-CN mdbook serve -d book/zh-CN

PO_LOCALE := zh-CN
.PHONY: translate
translate:
	MDBOOK_OUTPUT='{"xgettext": {"pot-file": "messages.pot"}}' mdbook build -d po
	cd po; \
	for i in $(PO_LOCALE); \
	do \
		if [ ! -f $$i.po ]; \
		then \
			msginit -l $$i --no-translator; \
		else \
			msgmerge --update $$i.po messages.pot; \
		fi \
	done

#
# Clean
#
.PHONY: distclean
distclean: clean

.PHONY: clean
clean: clean-deb

.PHONY: clean-deb
clean-deb:
	rm -rf debian/.debhelper debian/$(PROJECT)*/ debian/tmp/ debian/debhelper-build-stamp debian/files debian/*.debhelper.log debian/*.*.debhelper debian/*.substvars

#
# Release
#
.PHONY: dch
dch: debian/changelog
	gbp dch --ignore-branch --multimaint-merge --release --spawn-editor=never \
	--git-log='--no-merges --perl-regexp --invert-grep --grep=^(chore:\stemplates\sgenerated)' \
	--dch-opt=--upstream --commit --commit-msg="feat: release %(version)s"

.PHONY: deb
deb: debian
	$(CUSTOM_DEBUILD_ENV) debuild --no-lintian --lintian-hook "lintian --fail-on error,warning --suppress-tags-from-file $(PWD)/debian/common-lintian-overrides -- %p_%v_*.changes" --no-sign -b
