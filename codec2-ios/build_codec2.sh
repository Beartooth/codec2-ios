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
	echo -e "${GREEN} - $1${NC}"
}

function echored() {
	echo -e "${RED} - $1${NC}"
}

function echoorange() {
	echo -e "${ORANGE} - $1${NC}"
}

function echoorangen() {
	echo -ne "${ORANGE} - $1${NC}"
}

function verifyclang() {
	echo -e -e "${ORANGE} - Checking Clang installation...${NC}"
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
	echo -e "${ORANGE} - Checking CMake installation...${NC}"
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

PROJECT_DIR=`pwd`
CMAKE_IOS_TOOLCHAIN=$PROJECT_DIR/toolchain/iOS.cmake
CODEC_2_PATH=$PROJECT_DIR/codec2
CODEC_2_NATIVE_BUILD=$PROJECT_DIR/codec2_native_build
CODEC_2_IOS_BUILD=$PROJECT_DIR/codec2_ios_build
CODEC_2_SIMULATOR_BUILD=$PROJECT_DIR/codec2_simulator_build
CODEC_2_OUTPUT=$PROJECT_DIR/lib
echoorange "Codec 2 path: ${CODEC_2_PATH}"

# Update codec2 submodule if necessary
if [ ! -f "$CODEC_2_PATH/CMakeLists.txt" ]; then
	echoorange "Updating codec submodule..."
	git submodule update --init --recursive
fi

# Check toolchains
verifyclang
verifycmake

# Use Clang
export CC=clang
export CXX=clang++

# Create native build dir if needed
if [ ! -d "${CODEC_2_NATIVE_BUILD}" ]; then
	echoorange "Creating native build directory"
	mkdir $CODEC_2_NATIVE_BUILD
else
	echoorange "Native build directory already present"
fi
echoorange "Native build directory: ${CODEC_2_NATIVE_BUILD}"
cd $CODEC_2_NATIVE_BUILD

# Build codec2 natively
echoorange "Codec 2 (native): Generating build system..."
cmake ../codec2
echoorange "Codec 2 (native): Building code generators..."
make generate_codebook genlspdtcb
echogreen "Codec 2 (native): Finished"


# Check for codebook generator binaries module
echoorange "Verifying codebook generator module..."
if [ ! -f "ImportExecutables.cmake" ]; then
	echored "CMake module for codebook generators was not found, check CMakeOutput.log for more info."
	exit 1
fi
cd $PROJECT_DIR

# Create required dirs for iOS
if [ ! -d "${CODEC_2_IOS_BUILD}" ]; then
	echoorange "Creating iOS build directory"
	mkdir $CODEC_2_IOS_BUILD
fi
if [ ! -d "${CODEC_2_SIMULATOR_BUILD}" ]; then
	echoorange "Creating iOS simulator build directory"
	mkdir $CODEC_2_SIMULATOR_BUILD
fi
if [ ! -d "${CODEC_2_OUTPUT}" ]; then
	echoorange "Creating lib output directory"
	mkdir $CODEC_2_OUTPUT
fi
echoorange "iOS build directory: ${CODEC_2_IOS_BUILD}"
echoorange "iOS simulator build directory: ${CODEC_2_SIMULATOR_BUILD}"
echoorange "Library output: ${CODEC_2_OUTPUT}"

# Build codec2 for iOS
cd $CODEC_2_IOS_BUILD
echoorange "Codec 2 (iOS): Generating build system..."
cmake -DCMAKE_TOOLCHAIN_FILE=$CMAKE_IOS_TOOLCHAIN -DIOS_PLATFORM=OS -DCMAKE_MODULE_PATH=$CODEC_2_NATIVE_BUILD -GXcode ../codec2
echoorange "Codec 2 (iOS): Building..."
xcodebuild -quiet -target codec2 install -configuration Release

# Build codec2 for iOS simulator
cd $CODEC_2_SIMULATOR_BUILD
echoorange "Codec 2 (iOS simulator): Generating build system..."
cmake -DCMAKE_TOOLCHAIN_FILE=$CMAKE_IOS_TOOLCHAIN -DIOS_PLATFORM=SIMULATOR -DCMAKE_MODULE_PATH=$CODEC_2_NATIVE_BUILD -GXcode ../codec2
echoorange "Codec 2 (iOS simulator): Building..."
xcodebuild -quiet -target codec2 install -configuration Release

# combine dylibs, output to lib directory
CODEC_2_IOS_DYLIB_NO_V=$CODEC_2_IOS_BUILD/src/Release-iphoneos/libcodec2.dylib
CODEC_2_IOS_DYLIB=$CODEC_2_IOS_BUILD/src/Release-iphoneos/libcodec2.0.4.dylib
CODEC_2_SIM_DYLIB_NO_V=$CODEC_2_SIMULATOR_BUILD/src/Release-iphonesimulator/libcodec2.dylib
CODEC_2_SIM_DYLIB=$CODEC_2_SIMULATOR_BUILD/src/Release-iphonesimulator/libcodec2.0.4.dylib
lipo -output $PROJECT_DIR/lib/libcodec2.dylib -create $CODEC_2_IOS_DYLIB_NO_V $CODEC_2_SIM_DYLIB_NO_V
lipo -output $PROJECT_DIR/lib/libcodec2.0.4.dylib -create $CODEC_2_IOS_DYLIB $CODEC_2_SIM_DYLIB
echogreen "Codec 2 (iOS): Finished"

# Clean up
echoorange "Removing build directories..."
rm -rf $CODEC_2_NATIVE_BUILD $CODEC_2_IOS_BUILD $CODEC_2_SIMULATOR_BUILD
echogreen "Done! You can build the project from Xcode now."









