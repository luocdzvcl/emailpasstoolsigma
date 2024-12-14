@echo off
:Menu
cls
echo ===========================
echo      HOTREMENK TOOLS
echo ===========================
echo.

echo Please select an option:
echo 1. Enter a single file path to filter
echo 2. Select a folder to filter all .txt files into one result file
echo 3. Exit
set /p choice=Enter your choice (1/2/3): 

if "%choice%"=="1" goto SingleFile
if "%choice%"=="2" goto FolderFilter
if "%choice%"=="3" goto ExitProgram
echo Invalid choice. Please try again.
echo.
goto Menu

:SingleFile
cls
echo ===========================
echo      FUNCTION 1: SINGLE FILE
echo ===========================
echo.
echo 1. Enter file path to filter
echo 2. Exit to Main Menu
set /p choice=Select an option (1/2): 

if "%choice%"=="1" goto EnterFilePath
if "%choice%"=="2" goto Menu
echo Invalid choice. Please try again.
goto SingleFile

:EnterFilePath
echo Please enter the log/data .txt file (e.g., C:\path\to\file.txt):
set /p filePath=

if not exist "%filePath%" (
    echo File not found. Please check the path and try again.
    echo.
    goto EnterFilePath
)

goto FilterFile

:FolderFilter
cls
echo ===========================
echo      FUNCTION 2: FOLDER FILTER
echo ===========================
echo.
echo 1. Enter folder path to filter all .txt files
echo 2. Exit to Main Menu
set /p choice=Select an option (1/2): 

if "%choice%"=="1" goto EnterFolderPath
if "%choice%"=="2" goto Menu
echo Invalid choice. Please try again.
goto FolderFilter

:EnterFolderPath
echo Please enter the folder path (e.g., C:\path\to\folder):
set /p folderPath=

if not exist "%folderPath%" (
    echo Folder not found. Please check the path and try again.
    echo.
    goto EnterFolderPath
)

for /f "tokens=2 delims==" %%I in ('"wmic os get localdatetime /value"') do set datetime=%%I
set day=%datetime:~6,2%
set month=%datetime:~4,2%
set year=%datetime:~0,4%
set hour=%datetime:~8,2%
set minute=%datetime:~10,2%
set second=%datetime:~12,2%

if not defined keyword (
    echo.
    echo Please enter the keyword for filtering URLs:
    set /p keyword=
)

set combinedFile=%keyword%_combined_%month%%day%%year%%hour%%minute%%second%.txt
echo Combined results will be saved to: %combinedFile%
echo.

set fileCount=0
for %%F in ("%folderPath%\*.txt") do (
    set /a fileCount+=1
    set filePath=%%F
    call :FilterFileToCombined
)

if %fileCount%==0 (
    echo No .txt files found in the folder.
    echo.
    goto Menu
)

echo All files have been processed. Results saved to: %combinedFile%.
echo.

echo Do you want to return to the main menu? (y/n)
set /p exitChoice=
if /i "%exitChoice%"=="y" goto Menu
goto FolderFilter

:FilterFileToCombined
echo Filtering file: %filePath%

set tempFile=unique_urls.tmp
echo. > "%tempFile%"

for /f "delims=" %%A in ('findstr /i "%keyword%" "%filePath%"') do (
    findstr /x /c:"%%A" "%tempFile%" >nul
    if errorlevel 1 (
        echo %%A >> "%tempFile%"
    )
)

for /f %%B in ('find /c /v "" "%tempFile%"') do set lineCount=%%B
if %lineCount%==0 (
    echo No unique URLs found in file: %filePath%.
    del "%tempFile%"
    echo.
    goto :EOF
)

type "%tempFile%" >> "%combinedFile%"
del "%tempFile%"

echo Results from %filePath% have been added to %combinedFile%.
echo.
goto :EOF

:FilterFile
echo Filtering file: %filePath%

set tempFile=unique_urls.tmp
echo.

echo Please enter the keyword for filtering URLs:
set /p keyword=

echo. > "%tempFile%"

for /f "delims=" %%A in ('findstr /i "%keyword%" "%filePath%"') do (
    findstr /x /c:"%%A" "%tempFile%" >nul
    if errorlevel 1 (
        echo %%A >> "%tempFile%"
    )
)

for /f %%B in ('find /c /v "" "%tempFile%"') do set lineCount=%%B
if %lineCount%==0 (
    echo No unique URLs found in file: %filePath%.
    del "%tempFile%"
    echo.
    goto Menu
)

for /f "tokens=2 delims==" %%I in ('"wmic os get localdatetime /value"') do set datetime=%%I
set day=%datetime:~6,2%
set month=%datetime:~4,2%
set year=%datetime:~0,4%
set hour=%datetime:~8,2%
set minute=%datetime:~10,2%
set second=%datetime:~12,2%

set outputFile=%keyword%_filtered_%month%%day%%year%%hour%%minute%%second%.txt
move /y "%tempFile%" "%outputFile%"

echo Results have been saved to: %outputFile%.
echo.

echo Do you want to return to the main menu? (y/n)
set /p exitChoice=
if /i "%exitChoice%"=="y" goto Menu
goto SingleFile

:ExitProgram
cls
echo ===========================
echo      EXIT PROGRAM
echo ===========================
echo.
echo Do you want to visit the email:pass filtering page? (Y/N)
set /p visitChoice=Enter your choice (Y/N): 

if /i "%visitChoice%"=="Y" start https://luocdzvcl.github.io/emailpasstoolsigma/
exit
if /i "%visitChoice%"=="N" exit
