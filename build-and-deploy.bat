@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo.
echo ========================================
echo   VITRUVIUS V2 — BUILD E DEPLOY
echo ========================================
echo.

REM Obter o diretório raiz do projeto
set PROJECT_ROOT=%~dp0
cd /d "%PROJECT_ROOT%"

REM ========================================
REM 1. BUILD
REM ========================================
echo [1/5] COMPILANDO VitruviusAddin...
cd src\VitruviusAddin
dotnet build -c Release -o bin/Staging >nul 2>&1

if not exist "bin\Staging\VitruviusAddin.dll" (
    echo ERRO: Build falhou. DLL não encontrada em bin\Staging\
    pause
    exit /b 1
)
echo ✓ Build OK

REM ========================================
REM 2. LIMPAR bin\Release (se existir)
REM ========================================
echo [2/5] Limpando bin\Release...
if exist "bin\Release" (
    rmdir /s /q "bin\Release" >nul 2>&1
    echo ✓ Limpeza OK
) else (
    echo ✓ Nada para limpar
)

REM ========================================
REM 3. COPIAR DLL PARA REVIT ADD-INS
REM ========================================
echo [3/5] Copiando DLL para Revit Add-ins...
set ADDIN_DIR=C:\ProgramData\Autodesk\Revit\Addins\2026

if not exist "%ADDIN_DIR%" (
    echo ERRO: Diretório de add-ins não encontrado: %ADDIN_DIR%
    echo Verifique se o Revit 2026 está instalado.
    pause
    exit /b 1
)

copy /Y "bin\Staging\VitruviusAddin.dll" "%ADDIN_DIR%\" >nul 2>&1
if errorlevel 1 (
    echo ERRO: Não foi possível copiar a DLL.
    echo Verifique se o Revit está fechado.
    pause
    exit /b 1
)
echo ✓ Deploy OK

REM ========================================
REM 4. COMPILAR MCP SERVER
REM ========================================
echo [4/5] Compilando VitruviusMcp...
cd "%PROJECT_ROOT%src\VitruviusMcp"
dotnet build -c Release >nul 2>&1

if exist "bin\Release\VitruviusMcp.exe" (
    echo ✓ MCP Build OK
) else (
    echo ⚠ MCP build falhou (não crítico)
)

REM ========================================
REM 5. TESTE HTTP
REM ========================================
echo [5/5] Testando com HTTP...
cd "%PROJECT_ROOT%"

REM Aguardar 2 segundos para o Revit carregar a DLL
timeout /t 2 /nobreak >nul

REM Executar teste
powershell -NoProfile -ExecutionPolicy Bypass -File "tests\http-tests\09-select_by_type.ps1" "Wall"

echo.
echo ========================================
echo ✅ BUILD E DEPLOY CONCLUÍDOS
echo ========================================
echo.
echo Próximos passos:
echo 1. Abra o Revit 2026 com um projeto ativo
echo 2. Use a ferramenta select_by_type na interface
echo 3. Confirme se funcionou
echo.
pause
