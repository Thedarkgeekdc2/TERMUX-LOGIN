#!/bin/bash
trap ' '2 20
#BANNER
banner() {
clear    
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

#YOUR BANNER
your_banner () {
    read -p "Enter your name: " you 
    espeak -s 150 -v en+m3 -p 25 "welcome $you"
    clear
    figlet -c -k  $you | lolcat
    
    printf "\n"
    printf "                          \e[101m\e[1;77m::  we Fuck the Fuckers  ::\e[0m\n"
    printf "                          \e[101m\e[1;77m::  We Love the Lovers!  ::\e[0m\n"
    printf "\n"
    echo  "                                 telegram @HUNT3R136" | lolcat
    printf "\n"
cd $HOME
rm -rf TERMUX-LOGIN
    
}

#USERNAME SHELL
echo
echo
user_name () {
    
    read -p "Enter username: " usr1
    usr2="$(awk 'NR == 1' /data/data/com.termux/files/usr/share/login/crdintals)"
    # [[ $usr1 == usr2 ]] && echo $?
    if [[ $usr1 == $usr2 ]]
    then
    echo
echo
echo
echo    
        printf "\033[1;33m   Please wait...";
        echo
        sleep 2
        echo
        pass_word
        
    else
    echo
echo
echo
echo    
        printf "\033[0;31m   WRONG USERNAME!!"
        sleep 2
        banner
        user_name
    fi
}

pass2="$(awk 'NR == 2' /data/data/com.termux/files/usr/share/login/crdintals | openssl enc -aes-256-cbc -md sha512 -a -d -pbkdf2 -iter 100000 -salt -pass pass:'test@1234')"
#PASSWORD SHELL
pass_word () {
    echo
echo
    banner
    echo -n "Enter password: "
    read -s pass1
    echo
    pass2="$(awk 'NR == 2' /data/data/com.termux/files/usr/share/login/crdintals | openssl enc -aes-256-cbc -md sha512 -a -d -pbkdf2 -iter 100000 -salt -pass pass:'test@1234')"
    if [[ $pass1 == $pass2 ]]
    then
echo
echo
echo
echo
        printf "\033[1;33m   Please wait...";
        echo
        sleep 2
        banner
echo 
echo
echo
echo
        echo "login successfully!" |lolcat
        sleep 2
        clear
        your_banner
        
    else
echo
echo
echo
echo
        printf "\033[0;31m   WRONG PASSWORD!!"
        sleep 2
        banner
        pass_word
    fi
}



#MENU
menu()
{
    banner
echo
    echo ""
    echo -e "\e[93m[01] PROCEED TO LOGIN"
    echo -e "\e[93m[02] RE-REGISTER ACCNT"
    echo -e "\e[93m[03] RECOVER PASSWORD"
    echo -e "\e[93m[04] FOLLOW ME ON INSTAGRAM"
    echo ""
}


#Change password
dat_of_birth () {
echo
echo
    echo "Enter DOB to recover your password(01012001): "
    read birthday
    digit=`echo "$birthday" | egrep "^[0-9]+$"`
    if [ "$digit" ]
    then
        echo $birthday >> /data/data/com.termux/files/usr/share/login/crdintals
echo
echo    
    echo "Password & DOB Saved succesfully!!" | lolcat
    else
echo
echo
echo
echo    
    printf "\033[0;31m   ENTER ONLY NUMBERS IN DOB!!"
        sleep 3
        
        banner


        dat_of_birth
    fi
}
set_password () {
    read -p "Set your username: " username
    echo $username > /data/data/com.termux/files/usr/share/login/crdintals
echo
echo    
echo "Always Remember your username $username" | lolcat
    sleep 2
banner
    read -p "Enter new password: " frstpsswd;
    echo
    read  -p "Retype password: " scndpsswd;
    
    if [ $frstpsswd == $scndpsswd ];
    then
        echo $frstpsswd | openssl enc -aes-256-cbc -md sha512 -a -pbkdf2 -iter 100000 -salt -pass pass:'test@1234' >> /data/data/com.termux/files/usr/share/login/crdintals
        
dat_of_birth
        
        sleep 3
        clear
        bash login.sh
        
    else
echo
echo
echo
        echo
        printf "\033[0;31m   PASSWORD DIDN'T MATCH!! "
sleep 3
banner
chg_pass
    fi
}

chg_pass (){
echo
echo
banner
    read -p "Enter old password: " old_pass
    if [[ $old_pass == $pass2 ]]
    then
        clear
        banner
        set_password
    else
echo
echo
echo    
    echo
        printf "\033[0;31m     You have entered wrong password!"
       sleep 3
      banner
        menu
        start
    fi
}



#Recover password
forgot_pass () {
echo
echo
banner
    read -p "Enter your DOB when you settingup account: " dob1
    dob2="$(awk 'NR ==3' /data/data/com.termux/files/usr/share/login/crdintals)"
    if [[ $dob1 == $dob2 ]]
    then
echo
echo 
       echo "This is your password: " | lolcat
        awk 'NR == 2' /data/data/com.termux/files/usr/share/login/crdintals | openssl enc -aes-256-cbc -md sha512 -a -d -pbkdf2 -iter 100000 -salt -pass pass:'test@1234'
        sleep 4
        clear
        menu
        start
    else
echo
echo
echo
echo
        printf "\033[0;31m   WRONG DOB!!"
        sleep 2
        banner
        menu
        start
    fi
}

#start programme
start () {
    read -p "Choose option: " choose
    
    if [[ $choose == "01" || $choose == "1" ]];
    then
        clear
        banner
        user_name
    elif [[ $choose == "02" || $choose == "2" ]];
    then
        chg_pass
    elif [[ $choose == "03" || $choose == "3" ]];
    then
        forgot_pass
    elif [[ $choose == "04" || $choose == "4" ]];
    then
        xdg-open https://instagram.com/raazzz136
    else
banner
        menu
        start
    fi
}

menu
start


