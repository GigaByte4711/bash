#!/bin/bash

if [ $# -eq 0 ]; then
    ARG=false
else
NetInterface=$1
fi

#Identifies OS and installed programs
YUM_CMD=$(command -v yum)
APT_GET_CMD=$(command -v apt-get)
NM_AVAILABLE=$(command -v nmcli)
#OTHER_CMD=$(command -v <other installer>)

# Other Variables
essid=BTOpenzone

#All of the individual functions are up here!

#<-------------------------------FUNCTIONS---------------------------------------->#

ConnectifyMe(){

 # Ping is 8 packets, Grep looks for total failure. This is to give BT some leeway for having shitty ping.
if ping -c 8 8.8.8.8 | grep '100% packet loss\|Network is unreachable'
then
	echo "$(date "+%Y-%m-%d %H:%M:%S:") Connection down"

	if [[ ! -z $NM_AVAILABLE ]]; then
    		if nmcli | grep "BTOpenzone"
    		then 
			curl 'https://www.btopenzone.com:8443/ante' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: en-gb,en;q=0.5' -H 'Connection: keep-alive' -H 'Cookie: JSESSIONID=716ri2hfsar64; __utma=171794931.404001753.1385254451.1385254451.1385254451.1; __utmb=171794931.3.10.1385254451; __utmc=171794931; __utmz=171794931.1385254451.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); s_cc=true; s_sq=%5B%5BB%5D%5D' -H 'Host: www.btopenzone.com:8443' -H 'Referer: https://www.btopenzone.com:8443/wpb' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:25.0) Gecko/20100101 Firefox/25.0' -H 'Content-Type: application/x-www-form-urlencoded' --data "username=$username&password=$password&x=0&y=0&xhtmlLogon=https%3A%2F%2Fwww.btopenzone.com%3A8443%2Fante" > /dev/null
		else    
			# Disconnect onboard WLAN if my USB is plugged in.
        		nmcli dev disconnect iface wlan{0..20} > /dev/null 2>&1
			echo "Connecting to Access Point"
			nmcli dev wifi connect $essid ifname $NetInterface
		fi

 	else
	:
  	fi
else
        echo "$(date "+%Y-%m-%d %H:%M:%S:") Online"
        sleep 3

fi
}

#<-------------------------------------------------------------------------------->#
DecryptCheck() {

if [ $? -ne 0 ] ; then
rm -f userdata.dat
  echo "Incorrect Password! Please try again!"
sleep 3

DecryptMe
fi
}
#<-------------------------------------------------------------------------------->#
EncryptCheck() {

if [ $? -ne 0 ] ; then

  echo "Encryption Failed! Please try again!"
sleep 3

EncryptMe
fi
}
#<-------------------------------------------------------------------------------->#
EncryptMe(){
clear
echo "The program will now prompt you for a Password to protect your details."
echo "Remember this, otherwise you will have to re-enter your BT credentials!"
echo ""
openssl des3 -salt -in userdata.dat -out userdata.crypt >/dev/null 2>&1
EncryptCheck
rm -f userdata.dat
ConfigCheck
}
#<-------------------------------------------------------------------------------->#
DecryptMe(){
while [ -z "$BTUsername" ]; do #Whilst the script doesn't know your details...
clear
echo "The program will now ask for your password to unlock your details."
echo ""
openssl des3 -d -salt -in userdata.crypt -out userdata.dat 2>/dev/null
DecryptCheck



. ./userdata.dat #Read the settings file
username=$BTUsername #Put the settings
password=$BTPassword #In the scripts memory
NetInterface=$Interface
rm -f userdata.dat
done
}
#<-------------------------------------------------------------------------------->#
ConfigureMe(){
echo "There is no configuration file present. Obtaining necessary data now."
if [ "$ARG" = false ]; then
	read -p "Please enter the interface you would like to use: " NetInterface
fi 
read -p "Please enter the username used to log in to OpenZone: " NewUsername
clear
read -sp "Please enter the password used to log in to OpenZone: " NewPassword
echo ""
echo "BTUsername="$NewUsername >> userdata.dat
echo "BTPassword="$NewPassword >> userdata.dat
echo "Interface="$NetInterface >> userdata.dat
. ./userdata.dat
username=$BTUsername
password=$BTPassword
NetInterface=$Interface
echo ""
}
#<-------------------------------------------------------------------------------->#
ConfigCheck(){
clear
if [ -f userdata.crypt ] #If there's an encrypted file,
then

DecryptMe

elif [ -f userdata.dat ] #If there's a decrypted file,
then

EncryptMe



else

ConfigureMe

ConfigCheck
fi
}
#<-------------------------------------------------------------------------------->#
#Package Installer
dep-install(){
 PACKAGE=$1
 if [[ ! -z $YUM_CMD ]]; then
    sudo yum -y install $PACKAGE > /dev/null
 elif [[ ! -z $APT_GET_CMD ]]; then
    sudo apt-get -y install curl $PACKAGE > /dev/null
# elif [[ ! -z $OTHER_CMD ]]; then
#    $OTHER_CMD <proper arguments>
 else
    echo "error: Do not know how to install $PACKAGE"
    exit 1;
 fi
}
#<-------------------------------------------------------------------------------->#
#Dependency Check
dependson(){
program=$1
if [ -x "$(command -v $program)" ]; then
  echo "$program is already installed!"
    else
        dep-install $1
    fi
}
#<-------------------------------------------------------------------------------->#

#All dependencies are installed here
dependson curl
dependson openssl

ConfigCheck
#clear

# Our connectivity Loop
while [ 1 ]; do
ConnectifyMe
done



#<-------------------------------------------------------------------------------->#
