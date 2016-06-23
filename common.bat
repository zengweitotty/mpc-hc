REM @ECHO OFF
REM (C) 2015 see Authors.txt
REM
REM This file is part of MPC-HC.
REM
REM MPC-HC is free software; you can redistribute it and/or modify
REM it under the terms of the GNU General Public License as published by
REM the Free Software Foundation; either version 3 of the License, or
REM (at your option) any later version.
REM
REM MPC-HC is distributed in the hope that it will be useful,
REM but WITHOUT ANY WARRANTY; without even the implied warranty of
REM MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
REM GNU General Public License for more details.
REM
REM You should have received a copy of the GNU General Public License
REM along with this program.  If not, see <http://www.gnu.org/licenses/>.


IF "%1" == "" CALL :SubMsg "ERROR" "%~nx0, No argument was provided." & EXIT /B
PUSHD %~dp0
CALL %*
POPD
EXIT /B

:SubPreBuild
IF EXIST "build.user.bat" CALL "build.user.bat"

IF NOT DEFINED MPCHC_MINGW32 IF DEFINED MINGW32 (SET "MPCHC_MINGW32=%MINGW32%") ELSE (EXIT /B 1)
IF NOT DEFINED MPCHC_MINGW64 IF DEFINED MINGW64 (SET "MPCHC_MINGW64=%MINGW64%") ELSE (EXIT /B 1)
IF NOT DEFINED MPCHC_MSYS    IF DEFINED MSYS    (SET "MPCHC_MSYS=%MSYS%")       ELSE (EXIT /B 1)

IF NOT EXIST "%MPCHC_MINGW32%" EXIT /B 1
IF NOT EXIST "%MPCHC_MINGW64%" EXIT /B 1
IF NOT EXIST "%MPCHC_MSYS%"    EXIT /B 1
EXIT /B

:SubSetPath
CALL :SubPreBuild
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
SET "PATH=%MPCHC_MSYS%\usr\bin;%MPCHC_MSYS%\bin;%MPCHC_MINGW32%\bin;%PATH%"
EXIT /B

:SubDoesExist
FOR %%G IN (%~1) DO (SET FOUND=%%~$PATH:G)
IF NOT DEFINED FOUND EXIT /B 1
EXIT /B

:SubGetVersion
REM Get the version
IF NOT EXIST "include\version_rev.h" SET "FORCE_VER_UPDATE=True"
IF /I "%FORCE_VER_UPDATE%" == "True" CALL "update_version.bat" && SET "FORCE_VER_UPDATE=False"

FOR /F "tokens=2,3" %%A IN ('FINDSTR /R /C:"define MPC_VERSION_[M,P]" "include\version.h"') DO (
  SET "%%A=%%B"
)

FOR /F "tokens=2,3" %%A IN ('FINDSTR /R /C:"define MPC" "build\version_rev.h"') DO (
  SET "%%A=%%B"
)

IF "%MPC_VERSION_REV%" NEQ "0" (SET "MPCHC_NIGHTLY=1") ELSE (SET "MPCHC_NIGHTLY=0")

SET "MPCHC_HASH=%MPCHC_HASH:~4,-2%"
IF DEFINED MPCHC_BRANCH (
  SET "MPCHC_BRANCH=%MPCHC_BRANCH:~4,-2%"
)

IF "%MPCHC_NIGHTLY%" NEQ "0" (
  SET "MPCHC_VER=%MPC_VERSION_MAJOR%.%MPC_VERSION_MINOR%.%MPC_VERSION_PATCH%.%MPC_VERSION_REV%"
) ELSE (
  SET "MPCHC_VER=%MPC_VERSION_MAJOR%.%MPC_VERSION_MINOR%.%MPC_VERSION_PATCH%"
)
EXIT /B

:SubDetectCurl
IF EXIST curl.exe (SET "CURL=curl.exe" & EXIT /B)
IF EXIST "%CURL_PATH%\curl.exe" (SET "CURL=%CURL_PATH%\curl.exe" & EXIT /B)
IF EXIST "%CURL_PATH%\bin\curl.exe" (SET "CURL=%CURL_PATH%\bin\curl.exe" & EXIT /B)
FOR %%G IN (curl.exe) DO (SET "CURL_PATH=%%~$PATH:G")
IF EXIST "%CURL_PATH%" (SET "CURL=%CURL_PATH%" & EXIT /B)
EXIT /B

:SubDetectTar
IF EXIST tar.exe (SET "TAR=tar.exe" & EXIT /B)
IF EXIST "%TAR_PATH%\tar.exe" (SET "TAR=%TAR_PATH%\tar.exe" & EXIT /B)
FOR %%G IN (tar.exe) DO (SET "TAR_PATH=%%~$PATH:G")
IF EXIST "%TAR_PATH%" (SET "TAR=%TAR_PATH%" & EXIT /B)
EXIT /B

:SubDetectInnoSetup
FOR /F "tokens=5*" %%A IN (
  'REG QUERY "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Inno Setup 5_is1" /v "Inno Setup: App Path" 2^>NUL ^| FIND "REG_SZ" ^|^|
   REG QUERY "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Inno Setup 5_is1" /v "Inno Setup: App Path" 2^>NUL ^| FIND "REG_SZ"') DO SET "InnoSetupPath=%%B\ISCC.exe"
EXIT /B

:SubDetectSevenzipPath
FOR %%G IN (7z.exe) DO (SET "SEVENZIP_PATH=%%~$PATH:G")
IF EXIST "%SEVENZIP_PATH%" (SET "SEVENZIP=%SEVENZIP_PATH%" & EXIT /B)

FOR %%G IN (7za.exe) DO (SET "SEVENZIP_PATH=%%~$PATH:G")
IF EXIST "%SEVENZIP_PATH%" (SET "SEVENZIP=%SEVENZIP_PATH%" & EXIT /B)

FOR /F "tokens=2*" %%A IN (
  'REG QUERY "HKLM\SOFTWARE\7-Zip" /v "Path" 2^>NUL ^| FIND "REG_SZ" ^|^|
   REG QUERY "HKLM\SOFTWARE\Wow6432Node\7-Zip" /v "Path" 2^>NUL ^| FIND "REG_SZ"') DO SET "SEVENZIP=%%B\7z.exe"
EXIT /B

:SubMsg
ECHO. & ECHO ------------------------------
IF /I "%~1" == "ERROR" (
  CALL :SubColorText "0C" "[%~1]" "%~2"
) ELSE IF /I "%~1" == "INFO" (
  CALL :SubColorText "0A" "[%~1]" "%~2"
) ELSE IF /I "%~1" == "WARNING" (
  CALL :SubColorText "0E" "[%~1]" "%~2"
)
ECHO ------------------------------ & ECHO.
IF /I "%~1" == "ERROR" (
  IF NOT DEFINED SILENT (
    ECHO Press any key to exit...
    PAUSE >NUL
  )
  ENDLOCAL
  EXIT /B 1
) ELSE (
  EXIT /B
)

:SubColorText
IF DEFINED NOCOLORS ECHO %~2 %~3 & EXIT /B
FOR /F "tokens=1,2 delims=#" %%G IN (
  '"PROMPT #$H#$E# & ECHO ON & FOR %%H IN (1) DO REM"') DO (
  SET "DEL=%%G")
<NUL SET /p ".=%DEL%" > "%~2"
FINDSTR /v /a:%1 /R ".18" "%~2" NUL
DEL "%~2" > NUL 2>&1
REM The space in the following ECHO is intentional
ECHO  %~3
EXIT /B

:SubGetDuration
SET START_TIME=%START_TIME: =%
SET END_TIME=%END_TIME: =%

FOR /F "tokens=1-4 delims=:.," %%G IN ("%START_TIME%") DO (
  SET /A "STARTTIME=(100%%G %% 100) * 360000 + (100%%H %% 100) * 6000 + (100%%I %% 100) * 100 + (100%%J %% 100)"
)

FOR /F "tokens=1-4 delims=:.," %%G IN ("%END_TIME%") DO (
  SET /A "ENDTIME=(100%%G %% 100) * 360000 + (100%%H %% 100) * 6000 + (100%%I %% 100) * 100 + (100%%J %% 100)"
)

SET /A DURATION=%ENDTIME%-%STARTTIME%
IF %ENDTIME% LSS %STARTTIME% SET /A "DURATION+=24 * 360000"

SET /A DURATIONH=%DURATION% / 360000
SET /A DURATIONM=(%DURATION% - %DURATIONH%*360000) / 6000
SET /A DURATIONS=(%DURATION% - %DURATIONH%*360000 - %DURATIONM%*6000) / 100
SET /A DURATIONHS=(%DURATION% - %DURATIONH%*360000 - %DURATIONM%*6000 - %DURATIONS%*100)*10

IF %DURATIONH%  EQU 0 (SET DURATIONH=)  ELSE (SET DURATIONH=%DURATIONH%h )
IF %DURATIONM%  EQU 0 (SET DURATIONM=)  ELSE (SET DURATIONM=%DURATIONM%m )
IF %DURATIONS%  EQU 0 (SET DURATIONS=)  ELSE (SET DURATIONS=%DURATIONS%s )
IF %DURATIONHS% EQU 0 (SET DURATIONHS=) ELSE (SET DURATIONHS=%DURATIONHS%ms)

SET "DURATION=%DURATIONH%%DURATIONM%%DURATIONS%%DURATIONHS%"
EXIT /B
