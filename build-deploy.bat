@echo off
chcp 65001 >nul
cd /d "%~dp0"

echo. & echo Compilando... & echo.
cd src\VitruviusAddin && dotnet build -c Release -o bin/Staging >nul 2>&1

if not exist "bin\Staging\VitruviusAddin.dll" (
    echo ERRO: Build falhou
    pause & exit /b 1
)

echo Copiando DLL para Revit...
copy /Y "bin\Staging\VitruviusAddin.dll" "C:\ProgramData\Autodesk\Revit\Addins\2026\" >nul 2>&1

if errorlevel 1 (
    echo ERRO: Verifique se Revit está fechado
    pause & exit /b 1
)

cd "%~dp0src\VitruviusMcp" && dotnet build -c Release >nul 2>&1

echo.
echo ✅ PRONTO! Abra o Revit agora.
echo.
pause
