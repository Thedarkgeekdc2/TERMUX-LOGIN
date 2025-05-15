#!/data/data/com.termux/files/usr/bin/bash

# Setup script for TERMUX-LOGIN with OTP-based recovery
# Uses GitHub Secrets for Gmail SMTP, auto-installs dependencies, deletes existing config files
# Stores files in /data/data/com.termux/files/home/.config/.termux-login
# Configures /data/data/com.termux/files/usr/etc/zshrc, deletes $HOME/TERMUX-LOGIN
# Green/red design

# Define paths
config_dir="/data/data/com.termux/files/home/.config/.termux-login"
cred_file="$config_dir/crdintals"
msmtp_conf="$config_dir/.msmtprc"
setup_log="$config_dir/setup.log"
zshrc_file="/data/data/com.termux/files/usr/etc/zshrc"

# Logging function
log_event () {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$setup_log"
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
        figlet -c -k "SETUP" | lolcat -f -t -S 28
    else
        echo -e "\e[32m===== TERMUX-LOGIN SETUP =====\e[0m"
    fi
    echo -e "\e[32m~THEDARKGEEKDC©2025-26\e[0m"
    echo
}

# Install dependencies
check_dependencies () {
    local pkgs=("zsh" "figlet" "lolcat" "espeak" "openssl" "msmtp" "shuf")
    local missing=()
    for pkg in "${pkgs[@]}"; do
        command -v "$pkg" &> /dev/null || missing+=("$pkg")
    done
    if [ ${#missing[@]} -gt 0 ]; then
        check_internet
        echo -e "\e[32mInstalling: ${missing[*]}\e[0m"
        log_event "Installing: ${missing[*]}"
        pkg install "${missing[@]}" -y || {
            echo -e "\e[31mFailed to install: ${missing[*]}\e[0m"
            log_event "Failed to install: ${missing[*]}"
            exit 1
        }
    fi
    log_event "Dependencies verified"
}

# Send OTP
send_otp () {
    local email="$1" context="$2"
    otp=$(shuf -i 100000-999999 -n 1) || {
        echo -e "\e[31mOTP generation failed.\e[0m"
        log_event "OTP generation failed"
        return 1
    }
    echo -e "\e[32mSending OTP to $email...\e[0m"
    {
        echo "Subject: Termux-Login $context"
        echo "To: $email"
        echo "From: $smtp_user"
        echo ""
        echo "Your OTP is: $otp"
        echo "~THEDARKGEEKDC©2025-26"
    } | msmtp --file="$msmtp_conf" "$email" && {
        echo -e "\e[32mOTP sent! Check email (including spam).\e[0m"
        log_event "OTP sent to $email for $context"
        return 0
    }
    echo -e "\e[31mFailed to send OTP. Check SMTP/internet.\e[0m"
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
        echo -e "\e[32mOTP verified!\e[0m"
        log_event "OTP verified"
        return 0
    }
    echo -e "\e[31mIncorrect OTP!\e[0m"
    log_event "Incorrect OTP"
    return 1
}

# Set email with GitHub Secrets
set_email () {
    echo -e "\e[33mEnter recovery email:\e[0m"
    read -p "Email: " user_email
    sanitized_email=$(sanitize_input "$user_email")
    [ -z "$sanitized_email" ] || [ "$sanitized_email" != "$user_email" ] && {
        echo -e "\e[31mInvalid email! Use letters, numbers, @, ., _, -.\e[0m"
        log_event "Invalid email: $user_email"
        sleep 2
        clear
        banner
        set_email
        return
    }
    smtp_user="${GMAIL_USER}"
    smtp_pass="${GMAIL_APP_PASSWORD}"
    [ -z "$smtp_user" ] || [ -z "$smtp_pass" ] && {
        echo -e "\e[31mError: GMAIL_USER and GMAIL_APP_PASSWORD must be set.\e[0m"
        log_event "GMAIL_USER or GMAIL_APP_PASSWORD unset"
        exit 1
    }
    cat > "$msmtp_conf" << EOF
account default
host smtp.gmail.com
port 587
from $smtp_user
auth on
user $smtp_user
password $smtp_pass
tls on
tls_trust_file /data/data/com.termux/files/usr/etc/tls/cert.pem
logfile $config_dir/msmtp.log
EOF
    chmod 600 "$msmtp_conf"
    log_event "SMTP configured"
    check_internet
    send_otp "$user_email" "Setup" && {
        echo -e "\e[33mEnter 6-digit OTP:\e[0m"
        read -p "" input_otp
        verify_otp "$input_otp" && {
            hashed_email=$(echo -n "$user_email" | sha256sum | cut -d' ' -f1)
            echo "$hashed_email" >> "$cred_file"
            echo -e "\e[32mEmail set for recovery!\e[0m"
            log_event "Email set: $user_email (hashed)"
            return
        }
    }
    sleep 2
    clear
    banner
    set_email
}

# Set username
set_username () {
    echo -e "\e[33mSet username:\e[0m"
    read -p "Username: " username
    sanitized_username=$(sanitize_input "$username")
    [ -z "$sanitized_username" ] || [ "$sanitized_username" != "$username" ] && {
        echo -e "\e[31mInvalid username! Use letters, numbers, @, ., _, -.\e[0m"
        log_event "Invalid username: $username"
        sleep 2
        clear
        banner
        set_username
        return
    }
    hashed_username=$(echo -n "$username" | sha256sum | cut -d' ' -f1)
    echo "$hashed_username" > "$cred_file"
    echo -e "\e[32mUsername set: $username\e[0m"
    log_event "Username set: $username (hashed)"
    sleep 2
}

# Set password
set_password () {
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
        clear
        banner
        set_username
        set_password
        return
    }
    hashed_pass=$(echo -n "$pass1" | sha256sum | cut -d' ' -f1)
    echo "$hashed_pass" >> "$cred_file"
    log_event "Password set (hashed)"
    set_email
}

# Main setup
setup () {
    banner
    echo -e "\e[32mSetting up TERMUX-LOGIN...\e[0m"
    log_event "Setup started"

    # Delete existing config files
    if [ -d "$config_dir" ]; then
        echo -e "\e[33mExisting files in $config_dir:\e[0m"
        ls -l "$config_dir" | while read -r line; do
            echo -e "\e[33m$line\e[0m"
            log_event "Found: $line"
        done
        rm -rf "$config_dir"/*
        log_event "Deleted existing files in $config_dir"
    fi

    # Create config directory
    mkdir -p "$config_dir" || {
        echo -e "\e[31mFailed to create $config_dir!\e[0m"
        log_event "Failed to create $config_dir"
        exit 1
    }
    chmod 700 "$config_dir"
    log_event "Created $config_dir"

    # Install dependencies
    check_dependencies

    # Set credentials
    set_username
    set_password

    # Copy scripts
    [ -f "$HOME/TERMUX-LOGIN/login.sh" ] && cp "$HOME/TERMUX-LOGIN/login.sh" "$config_dir/" || {
        echo -e "\e[31mlogin.sh not found!\e[0m"
        log_event "login.sh not found"
        exit 1
    }
    chmod 700 "$config_dir/login.sh"
    log_event "Copied login.sh"
    cp "$0" "$config_dir/setup.sh" || {
        echo -e "\e[31mFailed to copy setup.sh!\e[0m"
        log_event "Failed to copy setup.sh"
        exit 1
    }
    chmod 700 "$config_dir/setup.sh"
    log_event "Copied setup.sh"

    # Delete TERMUX-LOGIN folder
    if [ -d "$HOME/TERMUX-LOGIN" ]; then
        rm -rf "$HOME/TERMUX-LOGIN"/*
        rmdir "$HOME/TERMUX-LOGIN" && log_event "Deleted TERMUX-LOGIN" || {
            echo -e "\e[31mWarning: Failed to delete TERMUX-LOGIN.\e[0m"
            log_event "Failed to delete TERMUX-LOGIN"
        }
    fi

    # Update zshrc
    if ! grep -Fx "bash $config_dir/login.sh" "$zshrc_file" > /dev/null; then
        [ -w "$zshrc_file" ] && {
            echo "bash $config_dir/login.sh" >> "$zshrc_file"
            log_event "Updated $zshrc_file"
        } || {
            echo -e "\e[31mCannot write to $zshrc_file. Add 'bash $config_dir/login.sh' manually.\e[0m"
            log_event "Failed to update $zshrc_file"
        }
    fi

    echo -e "\e[32mSetup complete! Secure your email.\e[0m"
    log_event "Setup complete"
    sleep 2
    clear
    bash "$config_dir/login.sh"
}

# Signal handling
trap 'echo -e "\n\e[31mCannot interrupt setup!\e[0m"; banner; setup' INT TSTP

# Non-interactive mode for GitHub Actions
if [ "$NON_INTERACTIVE" = "true" ]; then
    username="${SETUP_USERNAME:-testuser}"
    password="${SETUP_PASSWORD:-testpass}"
    user_email="${SETUP_EMAIL:-test@example.com}"
    input_otp="${SETUP_OTP:-123456}"
    hashed_username=$(echo -n "$username" | sha256sum | cut -d' ' -f1)
    hashed_pass=$(echo -n "$password" | sha256sum | cut -d' ' -f1)
    hashed_email=$(echo -n "$user_email" | sha256sum | cut -d' ' -f1)
    mkdir -p "$config_dir" || exit 1
    chmod 700 "$config_dir"
    echo "$hashed_username" > "$cred_file"
    echo "$hashed_pass" >> "$cred_file"
    echo "$hashed_email" >> "$cred_file"
    smtp_user="${GMAIL_USER}"
    smtp_pass="${GMAIL_APP_PASSWORD}"
    [ -z "$smtp_user" ] || [ -z "$smtp_pass" ] && {
        echo -e "\e[31mError: GMAIL_USER and GMAIL_APP_PASSWORD must be set.\e[0m"
        log_event "GMAIL_USER or GMAIL_APP_PASSWORD unset"
        exit 1
    }
    cat > "$msmtp_conf" << EOF
account default
host smtp.gmail.com
port 587
from $smtp_user
auth on
user $smtp_user
password $smtp_pass
tls on
tls_trust_file /data/data/com.termux/files/usr/etc/tls/cert.pem
logfile $config_dir/msmtp.log
EOF
    chmod 600 "$msmtp_conf"
    log_event "Non-interactive setup complete"
    exit 0
fi

# Run setup
setup
