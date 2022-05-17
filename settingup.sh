#!/bin/bash



#BANNER
banner() {
    figlet -c -k  HUNT3R | lolcat
    echo  "                                                         - DINESH CHAUDHARY"
    printf " "
    printf "\e[1;32m                  .:.:.\e[0m\e[1;95m Apk dev with kivy and ASD Tools \e[0m\e[1;32m.:.:.\e[0m\n"
    
    printf "\e[1;32m                   .:.:.\e[0m\e[1;95m Web dev and Reverse engineering \e[0m\e[1;32m.:.:.\e[0m\n"
    printf "\n"
    printf "                           \e[101m\e[1;77m::  we Fuck the Fuckers  ::\e[0m\n"
    printf "                           \e[101m\e[1;77m::  We Love the Lovers!  ::\e[0m\n"
    printf "\n"
}

#BASIC SETTINGS
clear
banner
echo
echo
echo -e "\e[1;34m Setting up tool environment----//--wait 10 sec--" | lolcat
sleep 10
apt purge zsh -y
pkg install figlet zsh ruby -y
gem install lolcat
rm -rf /data/data/com.termux/files/usr/.hunt3r
rm -rf /data/data/com.termux/files/usr/share/login/
mkdir /data/data/com.termux/files/usr/share/login
cd /$HOME/TERMUX-LOGIN
cp -r * /data/data/com.termux/files/usr/share/login/
cd
rm -rf TERMUX-LOGIN
#cat bashrc.txt > /data/data/com.termux/files/usr/etc/bash.bashrc
#cat zshrc.txt > /data/data/com.termux/files/usr/etc/zshrc
echo "clear" >/data/data/com.termux/files/usr/etc/bash.bashrc
echo "bash /data/data/com.termux/files/usr/share/login/login.sh" >> /data/data/com.termux/files/usr/etc/bash.bashrc
echo "clear" >/data/data/com.termux/files/usr/etc/zshrc
echo "bash /data/data/com.termux/files/usr/share/login/login.sh" >> /data/data/com.termux/files/usr/etc/zshrc
echo "PS1='%# ' "  >> /data/data/com.termux/files/usr/etc/zshrc
echo
echo
echo -e "\e[0;90m =====[Setup complete]====="
sleep 5
clear

#USERNAME SETTING
set_username () {
echo
echo
    read -p "Set your username: " username
    echo $username > crdintals
    echo "Always Remember your username $username" | lolcat
    sleep 2
}

dat_of_birth () {
echo
echo
    echo "Enter DOB to recover your password(01012001): "
    read birthday
    digit=`echo "$birthday" | egrep "^[0-9]+$"`
    if [ "$digit" ]
    then
        echo $birthday >> crdintals
        echo "Password & DOB Saved succesfully!!" | lolcat
    else
        printf "\033[0;31m   ENTER ONLY NUMBERS IN DOB!!"
        sleep 3
        clear
        banner
set_username
echo
echo
        set_password
    fi
}
#PASSWORD SETTING
set_password () {
    
    read -p "Enter new password: " frstpsswd;
    
    read  -p "Retype password: " scndpsswd;
    
    if [ $frstpsswd == $scndpsswd ];
    then
        echo $frstpsswd | openssl enc -aes-256-cbc -md sha512 -a -pbkdf2 -iter 100000 -salt -pass pass:'test@1234' >> /data/data/com.termux/files/usr/share/login/crdintals
        dat_of_birth
        
        sleep 3
        clear
        bash /data/data/com.termux/files/usr/share/login/login.sh
        
    else
        echo
  
      printf "\033[0;31m   PASSWORD DIDN'T MATCH!"
sleep 3
clear
banner
set_username
echo
echo
set_password
    fi
}

clear
banner
set_username
echo
echo
set_password
