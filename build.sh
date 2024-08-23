#!/bin/bash

# Check if build type and node type is provided
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <build_type> <node_type> <optional make arguments>"
  echo "    build_type: [Debug, Release]"
  echo "    node_type:  [MN, CN]"
  echo "    optional:   e.g. -j4" 
  exit 1
fi

# Check that build type matches one of the allowed values
if [ "$1" != "Debug" ] && [ "$1" != "Release" ]; then
  echo "Invalid build type. Allowed values: Debug, Release"
  exit 1
fi

# Check that node type matches one of the allowed values
if [ "$2" != "MN" ] && [ "$2" != "CN" ]; then
  echo "Invalid node type. Allowed values: MN, CN"
  exit 1
fi

# Check if dependencies are installed
check_installed() {
    dpkg -s "$1" &> /dev/null

    if [ $? -eq 0 ]; then
        echo "$1 is installed."
    else
        echo "$1 is not installed. Please install it using the following command:"
        echo "sudo apt-get install $1"
    fi
}

# openPOWERLINK depends on libpcap-dev and libsystemd-dev
echo "Checking dependencies ..."
check_installed "libpcap-dev"
check_installed "libsystemd-dev"
echo " "

BUILD_TYPE=$1
NODE_TYPE=$2   

# Set cmake config based on node type
if [ "$NODE_TYPE" == "MN" ]; then
  echo "Building for MN"
  NODE_TYPE_CMAKE_PARAM="CFG_OPLK_MN=ON"
  DEMO_APP_BASE_PATH="apps/demo_mn_console"
elif [ "$NODE_TYPE" == "CN" ]; then
  echo "Building for CN"
  NODE_TYPE_CMAKE_PARAM="CFG_OPLK_MN=OFF"
  DEMO_APP_BASE_PATH="apps/demo_cn_console"
fi

# Build stack
echo "Building stack with build type: $BUILD_TYPE"
cmake -Sstack  -Bstack/build/linux -DCMAKE_BUILD_TYPE=$BUILD_TYPE
cmake --build stack/build/linux -- $3
cmake --install stack/build/linux 

# Build driver
echo "Building PCAP driver with build type: $BUILD_TYPE"
cmake -Sdrivers/linux/drv_daemon_pcap -Bdrivers/linux/drv_daemon_pcap/build -DCMAKE_BUILD_TYPE=$BUILD_TYPE -D$NODE_TYPE_CMAKE_PARAM
cmake --build drivers/linux/drv_daemon_pcap/build -- $3
cmake --install drivers/linux/drv_daemon_pcap/build

# Build apps
echo "Building apps with build type: $BUILD_TYPE"
cmake -S$DEMO_APP_BASE_PATH -B$DEMO_APP_BASE_PATH/build/linux -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DCFG_BUILD_KERNEL_STACK="Linux Userspace Daemon"
cmake --build $DEMO_APP_BASE_PATH/build/linux -- $3
cmake --install $DEMO_APP_BASE_PATH/build/linux

echo "Build completed successfully."