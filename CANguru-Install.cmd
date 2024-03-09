@echo off
SET COMPORT=COM3


:loop
cls
echo.
echo CARguru - Helper
echo.
echo USB-Anschluesse:
call files
echo.
echo Bitte waehlen Sie eine der folgenden Optionen:
echo. 
echo  1 - COM-Port festlegen
echo  2 - Flash-Speicher loeschen
echo  3 - Upload CANguru-Bridge (aus Ordner CANguru-Bridge) ueber %COMPORT%
echo  4 - Putty starten
echo. 
echo  x - Beenden
echo.
set /p SELECTED=Ihre Auswahl: 

if "%SELECTED%" == "x" goto :eof
if "%SELECTED%" == "1" goto :SetComPort
if "%SELECTED%" == "2" goto :ERASE_FLASH
if "%SELECTED%" == "3" goto :UPLOAD_BRIDGE
if "%SELECTED%" == "4" goto :Putty

goto :errorInput 


:SetComPort
REM @echo OFF
REM FOR /L %%x IN (1, 1, 29) DO ECHO %%x - Setze COM-Port %%x
echo Bitte geben Sie die Nummer des COM-Anschlusses ein (z.B. 5 fuer COM5) oder x fuer Exit
echo.
set /p SELECTED=Ihre Auswahl: 

if "%SELECTED%" == "x" goto :loop

set COMPORT=COM%SELECTED%
goto :loop

:ERASE_FLASH
@echo on
esptool.exe --chip esp32 --port %COMPORT% erase_flash
@echo off
echo.
pause
goto :loop

:UPLOAD_BRIDGE
@echo on
REM Geht davon aus, dass die aktuelle Bridge-Software im Verzeichnis CANguru-Bridge steht; laedt diese Software auf den Olimex ESP32-EVB hoch
REM
set source=..\0101-CANguru-Bridge-Olimex-Version-3.5\.pio\build\esp32-evb\
set dest=CANguru-Bridge
copy %source%*.bin %dest%
esptool.exe --chip esp32 --port %COMPORT% --baud 460800 --before default_reset --after hard_reset write_flash -z --flash_mode dio --flash_freq 80m --flash_size 4MB 0x1000 %dest%/bootloader.bin 0x8000 %dest%/partitions.bin 0x10000 %dest%/firmware.bin
@echo off
echo.
pause
goto :loop

:Putty
@echo on
Putty\putty.exe -serial %COMPORT% -sercfg 115200,8,n,1,N
@echo off
echo.
pause
goto :loop

:errorInput
echo.
echo Falsche Eingabe! Bitte erneut versuchen!
echo.
pause
goto :loop

