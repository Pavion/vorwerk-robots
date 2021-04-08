#!/bin/bash
echo [96mThis a script for obtaining your Vorwerk vacuum robots serial and secret[0m
echo [96mPlease check the repository at: https://github.com/Pavion/vorwerk-robots[0m
echo [96mThis script is based on https://github.com/nicoh88/node-kobold/[0m
echo [96mThis is a part of openHAB Neato/Vorwerk binding fork and is distributed "as is" with no warranty[0m
echo
echo [92mPlease enter your Vorwerk email: [0m
read email
curl --silent -X "POST" "https://mykobold.eu.auth0.com/passwordless/start" \
     -H 'Content-Type: application/json' \
     -d $'{
  "send": "code",
  "email": "'$email'",
  "client_id": "KY4YbVAvtgB7lp8vIbWQ7zLk3hssZlhR",
  "connection": "email"
}' >/dev/null
echo
echo You should have received an email from Vorwerk...
echo
echo [92mPlease enter your received 6-digit code: [0m
read code
echo
echo Try to obtain token id from server
echo
curl --silent -X "POST" "https://mykobold.eu.auth0.com/oauth/token" \
     -H 'Content-Type: application/json' \
     -d $'{
  "prompt": "login",
  "grant_type": "http://auth0.com/oauth/grant-type/passwordless/otp",
  "scope": "openid email profile read:current_user",
  "locale": "en",
  "otp": "'$code'",
  "source": "vorwerk_auth0",
  "platform": "ios",
  "audience": "https://mykobold.eu.auth0.com/userinfo",
  "username": "'$email'",
  "client_id": "KY4YbVAvtgB7lp8vIbWQ7zLk3hssZlhR",
  "realm": "email",
  "country_code": "DE"
}' > vorwerk_token.txt

echo Server response:
cat vorwerk_token.txt
echo
echo
token=`cat vorwerk_token.txt | jq -r ".id_token"`

echo Your token:> vorwerk.txt
echo $token>> vorwerk.txt
echo>> vorwerk.txt

echo [93mYour token:[0m
echo [92m$token[0m
echo
echo Try to obtain robot list from server
curl --silent --location --request GET 'https://beehive.ksecosys.com/dashboard' \
     --header 'Authorization: Auth0Bearer '$token > vorwerk_robots.txt
echo
echo Server response:
cat vorwerk_robots.txt
echo
echo
serial=`cat vorwerk_robots.txt | jq -r ".robots[0].serial"`

echo Your serial:>> vorwerk.txt
echo $serial>>vorwerk.txt
echo>> vorwerk.txt

echo [93mYour serial:[0m
echo [92m$serial[0m

secret=`cat vorwerk_robots.txt | jq -r ".robots[0].secret_key"`

echo Your secret:>> vorwerk.txt
echo $secret>> vorwerk.txt
echo>> vorwerk.txt

echo [93mYour secret:[0m
echo [92m$secret[0m

echo
echo If you have more than one robot, please check the output file vorwerk_robots.txt for other serials

echo
echo [96mThank you for using this script, your codes are saved as text files[0m
echo
