@echo off
setlocal EnableDelayedExpansion

echo =========================================================
echo   One-click Havoc firmware flasher (PortaPack H1/H2/H4M)
echo =========================================================
echo.

set FIRMWARE=alt_firmware\portapack-h1_h2-havoc.bin

if not exist "%FIRMWARE%" (
    echo ERROR: firmware file not found: %FIRMWARE%
    pause
    exit /b 1
)

echo Firmware : %FIRMWARE%
echo Target   : HackRF One SPI flash
echo.

REM -- Check device is visible in HackRF mode ----------------
utils\hackrf_info.exe | findstr /C:"Found HackRF" >nul
if errorlevel 1 (
    echo Device not found in HackRF mode.
    echo.
    echo On the PortaPack screen, open the main menu and select
    echo "HackRF" to switch to HackRF mode, then press any key...
    pause >nul

    REM -- Serial fallback: ask device to switch to HackRF mode --
    powershell -NoProfile -Command "[System.IO.Ports.SerialPort]::GetPortNames() | Sort-Object | ForEach-Object { $_ }" > "%TEMP%\havoc_comports.txt" 2>nul
    for /f "usebackq tokens=*" %%P in ("%TEMP%\havoc_comports.txt") do (
        echo Trying serial port %%P to switch to HackRF mode...
        powershell -NoProfile -Command "$p = New-Object System.IO.Ports.SerialPort('%%P', 115200, [System.IO.Ports.Parity]::None, 8, [System.IO.Ports.StopBits]::One); try { $p.Open(); $p.Write('hackrf' + [char]13 + [char]10); Start-Sleep -Milliseconds 500; $p.Close() } catch {}"
        timeout /t 7 /nobreak >nul
    )

    utils\hackrf_info.exe | findstr /C:"Found HackRF" >nul
    if errorlevel 1 (
        echo.
        echo ERROR: still no device. Check USB cable and try again.
        pause
        exit /b 1
    )
)

echo Device found. Flashing...
echo.
utils\hackrf_spiflash.exe -R -w "%FIRMWARE%"
if errorlevel 1 (
    echo.
    echo ERROR: flash failed. Put the device in HackRF mode and retry.
    pause
    exit /b 1
)

echo.
echo =========================================================
echo   Havoc flashed OK. Device is rebooting.
echo   Back to Mayhem 2.4.0 anytime with:
echo     utils\hackrf_spiflash.exe -R -w firmware\firmware_hackrf.bin
echo =========================================================
pause
exit /b 0
