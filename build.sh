#!/bin/bash

kernel_dir="${PWD}"
CCACHE=$(command -v ccache)
HOME=/home/rasenkai
objdir="${kernel_dir}/out"
anykernel=$HOME/kernel/asus/anykernel
builddir="${kernel_dir}/build"
ZIMAGE=$kernel_dir/out/arch/arm64/boot/Image.gz-dtb
kernel_name="Requiem-Nightly"
zip_name="$kernel_name-$(date +"%d%m%Y").zip"
GCC_DIR=$HOME/kernel/toolchain/gcc9
export CONFIG_FILE="X00T_defconfig"
export ARCH="arm64"
export KBUILD_BUILD_HOST="TheWorld"
export KBUILD_BUILD_USER="BuriBuriZaemon"

# Colors
NC='\033[0m'
RED='\033[0;31m'
LRD='\033[1;31m'
LGR='\033[1;32m'

make_defconfig()
{
	# Needed to make sure we get dtb built and added to kernel image properly
     START=$(date +"%s")
	echo -e ${LGR} "############### Cleaning ################${NC}"
    rm -rf ${objdir}/arch/arm64/boot/dts/essential/
    rm $anykernel/Image.gz-dtb
    rm -rf $ZIMAGE

	echo -e ${LGR} "########### Generating Defconfig ############${NC}"
    make -s ARCH=${ARCH} O=${objdir} ${CONFIG_FILE} -j$(nproc --all)
}
compile()
{
	cd ${kernel_dir}
	echo -e ${LGR} "######### Compiling kernel #########${NC}"
	make -j$(nproc --all) O=out \
                      ARCH=${ARCH}\
                          CROSS_COMPILE="$HOME/kernel/toolchain/gcc11-arm64/aarch64-linux-elf/bin/aarch64-linux-elf-" \
					      CROSS_COMPILE_ARM32="$HOME/kernel/toolchain/arm32-gcc/bin/arm-eabi-"

}

completion() 
{
	cd ${objdir}
	COMPILED_IMAGE=arch/arm64/boot/Image.gz-dtb
	if [[ -f ${COMPILED_IMAGE} ]]; then
		mv -f $ZIMAGE $anykernel
        cd $anykernel
        find . -name "*.zip" -type f
        find . -name "*.zip" -type f -delete
        zip -r AnyKernel.zip *
        mv AnyKernel.zip $zip_name
        mv $anykernel/$zip_name $HOME/Desktop/$zip_name
        END=$(date +"%s")
        DIFF=$(($END - $START))
		echo -e ${LGR} "############################################"
		echo -e ${LGR} "############# OkThisIsEpic!  ##############"
		echo -e ${LGR} "############################################${NC}"
	else
		echo -e ${RED} "############################################"
		echo -e ${RED} "##         This Is Not Epic :'(           ##"
		echo -e ${RED} "############################################${NC}"
	fi
}
make_defconfig
compile 
completion
cd ${kernel_dir}
