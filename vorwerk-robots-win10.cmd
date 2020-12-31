@echo off

IF NOT EXIST C:\Windows\SysWOW64\curl.exe (
  ECHO [92mSorry, this script works on Windows 10 only[0m
  PAUSE
  goto :exit
)

SETLOCAL ENABLEDELAYEDEXPANSION
SET token=
SET secret=
SET serial=

ECHO [96mThis a script for obtaining your Vorwerk vacuum robots' serial and secret
ECHO Please check the repository at: https://github.com/Pavion/vorwerk-robots
ECHO This script is based on https://github.com/nicoh88/node-kobold/ 
ECHO This is a part of openHAB Neato/Vorwerk binding fork and is distributed "as is" with no warranty[0m
ECHO. 

SET /p email="[92mPlease enter your Vorwerk email: [0m"
C:\Windows\SysWOW64\curl.exe --silent -X "POST" "https://mykobold.eu.auth0.com/passwordless/start" -H "Content-Type: application/json" -d "{\"send\":\"code\",\"email\":\"%email%\",\"client_id\":\"KY4YbVAvtgB7lp8vIbWQ7zLk3hssZlhR\",\"connection\":\"email\"}" > nul
ECHO.
ECHO You should have received an email from Vorwerk... 
ECHO.
SET /p code="[92mPlease enter your received 6-digit code: [0m"
ECHO.
ECHO Try to obtain token id from server
ECHO.
C:\Windows\SysWOW64\curl.exe --silent -X "POST" "https://mykobold.eu.auth0.com/oauth/token" -H "Content-Type: application/json" -d "{\"otp\":\"%code%\",\"username\":\"%email%\",\"prompt\":\"login\",\"grant_type\":\"http://auth0.com/oauth/grant-type/passwordless/otp\",\"scope\":\"openid email profile read:current_user\",\"locale\":\"en\",\"source\":\"vorwerk_auth0\",\"platform\":\"ios\",\"audience\":\"https://mykobold.eu.auth0.com/userinfo\",\"client_id\":\"KY4YbVAvtgB7lp8vIbWQ7zLk3hssZlhR\",\"realm\":\"email\",\"country_code\":\"DE\"}" > vorwerk_token.txt

ECHO Server response:
TYPE vorwerk_token.txt
ECHO.
ECHO.

FOR /f "tokens=3 delims=:" %%a IN (vorwerk_token.txt) DO SET token=%%a
FOR /f "tokens=1 delims=," %%a IN ("%token%") DO SET token=%%a
SET token=!token:~1,-1!

ECHO Your token:> vorwerk.txt
ECHO %token%>> vorwerk.txt
ECHO.>> vorwerk.txt

ECHO [93mYour token:[0m
ECHO [92m%token%[0m
ECHO.
ECHO Try to obtain robot list from server


C:\Windows\SysWOW64\curl.exe --silent --request GET "https://beehive.ksecosys.com/dashboard" --header "Authorization: Auth0Bearer %token%" > vorwerk_robots.txt
ECHO.
ECHO Server response:
TYPE vorwerk_robots.txt
ECHO.
ECHO.

FOR /f "tokens=17 delims=:" %%a IN (vorwerk_robots.txt) DO SET serial=%%a
FOR /f "tokens=1 delims=," %%a IN ("%serial%") DO SET serial=%%a
SET serial=!serial:~1,-1!

ECHO Your serial:>> vorwerk.txt
ECHO %serial%>>vorwerk.txt
ECHO.>> vorwerk.txt

ECHO [93mYour serial:[0m
ECHO [92m%serial%[0m

FOR /f "tokens=23 delims=:" %%a IN (vorwerk_robots.txt) DO SET secret=%%a
FOR /f "tokens=1 delims=," %%a IN ("%secret%") DO SET secret=%%a
SET secret=!secret:~1,-1!

ECHO Your secret:>> vorwerk.txt
ECHO %secret%>> vorwerk.txt
ECHO.>> vorwerk.txt

ECHO [93mYour secret:[0m
ECHO [92m%secret%[0m

ECHO. 
ECHO If you have more then one robot, please check the output file vorwerk_robots.txt for other serials

ECHO.
ECHO [96mThank you for using this script. Press any key to exit, your codes will be then opened in your editor.[0m
ECHO.

PAUSE > NUL

START "Vorwerk" vorwerk.txt

:exit
EXIT