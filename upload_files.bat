@echo off
set winscp=C:\Users\gonlu\AppData\Local\Programs\WinSCP\WinSCP.exe
set localDir=C:\Users\gonlu\Desktop\TEST
set remoteDir=/
set host=192.168.18.146
set user=rob
set password=1234
set logFile=%localDir%\transfer_log.txt

:: Append to the log file (instead of overwriting)
echo ------------------------------------------ >> "%logFile%"
echo Transfer Log - %date% %time% >> "%logFile%"
echo ------------------------------------------ >> "%logFile%"
echo. >> "%logFile%"

:: Log files to be transferred
echo [Files to be transferred] >> "%logFile%"
for %%f in ("%localDir%\*") do (
    if /i not "%%~nxf"=="transfer_log.txt" (
        echo [INFO] %%~nxf - %date% %time% >> "%logFile%"
    )
)

:: Prepare a temporary WinSCP script file
set scriptFile=transfer.txt
(
    echo open sftp://%user%:%password%@%host%
    echo lcd %localDir%
    echo cd %remoteDir%
    echo put * -filemask="|transfer_log.txt"
    echo exit
) > %scriptFile%

:: Execute the file transfer
%winscp% /script=%scriptFile%
set transferResult=%errorlevel%

:: Check transfer result
if %transferResult% equ 0 (
    echo [SUCCESS] File transfer completed successfully - %date% %time% >> "%logFile%"
    echo Deleting local files...
    
    :: Delete files in the local directory and subfolders
    for /r "%localDir%" %%f in (*) do (
        if /i not "%%~nxf"=="transfer_log.txt" (
            del "%%f"
            if exist "%%f" (
                echo [ERROR] Failed to delete file: %%~nxf - %date% %time% >> "%logFile%"
            ) else (
                echo [SUCCESS] Deleted file: %%~nxf - %date% %time% >> "%logFile%"
            )
        )
    )
) else (
    echo [ERROR] File transfer failed. Exit code: %transferResult% - %date% %time% >> "%logFile%"
)

:: Add log file upload to the script file
(
    echo open sftp://%user%:%password%@%host%
    echo lcd %localDir%
    echo cd %remoteDir%
    echo put "%logFile%"
    echo exit
) > %scriptFile%

:: Upload the log file to the server
%winscp% /script=%scriptFile%
set uploadLogResult=%errorlevel%

:: Check log upload result
if %uploadLogResult% equ 0 (
    echo [SUCCESS] Log file uploaded to server - %date% %time% >> "%logFile%"
) else (
    echo [ERROR] Failed to upload log file. Exit code: %uploadLogResult% - %date% %time% >> "%logFile%"
)

:: Clean up temporary script file
del %scriptFile%

:: Optional: Clean up the local log file
:: del "%logFile%"

pause 