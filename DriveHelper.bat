@echo off
setlocal
title Drive Helper Pro

:: ==========================================================
::   Drive Helper Pro  -  portable troubleshooting toolkit
::   Drive info, diagnostics, repair, format, copy, backup.
::   Single file, no install. Windows 8.1 / 10 / 11
::   Also works in Windows Recovery (WinRE) when Windows
::   will not boot - it switches to RECOVERY MODE alone.
:: ==========================================================

:: Recovery mode: running from Windows RE / setup media (SystemDrive = X:)
set "REMODE=0"
if /i "%SystemDrive%"=="X:" set "REMODE=1"
if "%REMODE%"=="1" goto recovery

:: Header info
set "WINOS=?"
for /f "delims=" %%i in ('powershell -NoProfile -Command "$os=Get-CimInstance Win32_OperatingSystem; $os.Caption+' build '+$os.BuildNumber" 2^>nul') do set "WINOS=%%i"
if "%WINOS%"=="?" set "WINOS=Windows"
net session >nul 2>&1
if errorlevel 1 (set "ADMINST=NO") else (set "ADMINST=YES")

:: Offer admin relaunch at start
net session >nul 2>&1
if errorlevel 1 goto offadm
goto skipadm
:offadm
echo.
echo  Note: some tools need Administrator rights.
echo  I can relaunch this program as Administrator now.
call :ASKSET " Relaunch as admin now? type YES or just Enter: "
if /i "%ANS%"=="YES" goto doadm
goto skipadm
:doadm
echo  The UAC prompt will appear - click Yes. This window will close.
powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
exit
:skipadm

:: ==========================================================
:: MAIN MENU
:menu
cls
echo ==============================================================
echo                Drive Helper Pro  -  Toolkit
echo ==============================================================
echo  System: %WINOS%   -   Running as admin: %ADMINST%
echo --------------------------------------------------------------
echo  Columns: Total / Used / Free in GB
echo  Type: Local=disk / USB=flash or external / CD/DVD
echo.
call :LISTDRIVES
echo --------------------------------------------------------------
echo    1   Diagnostics and system info
echo    2   Repair and rescue Windows
echo    3   File and folder tools
echo    4   Drive and disk tools
echo    5   Backup, transfer and restore
echo    6   Windows utilities
echo    7   Install copies on this PC - reachable in WinRE
echo    8   Make a BOOTABLE rescue USB from this PC
echo    0   Exit
echo --------------------------------------------------------------
call :ASKSET " Enter a number and press Enter: "
if "%ANS%"=="1" goto menu1
if "%ANS%"=="2" goto menu2
if "%ANS%"=="3" goto menu3
if "%ANS%"=="4" goto menu4
if "%ANS%"=="5" goto menu5
if "%ANS%"=="6" goto menu6
if "%ANS%"=="7" call :DEPLOY
if "%ANS%"=="8" call :MKRESCUEUSB
if "%ANS%"=="0" goto bye
if "%ANS%"=="" goto menu
echo  Invalid choice!
timeout /t 2 >nul
goto menu

:bye
echo.
echo  Goodbye - good luck out there!
timeout /t 2 >nul
exit /b 0

:: ==========================================================
:: MENU 1 - Diagnostics and system info
:menu1
cls
echo ============ Diagnostics and system info ============
call :LISTDRIVES
echo ------------------------------------------------
echo    1  Disk health - SMART status
echo    2  Disks and partitions map
echo    3  BitLocker status of drives
echo    4  Check drive for errors - chkdsk + fix
echo    5  General system information
echo    6  Startup programs - run at boot
echo    7  Top memory-consuming processes
echo    8  Problem devices - broken drivers
echo    9  Laptop battery health report
echo   10  Largest files on a drive
echo   11  Folder sizes on a drive
echo    0  Back
echo ------------------------------------------------
call :ASKSET " Choice: "
if "%ANS%"=="1" call :SMART
if "%ANS%"=="2" call :PARTS
if "%ANS%"=="3" call :BITLOCKER
if "%ANS%"=="4" call :CHKDSK
if "%ANS%"=="5" call :SYSINFO
if "%ANS%"=="6" call :STARTUPS
if "%ANS%"=="7" call :TOPPROC
if "%ANS%"=="8" call :BADDEVS
if "%ANS%"=="9" call :BATTERY
if "%ANS%"=="10" call :BIGFILES
if "%ANS%"=="11" call :FOLDERSIZE
if "%ANS%"=="0" goto menu
goto menu1

:: ==========================================================
:: MENU 2 - Repair and rescue
:menu2
cls
echo ============ Repair and rescue Windows ============
echo ------------------------------------------------
echo    1  Repair system files - SFC
echo    2  Repair Windows image - DISM
echo    3  Create a system restore point
echo    4  Open System Restore / protection settings
echo    5  Network reset - internet and WiFi problems
echo    6  Unhide flash drive files - shortcut virus
echo    7  Sync clock with internet time server
echo    8  Hibernate on/off - free up space on C:
echo    9  Restart into Safe Mode and back
echo    0  Back
echo ------------------------------------------------
call :ASKSET " Choice: "
if "%ANS%"=="1" call :SFC
if "%ANS%"=="2" call :DISMR
if "%ANS%"=="3" call :RESTOREPT
if "%ANS%"=="4" call :SYSRESTORE
if "%ANS%"=="5" call :NETRESET
if "%ANS%"=="6" call :UNHIDE
if "%ANS%"=="7" call :TIMESYNC
if "%ANS%"=="8" call :HIBERNATE
if "%ANS%"=="9" call :SAFEMODE
if "%ANS%"=="0" goto menu
goto menu2

:: ==========================================================
:: MENU 3 - File and folder tools
:menu3
cls
echo ============ File and folder tools ============
echo ------------------------------------------------
echo    1  Copy a file or folder to another drive
echo    2  Delete a file or folder - with confirm
echo    3  Zip a folder or whole drive
echo    4  File hash - SHA256 / SHA1 / MD5
echo    5  Take ownership of a locked file
echo    0  Back
echo ------------------------------------------------
call :ASKSET " Choice: "
if "%ANS%"=="1" call :COPYITEM
if "%ANS%"=="2" call :DELETEITEM
if "%ANS%"=="3" call :ZIPITEM
if "%ANS%"=="4" call :HASHFILE
if "%ANS%"=="5" call :TAKEOWN
if "%ANS%"=="0" goto menu
goto menu3

:: ==========================================================
:: MENU 4 - Drive and disk tools
:menu4
cls
echo ============ Drive and disk tools ============
call :LISTDRIVES
echo ------------------------------------------------
echo    1  Format a drive - double confirmation
echo    2  Optimize - TRIM for SSD, defrag for HDD
echo    3  Clean temp files and recycle bin
echo    4  Windows Disk Cleanup
echo    5  Open Disk Management
echo    0  Back
echo ------------------------------------------------
call :ASKSET " Choice: "
if "%ANS%"=="1" call :FORMAT
if "%ANS%"=="2" call :OPTIMIZE
if "%ANS%"=="3" call :CLEAN
if "%ANS%"=="4" call :CLEANMGR
if "%ANS%"=="5" call :DISKMGT
if "%ANS%"=="0" goto menu
goto menu4

:: ==========================================================
:: MENU 5 - Backup, transfer and restore
:menu5
cls
echo ============ Backup, transfer and restore ============
call :LISTDRIVES
echo ------------------------------------------------
echo    1  Back up user folders
echo    2  Restore user backup
echo    3  Full system backup - Windows image
echo    4  Export WiFi profiles with passwords
echo    5  Import WiFi profiles from backup
echo    6  Show saved WiFi passwords
echo    7  Installed programs list - save to file
echo    8  Backup drivers + full list
echo    0  Back
echo ------------------------------------------------
call :ASKSET " Choice: "
if "%ANS%"=="1" call :USERBACKUP
if "%ANS%"=="2" call :USERRESTORE
if "%ANS%"=="3" call :IMAGE
if "%ANS%"=="4" call :WIFIEXPORT
if "%ANS%"=="5" call :WIFIIMPORT
if "%ANS%"=="6" call :WIFISHOW
if "%ANS%"=="7" call :PROGRAMS
if "%ANS%"=="8" call :DRIVERS
if "%ANS%"=="0" goto menu
goto menu5

:: ==========================================================
:: MENU 6 - Windows utilities
:menu6
cls
echo ============ Windows utilities ============
echo ------------------------------------------------
echo    1  Windows Defender quick scan
echo    2  Windows Defender full scan
echo    3  Show hidden files and extensions
echo    4  Create God Mode folder - all settings
echo    5  Scheduled shutdown / restart / cancel
echo    6  Open Task Manager
echo    7  Open Command Prompt - admin console
echo    8  Rescue guide - when Windows will not boot
echo    0  Back
echo ------------------------------------------------
call :ASKSET " Choice: "
if "%ANS%"=="1" call :QUICKSCAN
if "%ANS%"=="2" call :FULLSCAN
if "%ANS%"=="3" call :SHOWHIDDEN
if "%ANS%"=="4" call :GODMODE
if "%ANS%"=="5" call :SHUTDOWN
if "%ANS%"=="6" call :TASKMGR
if "%ANS%"=="7" call :ADMINCMD
if "%ANS%"=="8" call :REGUIDE
if "%ANS%"=="0" goto menu
goto menu6

:: ==========================================================
:: SHARED HELPERS
:: ==========================================================

:: Generic prompt - result stored in ANS
:ASKSET
set "ANS="
set /p "ANS=%~1"
exit /b 0

:: Build a command-line-safe argument from a path
:: drive roots -> X:\ unquoted, everything else -> "quoted"
:: avoids the classic "a:\" escaped-quote argument bug
:MAKEARG
set "RARG=%~1"
if "%RARG:~-1%"=="\" set "RARG=%RARG:~0,-1%"
if not "%RARG:~1%"==":" goto mkarg_q
set "RARG=%RARG%\"
goto mkarg_done
:mkarg_q
set RARG="%RARG%"
:mkarg_done
exit /b 0

:: List all drives with total / used / free
:LISTDRIVES
powershell -NoProfile -Command "Get-CimInstance Win32_LogicalDisk | Sort-Object DeviceID | Format-Table -AutoSize DeviceID, VolumeName, FileSystem, @{n='Type';e={ if($_.DriveType -eq 2){'USB'}elseif($_.DriveType -eq 4){'Network'}elseif($_.DriveType -eq 5){'CD/DVD'}else{'Local'} }}, @{n='TotalGB';e={ if($_.Size){'{0:N1}' -f ($_.Size/1GB)}else{'-'} }}, @{n='UsedGB';e={ if($_.Size -and $_.FreeSpace -ne $null){'{0:N1}' -f (($_.Size-$_.FreeSpace)/1GB)}else{'-'} }}, @{n='FreeGB';e={ if($_.FreeSpace -ne $null){'{0:N1}' -f ($_.FreeSpace/1GB)}else{'-'} }} | Out-String -Width 220"
exit /b 0

:: Ask for drive letter + validate
:ASKDRIVE
call :ASKSET " Type a drive letter, e.g. E : "
set "DRV=%ANS:~0,1%"
if "%DRV%"=="" goto askdrv_bad
if not exist %DRV%:\ goto askdrv_bad
if /i "%DRV%"=="%SystemDrive:~0,1%" goto askdrv_sys
exit /b 0
:askdrv_bad
echo  Drive not found! - pick a valid letter from the list above.
pause
exit /b 1
:askdrv_sys
echo  That is the Windows drive - not allowed for this operation!
pause
exit /b 1

:: Check admin - relaunch elevated if missing
:NEEDADMIN
if "%REMODE%"=="1" exit /b 0
net session >nul 2>&1
if not errorlevel 1 exit /b 0
echo.
echo  *** This operation needs Administrator rights ***
echo  A new window will open with admin rights;
echo  click Yes on the UAC prompt, then pick the same
echo  option again in the new window.
echo.
pause
powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
exit

:: ==========================================================
:: MENU 1 TOOLS
:: ==========================================================

:: Disk health
:SMART
echo.
echo  Disk health - the Status column should say OK:
echo.
powershell -NoProfile -Command "Get-CimInstance Win32_DiskDrive | Sort-Object Name | Format-Table -AutoSize Model, Status, InterfaceType, @{n='SizeGB';e={'{0:N0}' -f ($_.Size/1GB)}} | Out-String -Width 220"
echo  Anything other than OK means the disk is at risk - back up now!
pause
exit /b 0

:: Disks and partitions
:PARTS
echo.
echo  Physical disks and partitions:
echo.
powershell -NoProfile -Command "Get-Disk | Format-Table -AutoSize Number, FriendlyName, PartitionStyle, HealthStatus, @{n='TotalGB';e={'{0:N0}' -f ($_.Size/1GB)}} | Out-String -Width 200; Get-Partition -ErrorAction SilentlyContinue | Where-Object DriveLetter | Format-Table -AutoSize DriveLetter, DiskNumber, @{n='SizeGB';e={'{0:N1}' -f ($_.Size/1GB)}}, Type | Out-String -Width 200"
echo  GPT = modern standard - MBR = legacy
pause
exit /b 0

:: BitLocker status
:BITLOCKER
call :NEEDADMIN
where manage-bde >nul 2>&1
if errorlevel 1 goto bl_no
call :ASKDRIVE
if errorlevel 1 goto :eof
manage-bde -status %DRV%:
echo.
echo  Protection must be On for the drive to be encrypted.
pause
exit /b 0
:bl_no
echo  BitLocker tooling is not available on this Windows.
pause
exit /b 0

:: Check drive errors + optional fix
:CHKDSK
call :NEEDADMIN
if errorlevel 1 goto :eof
call :ASKDRIVE
if errorlevel 1 goto :eof
echo.
echo  Starting read-only check - nothing will be changed,
echo  but it may take a few minutes...
echo.
chkdsk %DRV%:
echo.
call :ASKSET " To fix found errors type FIX, or just Enter: "
if /i not "%ANS%"=="FIX" goto :eof
echo  Repairing errors... if the drive is in use,
echo  it will continue at next restart.
chkdsk %DRV%: /f
echo.
echo  Done.
pause
exit /b 0

:: System info
:SYSINFO
echo.
echo  Gathering information...
echo.
powershell -NoProfile -Command "$os=Get-CimInstance Win32_OperatingSystem; $cs=Get-CimInstance Win32_ComputerSystem; $cpu=Get-CimInstance Win32_Processor | Select-Object -First 1; $up=(Get-Date)-$os.LastBootUpTime; Write-Output ('Windows    : '+$os.Caption+' build '+$os.BuildNumber+' '+$os.OSArchitecture); Write-Output ('Computer   : '+$cs.Manufacturer+' '+$cs.Model); Write-Output ('CPU        : '+$cpu.Name); Write-Output ('RAM        : '+[math]::Round($cs.TotalPhysicalMemory/1GB,1)+' GB total / '+[math]::Round($os.FreePhysicalMemory/1MB,1)+' GB free'); Write-Output ('Installed  : '+$os.InstallDate); Write-Output ('Last boot  : '+$os.LastBootUpTime); Write-Output ('Uptime     : '+$up.Days+' days '+$up.Hours+' hours '+$up.Minutes+' minutes')"
echo.
echo  A very long uptime? A restart will do your system good!
pause
exit /b 0

:: Startup programs
:STARTUPS
echo.
echo  Programs that run when Windows starts:
echo.
powershell -NoProfile -Command "Get-CimInstance Win32_StartupCommand | Format-List Name, Command, Location | Out-String -Width 200"
echo  Tip: to disable one - Task Manager then Startup apps
pause
exit /b 0

:: Top memory processes
:TOPPROC
echo.
echo  Top 20 processes by memory usage:
echo.
powershell -NoProfile -Command "Get-Process | Sort-Object PM -Descending | Select-Object -First 20 @{n='RAM_MB';e={[int]($_.PM/1MB)}}, ProcessName, Id | Format-Table -AutoSize | Out-String -Width 120"
pause
exit /b 0

:: Problem devices
:BADDEVS
echo.
echo  Devices with driver problems:
echo.
powershell -NoProfile -Command "$d=Get-PnpDevice | Where-Object { $_.Present -and $_.Status -ne 'OK' }; if($d){ $d | Format-Table -AutoSize FriendlyName, Class, Status | Out-String -Width 200 } else { Write-Output 'All devices are healthy!' }"
echo  For missing drivers: Device Manager, right-click, Update driver
pause
exit /b 0

:: Battery report
:BATTERY
powercfg /batteryreport /output "%TEMP%\battery-report.html" >nul 2>&1
if exist "%TEMP%\battery-report.html" goto bat_ok
echo  Report not created - this is not a laptop or has no battery.
pause
goto :eof
:bat_ok
start "" "%TEMP%\battery-report.html"
echo.
echo  The report opened in your browser.
echo  In the last tables compare Design Capacity vs Full Charge
echo  Capacity - that shows battery wear. EQUAL = healthy
pause
exit /b 0

:: Largest files
:BIGFILES
call :ASKDRIVE
if errorlevel 1 goto :eof
echo.
echo  Scanning all of %DRV%: - this can take a few minutes
echo  depending on drive size. Showing the 30 largest files.
echo.
powershell -NoProfile -Command "Get-ChildItem -LiteralPath '%DRV%:\' -Recurse -File -ErrorAction SilentlyContinue | Sort-Object Length -Descending | Select-Object -First 30 @{n='SizeMB';e={'{0:N1}' -f ($_.Length/1MB)}}, FullName | Format-Table -AutoSize | Out-String -Width 260"
echo  Found something you do not need? Delete it via menu 3 option 2!
pause
exit /b 0

:: Folder sizes
:FOLDERSIZE
call :ASKDRIVE
if errorlevel 1 goto :eof
echo.
echo  Sizes of top-level folders on %DRV%: - may take a few minutes...
echo.
powershell -NoProfile -Command "Get-ChildItem -LiteralPath '%DRV%:\' -Directory -ErrorAction SilentlyContinue | ForEach-Object { $s=(Get-ChildItem -LiteralPath $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum; [PSCustomObject]@{ SizeGB=[math]::Round(($s/1GB),2); Folder=$_.Name } } | Sort-Object SizeGB -Descending | Format-Table -AutoSize | Out-String -Width 120"
echo  Now you know where all the space went!
pause
exit /b 0

:: ==========================================================
:: MENU 2 TOOLS
:: ==========================================================

:: System file check
:SFC
call :NEEDADMIN
echo.
echo  Repairs corrupted Windows files - takes 5 to 20 minutes.
call :ASKSET " Start? type YES : "
if /i not "%ANS%"=="YES" goto :eof
echo.
sfc /scannow
echo.
echo  Finished - if it said "found corrupt files and repaired them"
echo  then repairs were applied.
pause
exit /b 0

:: DISM repair
:DISMR
call :NEEDADMIN
echo.
echo  Repairs the Windows component store - 10 to 30 minutes,
echo  needs internet.
call :ASKSET " Start? type YES : "
if /i not "%ANS%"=="YES" goto :eof
echo.
DISM /Online /Cleanup-Image /RestoreHealth
echo.
echo  Done! If SFC was failing before, run it again now.
pause
exit /b 0

:: Restore point
:RESTOREPT
call :NEEDADMIN
echo.
echo  Creating a restore point...
powershell -NoProfile -Command "try { Checkpoint-Computer -Description 'DriveHelper' -RestorePointType MODIFY_SETTINGS -ErrorAction Stop; Write-Output 'DONE - restore point created' } catch { Write-Output ('ERROR: ' + $_.Exception.Message) }"
echo.
echo  If you got an ERROR, System Protection is off;
echo  use menu 2 option 4 to enable it first.
pause
exit /b 0

:: Open system restore UI
:SYSRESTORE
call :ASKSET " 1=open System Restore / 2=open protection settings : "
if "%ANS%"=="1" start "" rstrui.exe
if "%ANS%"=="2" start "" SystemPropertiesProtection.exe
echo  Window opened - click Yes if UAC asks.
exit /b 0

:: Network reset
:NETRESET
call :NEEDADMIN
echo.
echo  This fixes internet and WiFi problems:
echo  DNS cache is flushed and network settings reset
echo  to defaults. A restart is needed afterwards.
call :ASKSET " Start? type YES : "
if /i not "%ANS%"=="YES" goto :eof
echo.
ipconfig /flushdns
netsh winsock reset
netsh int ip reset
echo.
echo  Done! Restart the computer to finish.
pause
exit /b 0

:: Unhide flash files
:UNHIDE
call :ASKDRIVE
if errorlevel 1 goto :eof
echo.
echo  Removing hidden attributes... on a big flash drive
echo  this can take a minute or two. Wait for the done message.
echo.
attrib -s -h -r %DRV%:\*.* /s /d
echo.
echo  Done! You should now see your files in Explorer.
echo  Tip: delete the weird shortcut files the virus made.
pause
exit /b 0

:: Time sync
:TIMESYNC
call :NEEDADMIN
net start w32time >nul 2>&1
w32tm /resync /force
echo.
echo  If it says "successfully" above, the clock is fixed.
echo  Otherwise check your internet and try again.
pause
exit /b 0

:: Hibernate toggle
:HIBERNATE
call :NEEDADMIN
echo.
echo  Turning hibernate off deletes hiberfil.sys - about 40
echo  percent of your RAM size - from drive C:. Fast Startup
echo  is disabled too. Turning it on reverses everything.
call :ASKSET " 1=turn OFF / 2=turn ON - enter number: "
if "%ANS%"=="1" powercfg /h off
if "%ANS%"=="2" powercfg /h on
echo  Done.
pause
exit /b 0

:: Safe mode toggle
:SAFEMODE
call :NEEDADMIN
bcdedit /enum {current} 2>nul | findstr /i "safeboot" >nul 2>&1
if errorlevel 1 goto sm_off
echo  Current state: Safe Mode is ON.
call :ASKSET " Go back to normal mode? type YES : "
if /i not "%ANS%"=="YES" goto :eof
bcdedit /deletevalue {current} safeboot
echo  Removed! Restart and Windows will boot normally.
pause
exit /b 0
:sm_off
echo  Current state: normal mode.
echo  If you enable it, the system boots into Safe Mode after
echo  restart. Useful against stubborn viruses. When done,
echo  run this option again to switch back to normal.
call :ASKSET " Enable Safe Mode? type YES : "
if /i not "%ANS%"=="YES" goto :eof
bcdedit /set {current} safeboot minimal
echo.
echo  Enabled! Safe Mode will load after restart.
echo  Remember to switch back with this same option!
pause
exit /b 0

:: ==========================================================
:: MENU 3 TOOLS
:: ==========================================================

:: Copy file or folder
:COPYITEM
call :ASKSET " Source path - file or folder: "
if "%ANS%"=="" goto :eof
set "SRC=%ANS:"=%"
if exist "%SRC%" goto cpy_found
echo  Source path not found!
pause
goto :eof
:cpy_found
call :ASKSET " Destination path, e.g. F:\MyCopy : "
if "%ANS%"=="" goto :eof
set "DST=%ANS:"=%"
rem normalize - strip trailing backslash, keep drive roots as X:\
if "%SRC:~-1%"=="\" set "SRC=%SRC:~0,-1%"
if "%SRC:~1%"==":" set "SRC=%SRC%\"
if "%SRC:~1%"==":" goto cpy_dir
if "%DST:~-1%"=="\" set "DST=%DST:~0,-1%"
if "%DST:~1%"==":" set "DST=%DST%\"
echo.
echo  Copying... large amounts of data take time.
echo.
if exist "%SRC%\*" goto cpy_dir
call :MAKEARG "%DST%"
if exist "%DST%\" goto cpy_todir
copy /Y "%SRC%" %RARG% >nul
if errorlevel 1 goto cpy_err
goto cpy_done
:cpy_todir
copy /Y "%SRC%" %RARG% >nul
if errorlevel 1 goto cpy_err
goto cpy_done
:cpy_dir
call :MAKEARG "%SRC%"
set "SRCARG=%RARG%"
call :MAKEARG "%DST%"
set "DSTARG=%RARG%"
robocopy %SRCARG% %DSTARG% /E /R:1 /W:1 /NFL /NDL /NP /XD "$RECYCLE.BIN" "System Volume Information"
if errorlevel 8 goto cpy_err
:cpy_done
echo.
echo  Copy complete!
pause
exit /b 0
:cpy_err
echo.
echo  Copy finished with errors - check the messages above.
pause
exit /b 0

:: Delete file or folder
:DELETEITEM
call :ASKSET " Path of the file or folder to delete: "
if "%ANS%"=="" goto :eof
set "T=%ANS:"=%"
if exist "%T%" goto del_found
echo  Path not found!
pause
goto :eof
:del_found
if exist "%T%\*" goto del_dir
echo.
echo  This file will be permanently deleted: %T%
call :ASKSET " To confirm type DEL : "
if /i "%ANS%"=="DEL" goto del_dofile
echo  Cancelled - nothing was deleted.
pause
goto :eof
:del_dofile
del /f /q "%T%"
if exist "%T%" goto del_fail
echo  Deleted.
pause
goto :eof
:del_dir
echo.
echo  This folder and ALL of its contents will be deleted: %T%
call :ASKSET " To confirm type DEL : "
if /i "%ANS%"=="DEL" goto del_dord
echo  Cancelled - nothing was deleted.
pause
goto :eof
:del_dord
rd /s /q "%T%"
if exist "%T%" goto del_fail
echo  Deleted.
pause
goto :eof
:del_fail
echo  Could not delete! - file may be in use, or admin needed.
pause
exit /b 0

:: Zip folder or drive
:ZIPITEM
call :ASKSET " What to zip, e.g. E:\Docs or F:\ : "
if "%ANS%"=="" goto :eof
set "ZSRC=%ANS:"=%"
if exist "%ZSRC%" goto zip_found
echo  Path not found!
pause
goto :eof
:zip_found
call :ASKSET " Where to save the zip, e.g. G:\Backup.zip : "
if "%ANS%"=="" goto :eof
set "ZOUT=%ANS:"=%"
if "%ZSRC:~1,2%"==":\" goto zip_path
if "%ZSRC%"=="%ZSRC:~0,2%" goto zip_root
echo  Write a full path - like F:\Docs or F:\
pause
goto :eof
:zip_path
if "%ZSRC:~-1%"=="\" set "ZSRC=%ZSRC:~0,-1%"
if "%ZSRC:~1%"==":" goto zip_root
for %%F in ("%ZSRC%") do set "ZNAME=%%~nxF"
set "ZPARENT=%ZSRC:~0,2%\"
goto zip_go
:zip_root
set "ZPARENT=%ZSRC:~0,1%:\"
set "ZNAME=."
:zip_go
echo.
echo  Zipping... large data takes a while, please wait.
echo.
if exist "%SystemRoot%\System32\tar.exe" goto zip_tar
echo  -- tar not found; falling back to PowerShell which has
echo  -- trouble beyond 2 GB total. For big data use the
echo  -- copy tool instead.
powershell -NoProfile -Command "Compress-Archive -Path '%ZSRC%' -DestinationPath '%ZOUT%' -Force"
goto zip_end
:zip_tar
tar -a -c -f "%ZOUT%" --exclude "System Volume Information" --exclude "$RECYCLE.BIN" -C %ZPARENT% "%ZNAME%"
:zip_end
echo.
if errorlevel 1 goto zip_warn
echo  Done! Zip file saved at: %ZOUT%
pause
exit /b 0
:zip_warn
echo  Zipping finished with errors or warnings - check above.
pause
exit /b 0

:: File hash
:HASHFILE
call :ASKSET " File path: "
if "%ANS%"=="" goto :eof
set "HP=%ANS:"=%"
if exist "%HP%" goto hash_ok
echo  File not found!
pause
goto :eof
:hash_ok
call :ASKSET " Algorithm: 1=SHA256 / 2=SHA1 / 3=MD5 - number: "
set "ALG=SHA256"
if "%ANS%"=="2" set "ALG=SHA1"
if "%ANS%"=="3" set "ALG=MD5"
echo.
certutil -hashfile "%HP%" %ALG%
echo.
echo  Compare this value with the one published by the maker;
echo  a match means the file was not tampered with.
pause
exit /b 0

:: Take ownership
:TAKEOWN
call :NEEDADMIN
call :ASKSET " Path of the locked file or folder: "
if "%ANS%"=="" goto :eof
set "TK=%ANS:"=%"
if exist "%TK%" goto tk_ok
echo  Path not found!
pause
goto :eof
:tk_ok
echo  Ownership will be given to Administrators with full access.
echo  Large folders may take a while.
call :ASKSET " Start? type YES : "
if /i not "%ANS%"=="YES" goto :eof
icacls "%TK%" /setowner *S-1-5-32-544 /t /c /q
icacls "%TK%" /grant *S-1-5-32-544:F /t /c /q
echo.
echo  Done!
pause
exit /b 0

:: ==========================================================
:: MENU 4 TOOLS
:: ==========================================================

:: Format with double confirmation
:FORMAT
call :NEEDADMIN
echo.
echo  *** Formatting erases ALL data on the drive! ***
echo.
call :ASKDRIVE
if errorlevel 1 goto :eof
if /i "%DRV%:"=="%~d0" goto fmt_self
echo.
echo  Drive %DRV% information:
powershell -NoProfile -Command "Get-CimInstance Win32_LogicalDisk -Filter 'DeviceID=''%DRV%:''' | Format-List VolumeName, FileSystem, @{n='TotalGB';e={'{0:N1}' -f ($_.Size/1GB)}}, @{n='FreeGB';e={'{0:N1}' -f ($_.FreeSpace/1GB)}}"
echo  Step 1 of 2 - first confirmation:
call :ASKSET " To format %DRV%: type YES : "
if /i not "%ANS%"=="YES" goto fmt_cancel
echo  Step 2 of 2 - final confirmation:
call :ASKSET " Type only the drive letter %DRV% : "
set "ANS=%ANS:~0,1%"
if /i not "%ANS%"=="%DRV%" goto fmt_cancel
call :ASKSET " File system: 1=NTFS / 2=exFAT / 3=FAT32 - number: "
set "FS=NTFS"
if "%ANS%"=="2" set "FS=exFAT"
if "%ANS%"=="3" set "FS=FAT32"
call :ASKSET " Volume label after format - empty for none: "
set "LB=%ANS:&=%"
set "FMTLABEL="
if not "%LB%"=="" set FMTLABEL=/V:"%LB%"
echo.
echo  Formatting starts now - answer the format prompt if asked.
echo  Note: FAT32 cannot format drives larger than 32 GB.
echo.
format %DRV%: /FS:%FS% /Q %FMTLABEL%
echo.
echo  Format complete!
pause
exit /b 0
:fmt_cancel
echo.
echo  Cancelled - nothing was erased.
pause
exit /b 0
:fmt_self
echo.
echo  That is the drive this program is running from! Cannot format.
pause
exit /b 0

:: Optimize drive
:OPTIMIZE
call :NEEDADMIN
call :ASKDRIVE
if errorlevel 1 goto :eof
echo.
echo  Runs TRIM for SSDs or defrag for HDDs.
echo  Can take a long time - wait for it to finish.
call :ASKSET " Start? type YES : "
if /i not "%ANS%"=="YES" goto :eof
echo.
powershell -NoProfile -Command "Optimize-Volume -DriveLetter %DRV%"
echo.
echo  Optimization complete.
pause
exit /b 0

:: Clean temp files
:CLEAN
echo.
echo  Deleting temp files... one moment.
echo.
del /f /s /q "%TEMP%\*.*" >nul 2>&1
for /d %%p in ("%TEMP%\*") do rd /s /q "%%p" >nul 2>&1
net session >nul 2>&1
if not errorlevel 1 goto clean_admin
echo  -- User temp files deleted. To also clean Windows temp
echo  -- files, run this option again as admin.
goto clean_rc
:clean_admin
del /f /s /q "%SystemRoot%\Temp\*.*" >nul 2>&1
for /d %%p in ("%SystemRoot%\Temp\*") do rd /s /q "%%p" >nul 2>&1
:clean_rc
powershell -NoProfile -Command "try { Clear-RecycleBin -Force -ErrorAction SilentlyContinue } catch { }"
echo.
echo  Done! Check free space in the drive list on the menu.
pause
exit /b 0

:: Disk Cleanup
:CLEANMGR
start "" cleanmgr
echo  Disk Cleanup opened - pick a drive and click OK.
timeout /t 2 >nul
exit /b 0

:: Disk Management
:DISKMGT
echo  Opening Disk Management - click Yes if UAC appears.
start "" diskmgmt.msc
timeout /t 2 >nul
exit /b 0

:: ==========================================================
:: MENU 5 TOOLS
:: ==========================================================

:: User folders backup
:USERBACKUP
echo.
echo  Backs up: Desktop, Documents, Pictures, Music,
echo  Videos, Downloads and browser Favorites
echo.
call :ASKDRIVE
if errorlevel 1 goto :eof
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd-HHmm"') do set "TS=%%i"
set "BROOT=%DRV%:\Backup-%COMPUTERNAME%-%TS%"
echo  Destination: %BROOT%
call :ASKSET " Start? type YES : "
if /i not "%ANS%"=="YES" goto :eof
echo.
for %%f in (Desktop Documents Pictures Videos Music Downloads Favorites) do call :bakone "%%f"
echo.
echo  User backup finished! Everything is in %BROOT%
pause
exit /b 0
:bakone
if not exist "%USERPROFILE%\%~1" exit /b 0
echo --- Backing up %~1 ...
robocopy "%USERPROFILE%\%~1" "%BROOT%\%~1" /E /R:1 /W:1 /NFL /NDL /NP /XD "$RECYCLE.BIN" "System Volume Information"
exit /b 0

:: Restore user backup
:USERRESTORE
call :ASKSET " Backup folder path, e.g. F:\Backup-PC-20260101-1200 : "
if "%ANS%"=="" goto :eof
set "RSRC=%ANS:"=%"
if exist "%RSRC%" goto ur_ok
echo  Folder not found!
pause
goto :eof
:ur_ok
echo.
echo  Contents of this folder:
dir /b "%RSRC%"
echo.
echo  Files go back into the same-named user profile folders.
echo  Newer existing files will NOT be overwritten.
call :ASKSET " Start? type YES : "
if /i not "%ANS%"=="YES" goto :eof
echo.
for %%f in (Desktop Documents Pictures Videos Music Downloads Favorites) do if exist "%RSRC%\%%f" call :ur_one "%%f"
echo.
echo  Restore finished!
pause
exit /b 0
:ur_one
echo --- Restoring %~1 ...
robocopy "%RSRC%\%~1" "%USERPROFILE%\%~1" /E /R:1 /W:1 /NFL /NDL /NP
exit /b 0

:: Full system image
:IMAGE
call :NEEDADMIN
where wbadmin >nul 2>&1
if errorlevel 1 goto img_nowb
echo.
echo  Image backup of the whole Windows drive plus system
echo  partitions. Space needed: about the used space of C:
echo  Not available on Windows Home - use user backup or zip.
echo.
call :ASKDRIVE
if errorlevel 1 goto :eof
echo  Destination: drive %DRV%: - stored inside WindowsImageBackup.
call :ASKSET " Start? type YES : "
if /i not "%ANS%"=="YES" goto :eof
echo.
wbadmin start backup -backupTarget:%DRV%: -include:%SystemDrive% -allCritical -quiet
echo.
echo  Full backup finished!
pause
exit /b 0
:img_nowb
echo.
echo  wbadmin is not available on this Windows - use user backup or zip.
pause
exit /b 0

:: Export WiFi profiles
:WIFIEXPORT
set "WDIR=%USERPROFILE%\Desktop\WiFi-Backup"
mkdir "%WDIR%" 2>nul
echo.
echo  All saved WiFi profiles with passwords will be stored
echo  in the WiFi-Backup folder on your Desktop...
netsh wlan export profile key=clear folder="%WDIR%" >nul 2>&1
echo.
dir /b "%WDIR%\*.xml" 2>nul | findstr /r "." >nul
if errorlevel 1 goto wfx_no
echo  Created! - Desktop, folder WiFi-Backup
echo  WARNING: these files contain your WiFi passwords in
echo  plain text - delete them after use or keep them safe.
start "" explorer "%WDIR%"
goto wfx_end
:wfx_no
echo  Nothing was exported - maybe there are no saved WiFi profiles.
:wfx_end
pause
exit /b 0

:: Import WiFi profiles
:WIFIIMPORT
call :ASKSET " WiFi backup folder path, e.g. F:\WiFi-Backup : "
if "%ANS%"=="" goto :eof
set "WIMP=%ANS:"=%"
if not exist "%WIMP%" goto wim_no
echo  Adding profiles...
for %%f in ("%WIMP%\*.xml") do netsh wlan add profile filename="%%f" user=all
echo.
echo  Done - if there were no errors, your WiFi profiles are back.
goto wim_end
:wim_no
echo  Folder not found!
:wim_end
pause
exit /b 0

:: Show WiFi passwords
:WIFISHOW
echo.
echo  WiFi profiles saved on this system - with passwords:
echo  The line "Key Content" is the password.
echo.
for /f "tokens=2* delims=:" %%a in ('netsh wlan show profiles 2^>nul ^| findstr ":"') do call :wifione "%%a"
echo.
echo  If nothing was listed, there are no saved WiFi profiles.
pause
exit /b 0
:wifione
set "WN="
for /f "tokens=* delims= " %%b in ("%~1") do set "WN=%%b"
if not defined WN exit /b 0
echo.
echo   ===== %WN% =====
netsh wlan show profile name="%WN%" key=clear 2>nul
exit /b 0

:: Installed programs list
:PROGRAMS
echo.
echo  Building the installed programs list...
powershell -NoProfile -Command "Get-ItemProperty 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*','HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*' -ErrorAction SilentlyContinue | Where-Object DisplayName | Sort-Object DisplayName | Select-Object DisplayName, DisplayVersion, Publisher | Format-Table -AutoSize | Out-String -Width 200 | Out-File -FilePath ([Environment]::GetFolderPath('Desktop')+'\installed-programs.txt') -Encoding UTF8; Invoke-Item ([Environment]::GetFolderPath('Desktop')+'\installed-programs.txt')"
echo  Saved on Desktop: installed-programs.txt - golden before a reinstall!
pause
exit /b 0

:: Driver backup
:DRIVERS
echo.
driverquery /fo table > "%USERPROFILE%\Desktop\drivers-list.txt" 2>nul
echo  Full driver list saved: Desktop\drivers-list.txt
echo.
echo  Driver file backup - after a fresh Windows install all
echo  drivers come back without needing internet!
call :ASKSET " Back up drivers to another drive? type YES : "
if /i not "%ANS%"=="YES" goto :eof
call :NEEDADMIN
call :ASKDRIVE
if errorlevel 1 goto :eof
echo  Destination: %DRV%:\DriverBackup - starting...
dism /online /export-driver /destination:%DRV%:\DriverBackup
echo.
echo  Done!
pause
exit /b 0

:: ==========================================================
:: MENU 6 TOOLS
:: ==========================================================

:: Defender quick scan
:QUICKSCAN
set "MPCMD=%ProgramFiles%\Windows Defender\MpCmdRun.exe"
if exist "%MPCMD%" goto qs_ok
echo  Windows Defender not found - you probably have another antivirus.
pause
goto :eof
:qs_ok
echo.
echo  Quick scan started - takes a few minutes...
"%MPCMD%" -Scan -ScanType 1
echo.
echo  Scan finished.
pause
exit /b 0

:: Defender full scan
:FULLSCAN
set "MPCMD=%ProgramFiles%\Windows Defender\MpCmdRun.exe"
if exist "%MPCMD%" goto fs_ok
echo  Windows Defender not found - you probably have another antivirus.
pause
goto :eof
:fs_ok
echo.
echo  Full scan started - this can take a few hours!
echo  It covers the whole system, all files.
"%MPCMD%" -Scan -ScanType 2
echo.
echo  Full scan finished.
pause
exit /b 0

:: Show hidden files and extensions
:SHOWHIDDEN
call :ASKSET " 1=show hidden files and extensions / 2=back to default - number: "
if "%ANS%"=="1" goto sh_on
if "%ANS%"=="2" goto sh_off
goto :eof
:sh_on
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d 1 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 0 /f >nul
goto sh_apply
:sh_off
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Hidden /t REG_DWORD /d 2 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideFileExt /t REG_DWORD /d 1 /f >nul
:sh_apply
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe
echo  Done - Explorer was restarted.
pause
exit /b 0

:: God Mode folder
:GODMODE
set "GM=%USERPROFILE%\Desktop\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"
if exist "%GM%" goto gm_have
mkdir "%GM%"
echo  Created! Open the GodMode folder on your Desktop -
echo  hundreds of useful hidden Windows settings live there.
goto gm_end
:gm_have
echo  Already exists - the GodMode folder is on your Desktop.
:gm_end
pause
exit /b 0

:: Scheduled shutdown
:SHUTDOWN
call :ASKSET " In how many minutes? just the number, 0 means now: "
if "%ANS%"=="" goto :eof
for /f "delims=0123456789" %%n in ("%ANS%") do goto sh_bad
set /a SHSEC=%ANS%*60
call :ASKSET " 1=shutdown / 2=restart / 3=cancel previous timer - number: "
if "%ANS%"=="1" shutdown /s /t %SHSEC% /c "Drive Helper"
if "%ANS%"=="2" shutdown /r /t %SHSEC% /c "Drive Helper"
if "%ANS%"=="3" shutdown /a
echo  Registered - to cancel later, run this option and pick 3.
pause
exit /b 0
:sh_bad
echo  Numbers only please! Nothing was scheduled.
pause
exit /b 0

:: Task Manager
:TASKMGR
start "" taskmgr.exe
echo  Task Manager opened - see the Processes or Startup tab.
timeout /t 2 >nul
exit /b 0

:: Open an elevated Command Prompt
:ADMINCMD
net session >nul 2>&1
if not errorlevel 1 goto acmd_new
echo.
echo  A new Command Prompt will open with Administrator rights.
echo  Click Yes on the UAC prompt.
powershell -NoProfile -Command "Start-Process cmd.exe -Verb RunAs"
exit /b 0
:acmd_new
echo.
echo  This tool already runs as admin - opening a new
echo  Command Prompt window (it inherits admin rights).
start "" cmd.exe
exit /b 0

:: ==========================================================
:: RECOVERY MODE - active when Windows itself is not booted
:: (Windows RE "Command Prompt" from the Troubleshoot menu).
:: Only tools that exist in WinRE are used here.
:: ==========================================================

:recovery
cls
echo ==============================================================
echo        Drive Helper Pro  -  RECOVERY MODE
echo        Windows is not running - rescue tools only
echo ==============================================================
call :relist
echo --------------------------------------------------------------
echo    1  List drives + find Windows installations
echo    2  Rescue copy files to another drive
echo    3  Check a drive for errors - chkdsk + fix
echo    4  Offline repair of Windows files - SFC
echo    5  Repair boot - fixmbr / fixboot / rebuildbcd
echo    6  Unhide flash drive files - shortcut virus
echo    7  Open DISKPART - partition tools
echo    8  Open a new Command Prompt window
echo    9  Reboot or shut down the computer
echo   10  Rescue guide - how to use this mode
echo    0  Exit to the command prompt
echo --------------------------------------------------------------
call :ASKSET " Choice: "
if "%ANS%"=="1" call :relist
if "%ANS%"=="2" call :COPYITEM
if "%ANS%"=="3" call :CHKDSK
if "%ANS%"=="4" call :RESFC
if "%ANS%"=="5" call :REBOOTREP
if "%ANS%"=="6" call :UNHIDE
if "%ANS%"=="7" call :REDISKPART
if "%ANS%"=="8" call :RECMD
if "%ANS%"=="9" call :REPOWER
if "%ANS%"=="10" call :REGUIDE
if "%ANS%"=="0" goto rebye
if "%ANS%"=="" goto recovery
echo  Invalid choice!
timeout /t 2 >nul
goto recovery

:rebye
echo.
echo  Tip: to try booting the repaired Windows, reboot (option 9).
echo  You are back at the command prompt. To run this tool again
echo  type:  YOURUSB:\DriveHelper.bat
exit /b 0

:: List drives the WinRE way - no PowerShell needed
:relist
echo.
echo  Drives found right now:
for %%L in (A B C D E F G H I J K L M N O P Q R S T U V W Y Z) do call :reline %%L
echo.
echo  [WINDOWS INSTALLATION FOUND] = Windows lives on that drive.
echo  Note: in recovery mode drive letters may differ from normal!
exit /b 0
:reline
if not exist %1:\ exit /b 0
echo.
echo  ==== %1: ====
vol %1: 2>nul
if exist "%1:\Windows\System32\config\SYSTEM" echo   [WINDOWS INSTALLATION FOUND]
exit /b 0

:: Ask which drive holds the broken Windows
:rewask
set "REW="
for %%L in (C D E F G H I J K L M N O P Q R S T U V W Y Z) do if exist "%%L:\Windows\System32\config\SYSTEM" call :rewfirst %%L
if defined REW goto rewa_ok
echo  No Windows installation found on any drive!
pause
exit /b 1
:rewa_ok
call :ASKSET " Windows drive - Enter accepts %REW%: or type another letter: "
if "%ANS%"=="" exit /b 0
set "REW=%ANS:~0,1%"
if exist "%REW%:\Windows\System32\config\SYSTEM" exit /b 0
echo  No Windows installation found on %REW%:!
set "REW="
exit /b 1
:rewfirst
if defined REW exit /b 0
set "REW=%1"
echo   - Windows found on drive %1:
exit /b 0

:: Offline system file check on the broken Windows
:RESFC
echo.
echo  Repairs corrupted Windows files while it is not running.
echo  Takes 10-30 minutes.
call :rewask
if not defined REW goto :eof
echo.
call :ASKSET " Start offline SFC on %REW%:? type YES : "
if /i not "%ANS%"=="YES" goto :eof
sfc /offbootdir=%REW%:\ /offwindir=%REW%:\Windows
echo.
echo  Finished - if startup still fails, try boot repair (option 5).
pause
exit /b 0

:: Boot repair
:REBOOTREP
echo.
echo  Boot repair - fixes "Windows will not start" problems.
echo  On UEFI systems fixmbr may report "element not found" -
echo  that is normal, just continue with the other steps.
call :ASKSET " 1=fixmbr 2=fixboot 3=scanos 4=rebuildbcd 5=ALL in order : "
if "%ANS%"=="1" bootrec /fixmbr
if "%ANS%"=="2" bootrec /fixboot
if "%ANS%"=="3" bootrec /scanos
if "%ANS%"=="4" bootrec /rebuildbcd
if "%ANS%"=="5" goto rebr_all
goto rebr_end
:rebr_all
echo  --- fixmbr ---
bootrec /fixmbr
echo  --- fixboot ---
bootrec /fixboot
echo  --- scanos ---
bootrec /scanos
echo  --- rebuildbcd - this can take a few minutes ---
bootrec /rebuildbcd
:rebr_end
echo.
echo  Done! Reboot (option 9) and see if Windows starts.
pause
exit /b 0

:: Diskpart
:REDISKPART
echo.
echo  DISKPART opens in this window. Useful commands:
echo    list disk  list volume  select disk 1  detail volume
echo    assign letter=E   active   exit
echo  Be careful - diskpart can erase data!
call :ASKSET " Open DISKPART? type YES : "
if /i not "%ANS%"=="YES" goto :eof
diskpart
exit /b 0

:: Extra console window
:RECMD
echo.
echo  A new Command Prompt window opens. In recovery mode it
echo  already has full SYSTEM rights - no UAC needed here.
start "" cmd.exe
exit /b 0

:: Reboot / shutdown the WinRE way
:REPOWER
echo.
call :ASKSET " 1=reboot now  2=shut down now - number: "
if "%ANS%"=="1" goto rep_r
if "%ANS%"=="2" goto rep_s
goto :eof
:rep_r
call :ASKSET " Really reboot? type YES : "
if /i not "%ANS%"=="YES" goto :eof
wpeutil reboot
goto :eof
:rep_s
call :ASKSET " Really shut down? type YES : "
if /i not "%ANS%"=="YES" goto :eof
wpeutil shutdown
goto :eof

:: ==========================================================
:: RESCUE GUIDE (English) - shown from both menus
:: ==========================================================
:REGUIDE
cls
echo ==============================================================
echo        RESCUE GUIDE  -  when Windows will not boot
echo ==============================================================
echo.
echo  HOW TO GET INTO WINDOWS RECOVERY (WinRE):
echo.
echo   Way 1 - force recovery:
echo     Power on, and when the Windows logo appears hold the power
echo     button to cut power. Do this 3 times in a row - the third
echo     time Windows enters Recovery by itself.
echo.
echo   Way 2 - boot menu:
echo     Restart and tap F11, Esc or F12 - varies by brand - to open
echo     the boot or recovery menu.
echo.
echo   Way 3 - Windows install USB:
echo     On another PC create a bootable Windows USB with the Media
echo     Creation Tool, boot from it, click Next, then
echo     "Repair your computer".
echo.
echo   Way 4 - your DriveHelper rescue USB:
echo     If you made one with main menu option 8, just boot it -
echo     no working Windows needed at all.
echo.
pause
echo  THEN, INSIDE RECOVERY:
echo.
echo     Troubleshoot - Advanced options - Command Prompt
echo     Find your USB drive letter - letters are DIFFERENT here:
echo         dir c:     dir d:     dir e:     dir f:
echo     When you see DriveHelper.bat, run it - example:
echo         e:\DriveHelper.bat
echo.
echo  RECOMMENDED ORDER when Windows will not boot:
echo.
echo     1. Option 1  - list drives, find where Windows lives
echo     2. Option 2  - rescue copy important files FIRST
echo     3. Option 5  - boot repair - fixes most boot problems
echo     4. Option 3  - chkdsk if disk errors are suspected
echo     5. Option 4  - offline SFC if system files are corrupt
echo.
pause
echo  GOOD TO KNOW:
echo.
echo     - WinRE usually has NO internet - online repairs will not
echo       work here. Wired network can sometimes be started with
echo       this command, if the driver exists in WinRE:
echo           wpeutil InitializeNetwork
echo       Wi-Fi almost never works in WinRE.
echo     - You have full SYSTEM rights here - be careful with the
echo       delete and format tools.
echo     - If no drive shows [WINDOWS INSTALLATION FOUND], the
echo       partition table may be damaged: option 7 DISKPART, then
echo       run "list volume" inside it to inspect.
echo     - This tool fits on one USB stick - keep it somewhere you
echo       can find it when things go wrong.
echo.
pause
exit /b 0
/b 0

:: ==========================================================
:: INSTALL COPIES ON THIS PC - so the tool is reachable
:: from WinRE even without the USB stick
:: ==========================================================
:DEPLOY
echo.
echo  Copies this tool to a Tools folder on every local hard
echo  drive. Then, even without any USB, you can run it from
echo  Windows Recovery - see the note at the end.
echo.
set "DEPN=0"
for /f "delims=" %%L in ('powershell -NoProfile -Command "Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | ForEach-Object { $_.DeviceID }" ^| findstr ":"') do call :dep_one %%L
echo.
echo  Installed on %DEPN% drive-s.
echo  HOW TO USE FROM RECOVERY - with NO USB plugged in:
echo    Troubleshoot - Command Prompt, then try each drive:
echo       dir c:\tools     dir d:\tools     dir e:\tools
echo    when you see DriveHelper.bat, run it - example:
echo       c:\tools\drivehelper.bat
echo  Note: if the hard disk itself dies, only a bootable
echo  rescue USB - main menu option 8 - can still help.
pause
exit /b 0
:dep_one
set "DL=%~1"
if /i "%DL%"=="%~d0" (
    echo   %DL% skipped - this tool is running from there.
    exit /b 0
)
mkdir "%DL%\Tools" 2>nul
copy /Y "%~f0" "%DL%\Tools\DriveHelper.bat" >nul
if errorlevel 1 (
    echo   %DL% failed - could not copy.
    exit /b 0
)
if exist "%~dp0RESCUE-GUIDE.txt" copy /Y "%~dp0RESCUE-GUIDE.txt" "%DL%\Tools\" >nul
echo   %DL% - copy installed in %DL%\Tools
set /a DEPN+=1
exit /b 0

:: ==========================================================
:: MAKE A BOOTABLE RESCUE USB - boots straight into WinRE
:: with DriveHelper on it. UEFI systems, FAT32, no clean.
:: ==========================================================
:MKRESCUEUSB
call :NEEDADMIN
cls
echo ============ MAKE A BOOTABLE RESCUE USB ============
echo  This turns a USB stick into a rescue USB that boots
echo  into Windows Recovery - with this tool on it. Use a
echo  DIFFERENT USB than the one you run this from.
echo  - Erases the target USB - formatted FAT32, 32GB max
echo  - Boots on UEFI systems - nearly all PCs since 2013
echo  - Uses the WinRE recovery image of THIS PC
echo.
:: ---- step 1: find the WinRE image ----
set "WIMSRC="
set "REMOUNTED=0"
set "RD="
if exist "%SystemRoot%\System32\Recovery\winre.wim" set "WIMSRC=%SystemRoot%\System32\Recovery\winre.wim"
if not defined WIMSRC for /f "tokens=2* delims=:" %%a in ('reagentc /info ^| findstr /i /c:"Recovery image location"') do set "RELOC=%%b"
if defined RELOC call :rusub
if not defined WIMSRC for %%L in (C D E F G H I J K L M N O P Q R S T U V Y Z) do if exist "%%L:\Recovery\WindowsRE\winre.wim" set "WIMSRC=%%L:\Recovery\WindowsRE\winre.wim"
if not defined WIMSRC goto rusb_nowim
echo  Recovery image found:
echo    %WIMSRC%
:: ---- step 2: pick and format the USB ----
echo.
call :ASKDRIVE
if errorlevel 1 goto rusb_cleanup
if /i "%DRV%:"=="%~d0" goto rusb_self
echo.
echo  *** ALL DATA ON %DRV%: WILL BE ERASED! ***
call :ASKSET " Type YES to format the USB : "
if /i not "%ANS%"=="YES" goto rusb_cancel
format %DRV%: /FS:FAT32 /Q /V:RESCUE
if errorlevel 1 goto rusb_fmtfail
:: ---- step 3: copy boot files ----
if not exist "%SystemRoot%\Boot\EFI\bootmgfw.efi" goto rusb_nofiles
mkdir "%DRV%:\EFI\Boot" 2>nul
mkdir "%DRV%:\EFI\Microsoft\Boot" 2>nul
mkdir "%DRV%:\boot" 2>nul
mkdir "%DRV%:\sources" 2>nul
copy /Y "%SystemRoot%\Boot\EFI\bootmgfw.efi" "%DRV%:\EFI\Boot\bootx64.efi" >nul
set "SDISRC="
if exist "%SystemRoot%\Boot\DVD\EFI\boot.sdi" set "SDISRC=%SystemRoot%\Boot\DVD\EFI\boot.sdi"
if exist "%SystemRoot%\Boot\DVD\PCAT\boot.sdi" set "SDISRC=%SystemRoot%\Boot\DVD\PCAT\boot.sdi"
if not defined SDISRC goto rusb_nofiles
copy /Y "%SDISRC%" "%DRV%:\boot\boot.sdi" >nul
attrib -s -h -r "%WIMSRC%" >nul 2>&1
copy /Y "%WIMSRC%" "%DRV%:\sources\boot.wim" >nul
copy /Y "%~f0" "%DRV%:\DriveHelper.bat" >nul
if exist "%~dp0RESCUE-GUIDE.txt" copy /Y "%~dp0RESCUE-GUIDE.txt" "%DRV%:\" >nul
if not exist "%DRV%:\sources\boot.wim" goto rusb_copyfail
if not exist "%DRV%:\EFI\Boot\bootx64.efi" goto rusb_copyfail
:: ---- step 4: build the boot menu - BCD ----
set "BCDP=%DRV%:\EFI\Microsoft\Boot\BCD"
bcdedit /createstore "%BCDP%" >nul
if errorlevel 1 goto rusb_bcdfail
bcdedit /store "%BCDP%" /create {bootmgr} /d "DriveHelper Rescue" >nul
bcdedit /store "%BCDP%" /set {bootmgr} device boot >nul
bcdedit /store "%BCDP%" /create {ramdiskoptions} /d "Ramdisk options" >nul
bcdedit /store "%BCDP%" /set {ramdiskoptions} ramdisksdidevice boot >nul
bcdedit /store "%BCDP%" /set {ramdiskoptions} ramdisksdipath \boot\boot.sdi >nul
set "RLGUID="
for /f "tokens=2" %%g in ('bcdedit /store "%BCDP%" /create /d "WinRE Rescue" /application osloader ^| findstr "{"') do set "RLGUID=%%g"
if not defined RLGUID goto rusb_bcdfail
bcdedit /store "%BCDP%" /set %RLGUID% device ramdisk=[boot]\sources\boot.wim,{ramdiskoptions} >nul
bcdedit /store "%BCDP%" /set %RLGUID% osdevice ramdisk=[boot]\sources\boot.wim,{ramdiskoptions} >nul
bcdedit /store "%BCDP%" /set %RLGUID% path \windows\system32\boot\winload.efi >nul
bcdedit /store "%BCDP%" /set %RLGUID% systemroot \windows >nul
bcdedit /store "%BCDP%" /set %RLGUID% detecthal Yes >nul
bcdedit /store "%BCDP%" /set %RLGUID% winpe Yes >nul
bcdedit /store "%BCDP%" /default %RLGUID% >nul
call :reunmount
echo.
echo  DONE! Rescue USB created on drive %DRV%:
echo.
echo  HOW TO USE: plug it into the sick PC, power on, tap the
echo  boot menu key - F12, Esc or F9 - and pick the USB.
echo  It boots into Windows Recovery. Then:
echo  Troubleshoot - Command Prompt - and run, for example:
echo      e:\DriveHelper.bat
echo  The RESCUE GUIDE is on the USB too.
echo  If it refuses to boot, try disabling Secure Boot in BIOS.
pause
exit /b 0

:: helper: parse reagentc location + temporarily mount recovery partition as W:
:rusub
for /f "tokens=* delims= " %%c in ("%RELOC%") do set "RELOC=%%c"
if "%RELOC%"=="%RELOC:harddisk=%" exit /b 0
set "T=%RELOC:*harddisk=%"
for /f "tokens=1,2 delims=\" %%a in ("%T%") do (set "RD=%%a" & set "RP=%%b")
if not defined RD exit /b 0
set "RP=%RP:partition=%"
set "RSUB="
for /f "tokens=3,4 delims=\" %%c in ("%T%") do set "RSUB=%%c\%%d"
if not defined RSUB set "RSUB=Recovery\WindowsRE"
> "%TEMP%\dp_re_mount.txt" echo select disk %RD%
>> "%TEMP%\dp_re_mount.txt" echo select partition %RP%
>> "%TEMP%\dp_re_mount.txt" echo assign letter=W
diskpart /s "%TEMP%\dp_re_mount.txt" >nul 2>&1
if not exist W:\ exit /b 0
set "REMOUNTED=1"
set "WIMSRC=W:\%RSUB%\winre.wim"
if exist "%WIMSRC%" exit /b 0
set "WIMSRC="
exit /b 0

:: helper: unmount the temporary W: letter
:reunmount
if not "%REMOUNTED%"=="1" exit /b 0
> "%TEMP%\dp_re_unmount.txt" echo select disk %RD%
>> "%TEMP%\dp_re_unmount.txt" echo select partition %RP%
>> "%TEMP%\dp_re_unmount.txt" echo remove letter=W
diskpart /s "%TEMP%\dp_re_unmount.txt" >nul 2>&1
set "REMOUNTED=0"
exit /b 0

:: ---- failure / cancel exits ----
:rusb_nowim
echo.
echo  Could not find this PC's recovery image - winre.wim.
echo  Ask a friend with the same Windows version, or use the
echo  Media Creation Tool USB method from the Rescue Guide.
pause
exit /b 0
:rusb_self
echo.
echo  That is the USB this tool is running from! Use a second
echo  USB stick as the target.
call :reunmount
pause
exit /b 0
:rusb_cancel
echo.
echo  Cancelled - nothing was erased.
call :reunmount
pause
exit /b 0
:rusb_fmtfail
echo.
echo  Format failed. If the USB is bigger than 32 GB Windows
echo  refuses FAT32 - use a smaller stick, or format it as
echo  FAT32 with another tool first and run this again.
call :reunmount
pause
exit /b 0
:rusb_nofiles
echo.
echo  Boot files of this Windows are missing - this PC was
echo  probably installed in old BIOS mode. On such PCs use
echo  the Media Creation Tool USB method instead.
call :reunmount
pause
exit /b 0
:rusb_copyfail
echo.
echo  Copying the boot files failed - check free space on the
echo  USB and try again.
call :reunmount
pause
exit /b 0
:rusb_bcdfail
echo.
echo  Building the boot menu - BCD - failed. The USB has the
echo  files but may not boot. Try again or use the Media
echo  Creation Tool method.
call :reunmount
pause
exit /b 0
:rusb_cleanup
call :reunmount
exit /b 0
