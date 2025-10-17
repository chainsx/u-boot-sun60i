# Allwinner Tina SDK `buildserver` wrapper

For Allwinner A523 chip family, a new program called `update_chip` must be run to
patch the generated `boot0_sdcard_sun55iw3p1.bin` to be bootable.

However, this program will use UNIX socket to communicate with a `buildserver`
process, otherwise it will refuse to run.

This `buildserver` will also need the path of Allwinner Tina SDK to read some
files, otherwise it will refuse to run.

This program also has some basic anti-debugger protection.

---

We created `awbs` to handle this **A**ll**w**inner **b**uild**s**erver. This wrapper can create a minimal folder structure to let `buildserver` run. Only `update_chip` was tested with the generated folder structure.

## Example usage

```Makefile
spl-pub/nboot/boot0_sdcard_sun55iw3p1.bin: device/configs/cubie_a5e/sys_config.bin
	$(MAKE) -j$(shell nproc) CROSS_COMPILE=$(CROSS_COMPILE) $(CUSTOM_MAKE_DEFINITIONS) -C spl-pub b=a527
	$(MAKE) -j$(shell nproc) CROSS_COMPILE=$(CROSS_COMPILE) $(CUSTOM_MAKE_DEFINITIONS) -C spl-pub
	tools/pack/pctools/linux/mod_update/update_boot0 $@ $< SDMMC_CARD
	ln -sf device/bin/bl31.bin monitor.fex
	export LICHEE_OUT_DIR=$$(LICHEE_CHIP_CONFIG_DIR=device LICHEE_TOOLS_DIR=tools awbs/awbs)/out && \
	tools/pack/pctools/linux/mod_update/update_chip $@
```
