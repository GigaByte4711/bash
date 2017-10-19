#begin!

#Identifies OS and installed programs
YUM_CMD=$(command -v yum)
APT_GET_CMD=$(command -v apt-get)
#OTHER_CMD=$(command -v <other installer>)

dependson cowsay
dependson macchanger
dependson network-manager

interface=$1
newhostname=$RANDOM

if [ $# -eq 0 ]
  then
    echo "No arguments supplied. What interface do you want to randomize?"
    read -p "Please enter the interface: " interface
fi

cowsay R@ndom-a-miz!ng y3r shaniz-b1ts

sudo hostname $newhostname 
echo $newhostname | sudo tee /etc/hostname > /dev/null

sudo nmcli nm enable false
sudo macchanger -A $interface
sudo nmcli nm enable true

cowsay New hostname is $newhostname!

#end!


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

