@echo off
pushd "%~dp0apps\reader_app"
chcp 65001 >nul
call flutter run -d windows
if %errorlevel% neq 0 (
  echo.
  echo Flutter run exited with error code %errorlevel%.
)
echo.
pause
popd