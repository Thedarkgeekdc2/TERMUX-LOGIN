#!/data/data/com.termux/files/usr/bin/bash

# Login script for TERMUX-LOGIN with OTP recovery
# Uses .msmtprc from setup for Gmail SMTP
# Stores files in /data/data/com.termux/files/home/.config/.termux-login
# Blue/yellow design, no OTP for login

# Define paths
config_dir="/data/data/com.termux/files/home/.config/.termux-login"
cred_file="$config_dir/crdintals"
msmtp_conf="$config_dir/.msmtprc"
log_file="$config_dir/login.log"

# Initialize attempts
attempts=0
max_attempts=3

# Logging function
log_event () {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$log_file"
}

# Sanitize input
sanitize_input () {
    echo "$1" | grep -E '^[a-zA-Z0-9@._-]+$'
}

# Check internet
check_internet () {
    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        echo -e "\e[31mInternet required for OTP. Press Enter when online or Ctrl+C to exit.\e[0m"
        log_event "No internet detected"
        read -r
        check_internet
    fi
}

# Banner
banner () {
    clear
    if command -v figlet &> /dev/null && command -v lolcat &> /dev/null; then
        figlet -c -k "LOGIN" | lolcat -f -t -S 39
    else
        echo -e "\e[34m===== TERMUX-LOGIN =====\e[0m"
    fi
    echo -e "\e[34m~THEDARKGEEKDC©2025-26\e[0m"
    echo
}

# Send OTP
send_otp () {
    local email="$1" context="$2"
    otp=$(shuf -i 100000-999999 -n 1) || {
        echo -e "\e[31mOTP generation failed.\e[0m"
        log_event "OTP generation failed"
        return 1
    }
    echo -e "\e[34mSending OTP to $email...\e[0m"
    {
        echo "Subject: Termux-Login $context"
        echo "To: $email"
        echo "From: $smtp_user"
        echo ""
        echo "Your OTP is: $otp"
        echo "~THEDARKGEEKDC©2025-26"
    } | msmtp --file="$msmtp_conf" "$email" && {
        echo -e "\e[34mOTP sent! Check email (including spam).\e[0m"
        log_event "OTP sent to $email for $context"
        return 0
    }
    echo -e "\e[31mFailed to send OTP. Check internet.\e[0m"
    log_event "Failed to send OTP to $email"
    return 1
}

# Verify OTP
verify_otp () {
    local input_otp="$1"
    [[ "$input_otp" =~ ^[0-9]{6}$ ]] || {
        echo -e "\e[31mInvalid OTP! Must be 6 digits.\e[0m"
        log_event "Invalid OTP input"
        return 1
    }
    [ "$input_otp" = "$otp" ] && {
        echo -e "\e[34mOTP verified!\e[0m"
        log_event "OTP verified"
        return 0
    }
    echo -e "\e[31mIncorrect OTP!\e[0m"
    log_event "Incorrect OTP"
    return 1
}

# Login
login () {
    [ -f "$cred_file" ] && [ -r "$cred_file" ] || {
        echo -e "\e[31mCredentials file not found!\e[0m"
        log_event "Credentials file missing"
        exit 1
    }
    [ $attempts -ge $max_attempts ] && {
        echo -e "\e[31mToo many attempts! Locked for 5 minutes.\e[0m"
        log_event "Too many failed attempts"
        sleep 300
        attempts=0
        banner
        login
        return
    }
    echo -e "\e[33mUsername:\e[0m"
    read -p "" usr
    sanitized_usr=$(sanitize_input "$usr")
    [ -z "$sanitized_usr" ] || [ "$sanitized_usr" != "$usr" ] && {
        echo -e "\e[31mInvalid username! Use letters, numbers, @, ., _, -.\e[0m"
        log_event "Invalid username: $usr"
        sleep 2
        banner
        login
        return
    }
    echo -e "\e[33mPassword:\e[0m"
    read -s -p "" pass
    echo
    sanitized_pass=$(sanitize_input "$pass")
    [ -z "$sanitized_pass" ] || [ "$sanitized_pass" != "$pass" ] && {
        echo -e "\e[31mInvalid password! Use letters, numbers, @, ., _, -.\e[0m"
        log_event "Invalid password"
        sleep 2
        banner
        login
        return
    }
    hashed_usr=$(echo -n "$usr" | sha256sum | cut -d' ' -f1)
    hashed_pass=$(echo -n "$pass" | sha256sum | cut -d' ' -f1)
    stored_usr=$(awk 'NR==1' "$cred_file")
    stored_pass=$(awk 'NR==2' "$cred_file")
    [ "$hashed_usr" = "$stored_usr" ] && [ "$hashed_pass" = "$stored_pass" ] && {
        echo -e "\e[34mLogin successful!\e[0m"
        log_event "Successful login: $usr"
        sleep 2
        clear
        cd $HOME
        [ -d "TERMUX-LOGIN" ] && {
            rm -rf "TERMUX-LOGIN"/*
            rmdir "TERMUX-LOGIN" && log_event "Deleted TERMUX-LOGIN" || {
                echo -e "\e[31mWarning: Failed to delete TERMUX-LOGIN.\e[0m"
                log_event "Failed to delete TERMUX-LOGIN"
            }
        }
        exit 0
    }
    attempts=$((attempts + 1))
    echo -e "\e[31mIncorrect credentials! $((max_attempts - attempts)) attempts left.\e[0m"
    log_event "Failed login: $usr"
    sleep 2
    banner
    login
}

# Menu
menu () {
    banner
    echo -e "\e[33m[1] Login\e[0m"
    echo -e "\e[33m[2] Change Password\e[0m"
    echo -e "\e[33m[3] Recover Account\e[0m"
    echo -e "\e[33m[4] Follow on Instagram\e[0m"
    echo
}

# Recover account
recover_account () {
    [ -f "$msmtp_conf" ] || {
        echo -e "\e[31mSMTP configuration not found! Run setup.sh first.\e[0m"
        log_event "SMTP configuration missing"
        sleep 2
        banner
        menu
        start
        return
    }
    smtp_user=$(grep '^user ' "$msmtp_conf" | cut -d' ' -f2)
    echo -e "\e[33mEnter recovery email:\e[0m"
    read -p "" user_email
    sanitized_email=$(sanitize_input "$user_email")
    [ -z "$sanitized_email" ] || [ "$sanitized_email" != "$user_email" ] && {
        echo -e "\e[31mInvalid email! Use letters, numbers, @, ., _, -.\e[0m"
        log_event "Invalid email: $user_email"
        sleep 2
        recover_account
        return
    }
    hashed_email=$(echo -n "$user_email" | sha256sum | cut -d' ' -f1)
    stored_email=$(awk 'NR==3' "$cred_file")
    [ "$hashed_email" != "$stored_email" ] && {
        echo -e "\e[31mEmail not registered!\e[0m"
        log_event "Email not registered: $user_email"
        sleep 2
        banner
        menu
        start
        return
    }
    check_internet
    send_otp "$user_email" "Recovery" && {
        echo -e "\e[33mEnter 6-digit OTP:\e[0m"
        read -p "" input_otp
        verify_otp "$input_otp" && {
            echo -e "\e[34mOTP verified. Set new password.\e[0m"
            log_event "Recovery OTP verified: $user_email"
            sleep 2
            set_password
            return
        }
    }
    echo -e "\e[31mRecovery failed. Try again.\e[0m"
    sleep 2
    banner
    menu
    start
}

# Set password
set_password () {
    echo -e "\e[33mSet username:\e[0m"
    read -p "" username
    sanitized_username=$(sanitize_input "$username")
    [ -z "$sanitized_username" ] || [ "$sanitized_username" != "$username" ] && {
        echo -e "\e[31mInvalid username! Use letters, numbers, @, ., _, -.\e[0m"
        log_event "Invalid username: $username"
        sleep 2
        set_password
        return
    }
    hashed_username=$(echo -n "$username" | sha256sum | cut -d' ' -f1)
    echo "$hashed_username" > "$cred_file"
    echo -e "\e[34mUsername set: $username\e[0m"
    log_event "Username set: $username (hashed)"
    sleep 2
    banner
    echo -e "\e[33mSet password:\e[0m"
    read -p "Password: " pass1
    read -p "Retype password: " pass2
    [ "$pass1" = "$pass2" ] || {
        echo -e "\e[31mPasswords don't match!\e[0m"
        log_event "Password mismatch"
        sleep 2
        clear
        banner
        set_password
        return
    }
    sanitized_pass=$(sanitize_input "$pass1")
    [ -z "$sanitized_pass" ] || [ "$sanitized_pass" != "$pass1" ] && {
        echo -e "\e[31mInvalid password! Use letters, numbers, @, ., _, -.\e[0m"
        log_event "Invalid password"
        sleep 2
        set_password
        return
    }
    hashed_pass=$(echo -n "$pass1" | sha256sum | cut -d' ' -f1)
    echo "$hashed_pass" >> "$cred_file"
    log_event "Password set (hashed)"
    echo -e "\e[34mPassword set!\e[0m"
    sleep 2
    clear
    bash "$config_dir/login.sh"
}

# Change password
chg_pass () {
    banner
    echo -e "\e[33mEnter old password:\e[0m"
    read -s -p "" old_pass
    echo
    sanitized_pass=$(sanitize_input "$old_pass")
    [ -z "$sanitized_pass" ] || [ "$sanitized_pass" != "$old_pass" ] && {
        echo -e "\e[31mInvalid password! Use letters, numbers, @, ., _, -.\e[0m"
        log_event "Invalid old password"
        sleep 2
        banner
        chg_pass
        return
    }
    hashed_old_pass=$(echo -n "$old_pass" | sha256sum | cut -d' ' -f1)
    stored_pass=$(awk 'NR==2' "$cred_file")
    [ "$hashed_old_pass" = "$stored_pass" ] || {
        echo -e "\e[31mWrong password!\e[0m"
        log_event "Wrong old password"
        sleep 2
        banner
        menu
        start
        return
    }
    echo -e "\e[33mSet new password:\e[0m"
    read -p "Password: " pass1
    read -p "Retype password: " pass2
    [ "$pass1" = "$pass2" ] || {
        echo -e "\e[31mPasswords don't match!\e[0m"
        log_event "Password mismatch"
        sleep 2
        clear
        banner
        chg_pass
        return
    }
    sanitized_pass=$(sanitize_input "$pass1")
    [ -z "$sanitized_pass" ] || [ "$sanitized_pass" != "$pass1" ] && {
        echo -e "\e[31mInvalid password! Use letters, numbers, @, ., _, -.\e[0m"
        log_event "Invalid new password"
        sleep 2
        chg_pass
        return
    }
    hashed_pass=$(echo -n "$pass1" | sha256sum | cut -d' ' -f1)
    awk 'NR==2 {$0="'$hashed_pass'"} 1' "$cred_file" > tmp && mv tmp "$cred_file"
    echo -e "\e[34mPassword changed!\e[0m"
    log_event "Password changed"
    sleep 2
    clear
    bash "$config_dir/login.sh"
}

# Start
start () {
    menu
    echo -e "\e[33mChoose option:\e[0m"
    read -p "" opt
    case "$opt" in
        1) clear; banner; login ;;
        2) chg_pass ;;
        3) recover_account ;;
        4) command -v xdg-open &> /dev/null && {
               xdg-open https://instagram.com/raazzz136
               log_event "Opened Instagram"
           } || {
               echo -e "\e[31mxdg-open not found! Visit https://instagram.com/raazzz136\e[0m"
               log_event "xdg-open not found"
           }
           sleep 4
           banner
           menu
           start ;;
        *) log_event "Invalid option: $opt"
           banner
           menu
           start ;;
    esac
}

# Signal handling
trap 'echo -e "\n\e[31mCannot interrupt login!\e[0m"; banner; menu; start' INT TSTP

# Run
start
welcome() {
    clear

    local cols=$(stty size | awk '{print $2}')
    local msg="  Mr DK"
    local font="ANSI Shadow"

    # Top Border
    printf '=%.0s' $(seq 1 $cols)
    echo

    # Banner Name
    figlet -c -k -f "$font" "$msg" | lolcat || echo -e "\e[1;36m$msg\e[0m"
   printf "\e[1;32m                         .:.:.\e[0m\e[1;95m Contacts:- @THEDARKGEEKDC\e[0m \>
  #  echo
    printf "                              \e[101m\e[1;77m::  we Fuck the Fuckers  ::\e[0m\n"
    printf "                              \e[101m\e[1;77m::  We Love the Lovers!  ::\e[0m\n"
#info
#local cols=$(stty size | awk '{print $2}')
#printf '\e[1;96m'; printf '%*s\n' "$cols" "------[ System Info ]------" | sed "s/ /-/g"\e[0m" >
# Greeting (below banner)
    hour=$(date +"%H")
    if (( hour < 12 )); then
        echo -e "\n\e[1;96mGood Morning, Chaudhary Sa'ab!\e[0m"
    elif (( hour < 18 )); then
        echo -e "\n\e[1;92mGood Afternoon, Chaudhary Sa'ab!\e[0m"
    else
        echo -e "\n\e[1;95mGood Evening, Chaudhary Sa'ab!\e[0m"
    fi
echo

    # Time, System Info
#local cols=$(stty size | awk '{print $2}')
#printf '\e[1;96m'; printf '%*s\n' "$cols" "------[ System Info ]------" | sed "s/ /-/g"; echo >
    # Extract local IP (only 192.0.x.x, excluding 127.0.0.1)
    local ip=$(ifconfig 2>/dev/null | grep -oP 'inet \K[\d.]+' | grep -v '127.0.0.1' | grep -m >

    # Fetch Public IP using curl
    local public_ip=$(curl -s https://ipv4.icanhazip.com)


    echo -e "\e[1;93mTime      : \e[0m$(date +"%H:%M:%S")"
    echo -e "\e[1;93mUser      : \e[0m$(whoami) @ ${ip:-NA}"
    echo -e "\e[1;93mPublic IP : \e[0m${public_ip:-NA}"
    echo -e "\e[1;93mUptime    : \e[0m$(uptime -p)"
    echo -e "\e[1;93mShell     : \e[0m$SHELL"

    echo

    # Hacker Quote (at end) with 10 quotes in red color
    local quotes=(
      "Hack the planet!"
      "Code is poetry."
      "There is no system I can't hack."
      "Talk is cheap, show me the code."
      "We Love the Love, Not the Loop."
      "You can’t patch a hole in a system if you don’t know where it is."
      "The best way to predict the future is to invent it."
      "The greatest vulnerability is a lack of imagination."
      "Sudo is not a suggestion, it’s a command."
      "Security is a state of mind, not a product."
    )
    echo -e "\e[1;91mQuote     : ${quotes[$RANDOM % ${#quotes[@]}]}\e[0m"

    echo
    # Bottom Border
    printf '=%.0s' $(seq 1 $cols)
    echo -e "\n"
}
welcome
