# Clean build directories
echo "Cleaning build directories ..."
make -C stack/build/linux clean
make -C drivers/linux/drv_daemon_pcap/build clean
make -C apps/demo_mn_console/build/linux clean
make -C apps/demo_cn_console/build/linux clean

rm -rf stack/build/linux/*
rm -rf stack/lib/*
rm -rf drivers/linux/drv_daemon_pcap/build/*
rm -rf apps/demo_mn_console/build/linux/*
rm -rf apps/demo_cn_console/build/linux/*

rm -rf bin/*
echo "Done."


