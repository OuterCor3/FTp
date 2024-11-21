@echo off
:: Set the path to WinSCP (use the full path if needed)
set winscp=C:\Users\gonlu\AppData\Local\Programs\WinSCP\WinSCP.exe

:: Define local directory and remote directory
set localDir=C:\Users\gonlu\Desktop\testfolder\hello
set remoteDir=/hello

:: Server connection details
set host=192.168.137.1
set user=rob
set password=1234

:: Generate WinSCP script for transferring files
echo open ftp://%user%:%password%@%host% > temp_script.txt
echo lcd "%localDir%" >> temp_script.txt
echo cd %remoteDir% >> temp_script.txt
echo put * >> temp_script.txt
echo exit >> temp_script.txt

:: Run the script with WinSCP to transfer the files
%winscp% /script=temp_script.txt /log=upload_log.txt /ini=nul
set transferResult=%errorlevel%

:: Check if the transfer was successful using WinSCP's exit code
if %transferResult% equ 0 (
    echo Transfer was successful. Attempting to delete files...

    :: List files before deletion
    echo Listing files before deletion in %localDir%:
    dir "%localDir%" /s > before_delete_log.txt

    :: Attempt to delete files recursively (but keep folders)
    echo Attempting to delete files recursively...
    for /R "%localDir%" %%F in (*) do (
        if not "%%~aF"=="d" (
            del /Q /F "%%F" >> delete_log.txt 2>&1
        )
    )

    :: List files after deletion attempt
    echo Listing remaining files after delete attempt:
    dir "%localDir%" /s > after_delete_log.txt

    :: Check if files were actually deleted
    if exist "%localDir%\*" (
        echo Some files could not be deleted. Check delete_log.txt for errors.
        echo Remaining files:
        type after_delete_log.txt
    ) else (
        echo All files successfully deleted.
    )
) else (
    echo Transfer failed. No files deleted. WinSCP error code: %transferResult%
)

:: Clean up
del temp_script.txt

:: The script will close automatically after completion
exit