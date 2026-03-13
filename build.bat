@echo off
setlocal EnableDelayedExpansion

set BUILD_DIR=build
set OUTPUT_DIR=%BUILD_DIR%\output
set VENDOR_DIR=%BUILD_DIR%\vendor

set EXE_NAME=odin_sdl3_template.exe
set SDL_VERSION=release-3.4.2

if not exist %BUILD_DIR% mkdir %BUILD_DIR%
if not exist %OUTPUT_DIR% mkdir %OUTPUT_DIR%
if not exist %VENDOR_DIR% mkdir %VENDOR_DIR%

cls

if "%~1" == "build" (
    odin build source -out:%OUTPUT_DIR%\%EXE_NAME%
) else if "%~1" == "build-debug" (
    odin build source -out:%OUTPUT_DIR%\%EXE_NAME% -debug
) else if "%~1" == "run" (
    odin run source -out:%OUTPUT_DIR%\%EXE_NAME%
) else if "%~1" == "run-debug" (
    odin run source -out:%OUTPUT_DIR%\%EXE_NAME% -debug
) else if "%~1" == "get-sdl" (
    curl -L -o %OUTPUT_DIR%\SDL3.dll https://raw.githubusercontent.com/odin-lang/Odin/master/vendor/sdl3/SDL3.dll
    curl -L -o %OUTPUT_DIR%\SDL3.lib https://raw.githubusercontent.com/odin-lang/Odin/master/vendor/sdl3/SDL3.lib
) else if "%~1" == "build-sdl" (
    for /f "tokens=*" %%i in ('"C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath') do set VS=%%i

    if "!VS!" equ "" (
        echo ERROR: MSVC installation not found
        exit /b 1
    )

    pushd %VENDOR_DIR%

    if not exist sdl (
        git clone https://github.com/libsdl-org/SDL.git sdl
    )

    cd sdl

    git checkout %SDL_VERSION%
    call "!VS!\Common7\Tools\vsdevcmd.bat" -arch=x64 -host_arch=x64 || exit /b 1
    cmake -S . -B build
    cmake --build build --config Release

    popd

    copy /Y "%VENDOR_DIR%\sdl\build\Release\SDL3.dll" "%OUTPUT_DIR%\SDL3.dll"
    copy /Y "%VENDOR_DIR%\sdl\build\Release\SDL3.lib" "%OUTPUT_DIR%\SDL3.lib"
)
