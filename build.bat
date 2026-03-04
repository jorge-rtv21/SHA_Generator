@echo off
:: =============================================
:: SHA_Generator - Build & Run Script
:: =============================================

:: Configurar entorno basado en NetworkTool
set CMAKE_DIR=C:\Qt\Tools\CMake_64\bin
set NINJA_DIR=C:\Qt\Tools\Ninja
set MINGW_COMPILER_DIR=C:\Qt\Tools\mingw1310_64\bin
set QT_DIR=C:\Qt\6.10.2\mingw_64\bin
set PATH=%MINGW_COMPILER_DIR%;%CMAKE_DIR%;%NINJA_DIR%;%QT_DIR%;%PATH%

:: Parsear argumentos
if "%1"=="run" goto RUN
if "%1"=="clean" goto CLEAN
if "%1"=="dist" goto DIST

:: Build por defecto
:BUILD
echo.
echo [1/2] Configurando CMake...
if not exist build (
    cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
)

echo.
echo [2/2] Compilando...
cmake --build build
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: La compilacion fallo.
    pause
    exit /b 1
)

echo.
echo ===================================
echo  Build exitoso!
echo  Ejecutable: build\appSHAGenerator.exe
echo ===================================
echo.
echo Usa: build.bat run    - para ejecutar
echo Usa: build.bat clean  - para limpiar
echo Usa: build.bat dist   - para crear distribucion
echo.
goto END

:: Ejecutar la app (siempre recompila primero)
:RUN
echo Compilando antes de ejecutar...
cmake --build build
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: La compilacion fallo.
    pause
    exit /b 1
)
echo Ejecutando SHA Generator...
start "" build\appSHAGenerator.exe
goto END

:: Limpiar build
:CLEAN
echo Limpiando directorio build...
if exist build rmdir /s /q build
echo Limpieza completada.
goto END

:: Crear distribucion con windeployqt
:DIST
echo Creando distribucion portable...
if not exist build\appSHAGenerator.exe (
    echo No se encontro el ejecutable. Compilando primero...
    call :BUILD
)
if not exist dist mkdir dist
copy /y build\appSHAGenerator.exe dist\
windeployqt --compiler-runtime --qmldir qml dist\appSHAGenerator.exe
echo.
echo Distribucion creada en: dist\
goto END

:END
