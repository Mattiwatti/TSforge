@echo off
setlocal
pushd "%~dp0"
set _HERE="%CD%"
set _LIBTSFORGE="%_HERE%\LibTSforge"
set _TSFORGECLI="%_HERE%\TSforgeCLI"

::call ..\..\..\Build\BatchFiles\GetDotnetPath.bat
:: ^ replace with 'where dotnet' and/or dotnet --list-sdks check to verify dotnet 8.0/9.0 present
:: NB 1: 9.0 is the first version of dotnet that allows targeting 32 bit x86 for AOT. If 32 bit support is not needed, the minimum SDK can be lowered to .NET 8.0.
:: NB 2. For some reason targeting ARM64 in this combination is fine even though there is no ARM64 until 6.3, but trying the same thing for ARM32 will fail.

rmdir /s /q "publish\win-x86" 1>NUL 2>&1
rmdir /s /q "publish\win-x64" 1>NUL 2>&1
rmdir /s /q "publish\win-arm64" 1>NUL 2>&1
mkdir "publish" 1>NUL

:: UE5 GitDependencies.csproj related notes ~2023:
:: -p:PublishSingleFile=true generates nullptr exception, because (quote):
::		P:\UnrealTournament\UnrealEngine\Engine\Source\Programs\GitDependencies\Program.cs(110,109): warning IL3000: 'System.Reflection.Assembly.Location' always returns an empty string
::		for assemblies embedded in a single-file app. If the path to the app directory is needed, consider calling 'System.AppContext.BaseDirectory'.
:: Seems to be N/A here because no reflection used (at least in the paths I tested).
::
:: -p:PublishTrimmed=true seems to work (and halves the total published dir size), but does generate additional warnings
::
:: -p:PublishReadyToRun=true is OK

echo.
echo Building for win-x86...
rmdir /S /Q "%_LIBTSFORGE%\bin" 1>NUL 2>&1
rmdir /S /Q "%_LIBTSFORGE%\obj" 1>NUL 2>&1
rmdir /S /Q "%_TSFORGECLI%\bin" 1>NUL 2>&1
rmdir /S /Q "%_TSFORGECLI%\obj" 1>NUL 2>&1

dotnet publish "%_LIBTSFORGE%\LibTSforge.csproj" -f net9.0-windows7.0 -r win-x86 -c Release -p:PublishReadyToRun=true --output "publish\win-x86" --nologo --self-contained
if errorlevel 1 goto :error
dotnet publish "%_TSFORGECLI%\TSforgeCLI.csproj" -f net9.0-windows7.0 -r win-x86 -c Release -p:PublishSingleFile=true -p:PublishReadyToRun=true --output "publish\win-x86" --nologo --self-contained
if errorlevel 1 goto :error

echo.
echo Building for win-x64...
rmdir /S /Q "%_LIBTSFORGE%\bin" 1>NUL 2>&1
rmdir /S /Q "%_LIBTSFORGE%\obj" 1>NUL 2>&1
rmdir /S /Q "%_TSFORGECLI%\bin" 1>NUL 2>&1
rmdir /S /Q "%_TSFORGECLI%\obj" 1>NUL 2>&1

dotnet publish "%_LIBTSFORGE%\LibTSforge.csproj" -f net9.0-windows7.0 -r win-x64 -c Release -p:PublishReadyToRun=true --output "publish\win-x64" --nologo --self-contained
if errorlevel 1 goto :error
dotnet publish "%_TSFORGECLI%\TSforgeCLI.csproj" -f net9.0-windows7.0 -r win-x64 -c Release -p:PublishSingleFile=true -p:PublishReadyToRun=true --output "publish\win-x64" --nologo --self-contained
if errorlevel 1 goto :error

echo.
echo Building for win-arm64...
rmdir /S /Q "%_LIBTSFORGE%\bin" 1>NUL 2>&1
rmdir /S /Q "%_LIBTSFORGE%\obj" 1>NUL 2>&1
rmdir /S /Q "%_TSFORGECLI%\bin" 1>NUL 2>&1
rmdir /S /Q "%_TSFORGECLI%\obj" 1>NUL 2>&1

dotnet publish "%_LIBTSFORGE%\LibTSforge.csproj" -f net9.0-windows7.0 -r win-arm64 -c Release -p:PublishReadyToRun=true --output "publish\win-arm64" --nologo --self-contained
if errorlevel 1 goto :error
dotnet publish "%_TSFORGECLI%\TSforgeCLI.csproj" -f net9.0-windows7.0 -r win-arm64 -c Release -p:PublishSingleFile=true -p:PublishReadyToRun=true --output "publish\win-arm64" --nologo --self-contained
if errorlevel 1 goto :error

goto ok

:error
echo Fuck! Don't worry, we'll get 'em next time...
goto :done

:ok
echo.
echo Great success!
goto :done

:done
endlocal
pause
