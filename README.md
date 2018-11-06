OpenWrt LuCI for v2ray-core
===

简介
---

本软件包是 [v2ray-core][v2ray-core] 的 LuCI 控制界面,
方便用户控制和使用透明代理功能.  

依赖
---

软件包的正常使用需要依赖 `iptables` 和 `coreutils-nohup`.

编译
---

从 OpenWrt 的 [SDK][openwrt-sdk] 编译  
```bash
# 解压下载好的 SDK
tar xjf OpenWrt-SDK-ar71xx-for-linux-x86_64-gcc-4.8-linaro_uClibc-0.9.33.2.tar.bz2
cd OpenWrt-SDK-ar71xx-*
# Clone 项目
git clone https://github.com/aiyahacke/luci-app-v2ray.git package/luci-app-v2ray
# 编译 po2lmo (如果有po2lmo可跳过)
pushd package/luci-app-v2ray/tools/po2lmo
make && sudo make install
popd
# 选择要编译的包 LuCI -> 3. Applications
make menuconfig
# 开始编译
make package/luci-app-v2ray/compile V=99
```

说明
---
1. 第一次编写openwrt插件，不是很熟练，可能会有一些问题
2. v2ray可执行文件需要放入```/usr/bin/v2ray```目录中

软件截图
---
![demo](https://github.com/aiyahacke/luci-app-v2ray/raw/master/screencapture1.png)
![demo](https://github.com/aiyahacke/luci-app-v2ray/raw/master/screencapture2.png)

 [v2ray-core]: https://github.com/v2ray/v2ray-core
 [openwrt-sdk]: https://openwrt.org/docs/guide-developer/obtain.firmware.sdk