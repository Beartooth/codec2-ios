#!/usr/bin/env bash
# Copyright © 2017 Jefferson Jones. All rights reserved.

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License version 2.1, as
# published by the Free Software Foundation.  This program is
# distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
# License for more details.

# You should have received a copy of the GNU Lesser General Public License
# along with this program; if not, see <http://www.gnu.org/licenses/>.

#
# build_codec2.sh
#
# This script automates the cross-compilation of Codec 2 for iOS. You must run this script before attempting to compile the framework.
#
# The compiled .dylibs will be copied to $(SRCROOT)/codec2-ios/lib


GREEN='\033[0;32m'
RED='\033[0;31m'
ORANGE='\033[0;33m'
NC='\033[0m'
SPIN='-\|/'

function echogreen() {
	echo -e "${GREEN}$1${NC}"
}

function echored() {
	echo -e "${RED}$1${NC}"
}

function echoorange() {
	echo -e "${ORANGE}$1${NC}"
}

function echoorangen() {
	echo -ne "${ORANGE}$1${NC}"
}

function verifyclang() {
	echoorange "Checking Clang installation"
	if hash clang 2>/dev/null; then
		clang --version
	else
		while true; do
		read -p "Clang is NOT installed. Install it now? [Y/N]" yn
		case $yn in
	[Yy]* ) brew install clang; break;;
	[Nn]* ) exit;;
	* ) echo -e "Please answer yes or no.";;
		esac
		done
	fi
}

function verifycmake() {
	echoorange "Checking CMake installation"
	if hash cmake 2>/dev/null; then
		cmake /V
	else
		while true; do
		read -p "CMake is NOT installed. Install it now? [Y/N]" yn
		case $yn in
	[Yy]* ) brew install cmake; break;;
	[Nn]* ) exit;;
	* ) echo -e -e "${RED}Please answer yes or no.${NC}";;
		esac
		done
	fi
}

# if [ -z "$IOS_SDK" ]; then
# 	echored "IOS_SDK needs to be set."
# 	exit 1
# fi

export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

printenv > BUILD_ENV.txt 

PROJECT_DIR=`pwd`
CMAKE_IOS_TOOLCHAIN=$PROJECT_DIR/toolchain/iOS.cmake
CODEC_2_PATH=$PROJECT_DIR/codec2
CODEC_2_NATIVE_BUILD=$PROJECT_DIR/codec2_native_build
CODEC_2_IOS_BUILD=$PROJECT_DIR/codec2_ios_build
CODEC_2_SIMULATOR_BUILD=$PROJECT_DIR/codec2_simulator_build
CODEC_2_OUTPUT=$PROJECT_DIR/lib
CODEC_2_GENERATED=$PROJECT_DIR/generated
echoorange "Codec 2 path: ${CODEC_2_PATH}"

# Update codec2 submodule if necessary'
echoorange "Initializing submodules..."
git submodule init
echoorange "Updating submodules..."
git submodule update --init --recursive
cd $CODEC_2_PATH && git checkout cross-compile-support

# Check toolchains
verifyclang
verifycmake

# Use Clang
# export CC=/usr/bin/clang
# export CXX=/usr/bin/clang++


################################################
# Build native codebook generators for codec 2 #
################################################

# Build codebook targets
mkdir -p $CODEC_2_NATIVE_BUILD && cd $CODEC_2_NATIVE_BUILD
echoorange "Build directory: ${CODEC_2_NATIVE_BUILD}"
echoorangen "Generating build system..."
cmake ../codec2 > cmake_native.log 2>&1
echoorange "done"
echoorangen "Building code generators..."
make generate_codebook genlspdtcb > make_native.log 2>&1
echoorange "done"

# Check for codebook generator binaries module
echoorangen "Verifying codebook generator module..."
if [ ! -f "ImportExecutables.cmake" ]; then
	echored "CMake module for codebook generators was not found, check CMakeOutput.log for more info."
	exit 1
fi
echoorange "done"

echoorangen "Generating codebooks..."
GENERATE_CODEBOOK=$CODEC_2_NATIVE_BUILD/src/generate_codebook
GENLSPDTCB=$CODEC_2_NATIVE_BUILD/src/genlspdtcb
mkdir -p $CODEC_2_GENERATED && cd $CODEC_2_GENERATED
cp -rf $CODEC_2_PATH/src/codebook ./
D=codebook
rm -f $D/*.c
$GENERATE_CODEBOOK lsp_cb $D/lsp1.txt $D/lsp2.txt $D/lsp3.txt $D/lsp4.txt $D/lsp5.txt $D/lsp6.txt $D/lsp6.txt $D/lsp7.txt $D/lsp8.txt $D/lsp9.txt $D/lsp10.txt > codebook.c 
$GENERATE_CODEBOOK lsp_cbd $D/dlsp1.txt $D/dlsp2.txt $D/dlsp3.txt $D/dlsp4.txt $D/dlsp5.txt $D/dlsp6.txt $D/dlsp7.txt $D/dlsp8.txt $D/dlsp9.txt $D/dlsp10.txt > codebookd.c
$GENERATE_CODEBOOK lsp_cbjvm $D/lspjvm1.txt $D/lspjvm2.txt $D/lspjvm3.txt > codebookjvm.c
$GENERATE_CODEBOOK mel_cb $D/mel1.txt $D/mel2.txt $D/mel3.txt $D/mel4.txt $D/mel5.txt $D/mel6.txt > codebookmel.c
$GENERATE_CODEBOOK lspmelvq_cb $D/lspmelvq1.txt $D/lspmelvq2.txt $D/lspmelvq3.txt > codebooklspmelvq.c
$GENERATE_CODEBOOK ge_cb $D/gecb.txt > codebookge.c
echoorange "done"
########################
# Build codec2 for iOS #
########################

# # xcodebuild outputs
# IOS_OS_BIN_OUTPUT=$CODEC_2_IOS_BUILD/src/Release-iphoneos 				# device
# IOS_SIM_BIN_OUTPUT=$CODEC_2_SIMULATOR_BUILD/src/Release-iphonesimulator # simulator
# # Arch libarary paths
# IOS_OS_DYLIBS=$CODEC_2_OUTPUT/os
# IOS_SIM_DYLIBS_i386=$CODEC_2_OUTPUT/simulator/i386
# IOS_SIM_DYLIBS_x86_64=$CODEC_2_OUTPUT/simulator/x86_64
# # Dylib names
# IOS_DYLIB_NAME_NO_V=libcodec2.dylib
# IOS_DYLIB_NAME=libcodec2.0.4.dylib

# # Build for device
# mkdir -p $CODEC_2_IOS_BUILD && cd $CODEC_2_IOS_BUILD
# echoorange "iOS: Build directory: ${CODEC_2_IOS_BUILD}"
# echoorangen "iOS: Generating build system..."
# cmake -DCMAKE_TOOLCHAIN_FILE=$CMAKE_IOS_TOOLCHAIN -DIOS_PLATFORM=OS -DCMAKE_MODULE_PATH=$CODEC_2_NATIVE_BUILD -GXcode ../codec2 > cmake_os.log 2>&1
# echoorange "done"
# echoorangen "iOS: Building..."
# xcodebuild -quiet -target codec2 install -configuration Release build BITCODE_GENERATION_MODE=bitcode > os_build.log 2>&1
# echoorange "done"
# mkdir -p $IOS_OS_DYLIBS
# mv $IOS_OS_BIN_OUTPUT/$IOS_DYLIB_NAME_NO_V $IOS_OS_DYLIBS
# mv $IOS_OS_BIN_OUTPUT/$IOS_DYLIB_NAME $IOS_OS_DYLIBS
# echoorange "iOS: Finished"

# # Build codec2 for iOS simulator
# mkdir -p $CODEC_2_SIMULATOR_BUILD && cd $CODEC_2_SIMULATOR_BUILD
# echoorange "iOS simulator: Build directory: ${CODEC_2_SIMULATOR_BUILD}"
# echoorangen "iOS simulator: Generating build system..."
# cmake -DCMAKE_TOOLCHAIN_FILE=$CMAKE_IOS_TOOLCHAIN -DIOS_PLATFORM=SIMULATOR -DCMAKE_MODULE_PATH=$CODEC_2_NATIVE_BUILD -GXcode ../codec2 > cmake_sim.log 2>&1
# echoorange "done"
# echoorangen "iOS simulator: Building i386..."
# xcodebuild -quiet -target codec2 install -configuration Release build BITCODE_GENERATION_MODE=bitcode ARCHS="i386" > sim_build_i386.log 2>&1
# echoorange "done"
# mkdir -p $IOS_SIM_DYLIBS_i386
# mv $IOS_SIM_BIN_OUTPUT/$IOS_DYLIB_NAME_NO_V $IOS_SIM_DYLIBS_i386
# mv $IOS_SIM_BIN_OUTPUT/$IOS_DYLIB_NAME $IOS_SIM_DYLIBS_i386
# echoorangen "iOS simulator: Building x86_64..."
# xcodebuild -quiet -target codec2 install -configuration Release build BITCODE_GENERATION_MODE=bitcode ARCHS="x86_64" VALID_ARCHS="x86_64" > sim_build_x86_64.log 2>&1
# echoorange "done"
# mkdir -p $IOS_SIM_DYLIBS_x86_64
# mv $IOS_SIM_BIN_OUTPUT/$IOS_DYLIB_NAME_NO_V $IOS_SIM_DYLIBS_x86_64
# mv $IOS_SIM_BIN_OUTPUT/$IOS_DYLIB_NAME $IOS_SIM_DYLIBS_x86_64
# echoorange "iOS simulator: Finished"

# # Combine dylibs
# echoorangen "Combining binaries..."
# lipo -create $IOS_OS_DYLIBS/$IOS_DYLIB_NAME_NO_V $IOS_SIM_DYLIBS_i386/$IOS_DYLIB_NAME_NO_V $IOS_SIM_DYLIBS_x86_64/$IOS_DYLIB_NAME_NO_V -output $CODEC_2_OUTPUT/$IOS_DYLIB_NAME_NO_V
# lipo -create $IOS_OS_DYLIBS/$IOS_DYLIB_NAME $IOS_SIM_DYLIBS_i386/$IOS_DYLIB_NAME $IOS_SIM_DYLIBS_x86_64/$IOS_DYLIB_NAME -output $CODEC_2_OUTPUT/$IOS_DYLIB_NAME
# echoorange "done"

# echoorangen "Changing binary install names..."
# install_name_tool -id @loader_path/Frameworks/$IOS_DYLIB_NAME_NO_V $CODEC_2_OUTPUT/$IOS_DYLIB_NAME_NO_V
# install_name_tool -id @loader_path/Frameworks/$IOS_DYLIB_NAME $CODEC_2_OUTPUT/$IOS_DYLIB_NAME
# echoorange "done"

echogreen "Done! You can build the project from Xcode now."









