@echo off
..\PlaydateSDK\bin\pdc source test.pdx
echo Error level: %errorlevel%
if errorlevel 1 goto end
taskkill /im PlaydateSimulator*
start ..\PlaydateSDK\bin\PlaydateSimulator.exe test.pdx

:end