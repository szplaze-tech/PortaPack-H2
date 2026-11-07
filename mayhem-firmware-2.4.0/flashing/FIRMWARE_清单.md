# PortaPack 固件清单（陈工 / 2026-10-27）

## 一、卖家原版固件（来源：C:\Users\CnGdS\Desktop\hackrf_软件\刷机\）

所谓 "PortaPack H2 固件" 就是这批 Havoc 私改版。公司原型机上跑的是 `mod.bin`。

| 文件 | 大小(B) | MD5(前12) | 版本号 | 日期 | 卖家截图匹配 |
|---|---|---|---|---|---|
| mod2.bin | 803064 | b82a228c240d | local-be45cf6 | 2020-03-09 | 完全匹配（最新） |
| mod.bin | 805784 | ba9f460c922a | local-de927bd | 2020-03-04 | 完全匹配（原型机同款） |
| portapack-h1-havoc.bin | 770944 | 06abc8325822 | local-127a798 | 2020-03-04 | 完全匹配 |
| spk.bin | 758648 | 38f036dfe790 | 无版本串 | 2019-05 | 旧命名，不匹配 |

卖家截图特征串：Play dead / Calls / AIS Boats / Radiosnde / TPMS Cars / ADS-B [S]

## 二、网上下载的社区版本（flashing\alt_firmware\）

| 文件 | 大小(B) | MD5(前12) | 版本号 | 说明 |
|---|---|---|---|---|
| portapack-h1_h2-havoc.bin | 841644 | 9483adf71e02 | local-9e5eebae | 官方 Havoc master 2020-04-20，UI 相近但非卖家同款 |
| havoc_20180612.bin | 916580 | b7910fb88100 | 无版本串 | 2018-06-12 旧版 Havoc，菜单旧命名 |
| portapack-h1_h2-mayhem.bin | 839744 | de7c56dd1f0b | local-f1ca56b | Mayhem v1.0.0（2020-05-12），无 Play dead |

## 三、Mayhem 2.4.0 官方（flashing\firmware\）

| 文件 | 大小(B) | 说明 |
|---|---|---|
| firmware_hackrf.bin | 1048576 | H1/H2/H4M 通用，运行时检测板型 |
| firmware_portarf.bin | 2097152 | PortaRF 专用 |
| firmware_hpro.bin | 4194304 | PRALINE/HPro，含 FPGA bitstream@0x380000 |
| hackrf_usb.dfu | 49096 | DFU 救砖用（HackRF 主控固件） |
| hackrf_hpro_usb.dfu | — | HPro 专用 DFU |

## 四、常用命令（工作目录：flashing）

```bat
:: 查设备
utils\hackrf_info.exe

:: 读整片 Flash（提取固件用，不改设备）
utils\hackrf_spiflash.exe -r 备份.bin

:: 写固件并校验
utils\hackrf_spiflash.exe -R -w seller_firmware\mod2.bin

:: DFU 救砖（设备按住左上第一个键上电 → 出现 LPC 设备）
utils\dfu-util-static.exe -d 1fc9:000c -D firmware\hackrf_usb.dfu
```

## 五、注意事项（血泪教训）

1. **`hackrf_spiflash -w` 是先整片擦除再写入**。中途 USB 断线 = 原固件永久丢失。
   提取固件只能用 `-r`，绝不能用 `-w`。
2. 原型机（SN ...6f8057）USB 链路不稳，大块传输必报 `Pipe error -1000`。
   已确认 `hackrf_info` 可通、`spiflash -r` 一读就断 → 需换数据线 + 直插主机后置口。
3. 设备进 **HackRF 模式**（主菜单 → HackRF）电脑才认得出；DFU 模式只写不读（需 `-a 0` 才能读，且读出的是空片）。
4. 刷完不显示画面：**按住 5 键里任意一个再上电**，切换 LCD 驱动（H2 常见需按住左键）。

## 六、待办

- [ ] 换线换口后读原型机 Flash，与 mod.bin 做二进制 diff，确认是否有私有改动
- [ ] 明天刷到另一台机子做对比
- [ ] SD 卡内容包（COPY_TO_SDCARD）尚未安装，需要读卡器
