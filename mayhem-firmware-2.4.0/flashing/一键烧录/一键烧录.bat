@echo off
chcp 936 >nul
setlocal enabledelayedexpansion
cd /d "%~dp0"
set "INFO=bin\hackrf_info.exe"
set "SPI=bin\hackrf_spiflash.exe"
set "DFU=bin\dfu-util-static.exe"

:main
cls
echo.
echo  ==========================================================
echo            PortaPack H2 / HackRF 固件一键烧录工具
echo  ==========================================================
echo.
echo    卖家原版（公司机器同款 UI）
echo    [1]  mod2        local-be45cf6    2020-03-09   ^<- 推荐
echo    [2]  mod         local-de927bd    2020-03-04
echo    [3]  havoc       local-127a798    2020-03-04
echo    [4]  spk         2019-05 旧版
echo.
echo    社区 / 官方版本
echo    [5]  Havoc 官方  2020-04-20
echo    [6]  Havoc 旧版  2018-06-12
echo    [7]  Mayhem       v1.0.0
echo    [8]  Mayhem       v2.4.0
echo    [9]  ShareBrained 原版 1.5.1  2019-04-05
echo.
echo    工具
echo    [B]  备份：读取整片 Flash 到文件（不改动设备）
echo    [D]  DFU 救砖：设备黑屏无反应时使用
echo    [Q]  退出
echo.
set "c="
set /p "c=请输入序号后回车: "

if /i "%c%"=="1" (set "FW=firmware\1_mod2_seller.bin" & set "FN=卖家 mod2  local-be45cf6  2020-03-09" & goto doflash)
if /i "%c%"=="2" (set "FW=firmware\2_mod_seller.bin" & set "FN=卖家 mod  local-de927bd  2020-03-04" & goto doflash)
if /i "%c%"=="3" (set "FW=firmware\3_havoc_seller.bin" & set "FN=卖家 havoc  local-127a798  2020-03-04" & goto doflash)
if /i "%c%"=="4" (set "FW=firmware\4_spk_2019.bin" & set "FN=卖家 spk  2019-05 旧版" & goto doflash)
if /i "%c%"=="5" (set "FW=firmware\5_havoc_master_20200420.bin" & set "FN=Havoc 官方  2020-04-20" & goto doflash)
if /i "%c%"=="6" (set "FW=firmware\6_havoc_20180612.bin" & set "FN=Havoc 旧版  2018-06-12" & goto doflash)
if /i "%c%"=="7" (set "FW=firmware\7_mayhem_v1.0.0.bin" & set "FN=Mayhem v1.0.0" & goto doflash)
if /i "%c%"=="8" (set "FW=firmware\8_mayhem_v2.4.0.bin" & set "FN=Mayhem v2.4.0" & goto doflash)
if /i "%c%"=="9" (set "FW=firmware\9_sharebrained_1.5.1_20190405.bin" & set "FN=ShareBrained 原版 1.5.1  2019-04-05" & goto doflash)
if /i "%c%"=="B" goto dobackup
if /i "%c%"=="D" goto dobrick
if /i "%c%"=="Q" goto end
echo.
echo  无效输入，请重新选择。
timeout /t 1 >nul
goto main

:checkdev
"%INFO%" > "%TEMP%\pp_probe.txt" 2>&1
findstr /C:"Found HackRF" "%TEMP%\pp_probe.txt" >nul
if errorlevel 1 (
    echo.
    echo   [错误] 没有检测到 HackRF 设备
    echo.
    echo   请依次确认：
    echo     1. USB 线是数据线（很多线只能充电）
    echo     2. 换主机后置 USB 口，别经过 hub / 扩展坞
    echo     3. 设备已进入 HackRF 模式：主菜单 -^> HackRF
    echo        进入后屏幕变黑或只显示一行字，属正常
    echo.
    type "%TEMP%\pp_probe.txt"
    echo.
    pause
    exit /b 1
)
exit /b 0

:doflash
cls
if not exist "%FW%" (
    echo   [错误] 找不到固件文件：%FW%
    echo.
    pause
    goto main
)
echo.
echo   ================== 准备烧录 ==================
echo.
echo   固件：%FN%
echo   文件：%FW%
echo.
call :checkdev
if errorlevel 1 goto main
type "%TEMP%\pp_probe.txt"
echo.
echo  ----------------------------------------------------------
echo   警告：烧录会"先整片擦除再写入"。
echo         中途断线，原固件将永久丢失，无法找回。
echo         如需保留设备上的原固件，请先返回主菜单按 [B] 备份。
echo  ----------------------------------------------------------
echo.
set "yn="
set /p "yn=确认烧录请输入 Y 后回车（其他键取消）: "
if /i not "%yn%"=="Y" (
    echo.
    echo   已取消。
    timeout /t 1 >nul
    goto main
)
echo.
echo   正在擦除并写入，请勿拔线、勿断电（约 20~60 秒）...
echo.
"%SPI%" -R -w "%FW%"
if errorlevel 1 (
    echo.
    echo   [提示] 返回码非 0。常见原因：写入中途 USB 断开。
    echo         处理办法：
    echo           1. 本工具重新烧一次
    echo           2. 仍不行 -^> 按 [D] 走 DFU 救砖流程
    echo           3. 换一根确定能传数据的 USB 线
) else (
    echo.
    echo   烧录完成。
)
echo.
echo   ================== 烧录后设备信息 ==================
"%INFO%"
echo.
echo   说明：hackrf_info 显示的 Version 是固件内部 HackRF 基座版本号，
echo         不一定等于界面版本（例如 mod2 界面是 be45cf6，
echo         但这里显示 local-de927bd，属正常现象）。
echo.
echo   开机黑屏处理：断电后按住 5 个按键中的任意一个再上电，
echo   用于切换 LCD 驱动型号，逐个按键试即可。
echo.
pause
goto main

:dobackup
cls
echo.
echo   ================== 读取 Flash 备份 ==================
echo.
echo   此操作只读取，不会改动设备上的任何内容。
echo   整片约 1MB，若中途报 Pipe error 属 USB 链路不稳，
echo   可重复执行；小块读取不受影响。
echo.
call :checkdev
if errorlevel 1 goto main
echo.
set "bn="
set /p "bn=备份文件名（直接回车用 backup_flash.bin）: "
if "%bn%"=="" set "bn=backup_flash.bin"
echo.
echo   正在读取到 %bn% ...
"%SPI%" -r "%bn%"
echo.
if exist "%bn%" (
    for %%A in ("%bn%") do echo   完成，文件大小 %%~zA 字节
) else (
    echo   读取失败，未生成文件。
)
echo.
echo   提示：若大小远小于 1000000 字节，说明读取中断，
echo         请换 USB 线/接口后重试。
echo.
pause
goto main

:dobrick
cls
echo.
echo   ==================== DFU 救砖 ====================
echo.
echo   适用情况：设备黑屏、电脑认不出、烧录中途断电。
echo.
echo   操作步骤：
echo     1. 拔掉 USB
echo     2. 按住 HackRF 板上左上角第一个按键不松
echo     3. 插上 USB，保持按住约 3 秒，松开
echo     4. 此时设备会被识别为 "LPC"（VID_1FC9）
echo.
echo   本步骤写入 HackRF 主控固件，之后还需重新烧一次
echo   PortaPack 固件才会有界面。
echo.
echo   可选文件（本项默认用第一个）：
echo     firmware\hackrf_usb_recovery.dfu      Mayhem 2.4.0 配套
echo     firmware\recovery\hackrf_usb_v2.4.0.dfu    同上
echo     firmware\recovery\hackrf_usb_2019.dfu      2019 老版本
echo     firmware\recovery\hackrf_one_2018.dfu      2018 老版本
echo.
"%DFU%" -l > "%TEMP%\pp_dfu.txt" 2>&1
findstr /C:"1fc9:000c" "%TEMP%\pp_dfu.txt" >nul
if errorlevel 1 (
    echo   [错误] 未检测到 DFU 设备（1fc9:000c）
    echo.
    type "%TEMP%\pp_dfu.txt"
    echo.
    echo   请按上面 1~4 步重新进入 DFU 模式后再运行本项。
    echo.
    pause
    goto main
)
echo   已检测到 DFU 设备，开始写入...
echo.
"%DFU%" -d 1fc9:000c -D "firmware\hackrf_usb_recovery.dfu"
echo.
echo   写入结束（出现 unable to read DFU status 属正常，
echo   是 LPC 芯片复位特性，不影响结果）。
echo.
echo   接下来请回到主菜单选一个固件（建议 [1] mod2）继续烧录。
echo.
pause
goto main

:end
cls
echo.
echo   已退出。
echo.
timeout /t 1 >nul
exit /b 0
