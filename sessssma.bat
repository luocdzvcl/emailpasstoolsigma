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
:: Nhập đường dẫn file .txt
echo Please enter the log/data .txt file (e.g., C:\path\to\file.txt):
set /p filePath=

:: Kiểm tra xem file có tồn tại không
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
:: Nhập đường dẫn folder
echo Please enter the folder path (e.g., C:\path\to\folder):
set /p folderPath=

:: Kiểm tra xem folder có tồn tại không
if not exist "%folderPath%" (
    echo Folder not found. Please check the path and try again.
    echo.
    goto EnterFolderPath
)

:: Lấy ngày giờ hiện tại để đặt tên file kết quả tổng hợp
for /f "tokens=2 delims==" %%I in ('"wmic os get localdatetime /value"') do set datetime=%%I
set day=%datetime:~6,2%
set month=%datetime:~4,2%
set year=%datetime:~0,4%
set hour=%datetime:~8,2%
set minute=%datetime:~10,2%
set second=%datetime:~12,2%

:: Khởi tạo file kết quả tổng hợp
set combinedFile=%keyword%_combined_%random%.txt
echo Combined results will be saved to: %combinedFile%
echo.

:: Lặp qua từng file .txt trong folder
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

echo All files have been processed. Results saved to: %combinedFile%
echo.

:: Prompt to return to main menu after processing
echo Do you want to return to the main menu? (y/n)
set /p exitChoice=
if /i "%exitChoice%"=="y" goto Menu
goto FolderFilter

:FilterFileToCombined
:: Lọc URL từ file hiện tại và nối vào file tổng hợp
echo ===========================
echo Filtering file: %filePath%

:: File tạm thời để lưu các URL duy nhất
set tempFile=unique_urls.tmp

:: Khởi tạo file tạm thời trống
echo. > "%tempFile%"

:: Nhập từ khóa nếu chưa có
if not defined keyword (
    echo.
    echo Please enter the keyword for filtering URLs:
    set /p keyword=
)

:: Lọc URL, kiểm tra sự duy nhất và lưu vào file tạm
for /f "delims=" %%A in ('findstr /i "%keyword%" "%filePath%"') do (
    findstr /x /c:"%%A" "%tempFile%" >nul
    if errorlevel 1 (
        echo %%A >> "%tempFile%"
    )
)

:: Nếu không có kết quả, bỏ qua
for /f %%B in ('find /c /v "" "%tempFile%"') do set lineCount=%%B
if %lineCount%==0 (
    echo No unique URLs found in file: %filePath%.
    del "%tempFile%"
    echo.
    goto :EOF
)

:: Nối kết quả từ file tạm vào file tổng hợp
type "%tempFile%" >> "%combinedFile%"
del "%tempFile%"

echo Results from %filePath% have been added to %combinedFile%.
echo.
goto :EOF

:FilterFile
:: Lọc một file đơn lẻ
echo ===========================
echo Filtering file: %filePath%

:: File tạm thời để lưu các URL duy nhất
set tempFile=unique_urls.tmp

:: Nhập từ khóa lọc URL
echo.
echo Please enter the keyword for filtering URLs:
set /p keyword=

:: Khởi tạo file tạm thời trống
echo. > "%tempFile%"

:: Lọc URL, kiểm tra sự duy nhất và lưu vào file tạm
for /f "delims=" %%A in ('findstr /i "%keyword%" "%filePath%"') do (
    findstr /x /c:"%%A" "%tempFile%" >nul
    if errorlevel 1 (
        echo %%A >> "%tempFile%"
    )
)

:: Nếu không có kết quả, thông báo và thoát
for /f %%B in ('find /c /v "" "%tempFile%"') do set lineCount=%%B
if %lineCount%==0 (
    echo No unique URLs found in file: %filePath%.
    del "%tempFile%"
    echo.
    goto Menu
)

:: Lưu kết quả vào file đầu ra
set outputFile=%keyword%_filtered_%random%.txt
move /y "%tempFile%" "%outputFile%"

echo Results have been saved to: %outputFile%.
echo.

:: Prompt to return to main menu after processing
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
