# TERMUX-LOGIN

## Introduction

TERMUX-LOGIN is a custom login script designed for the Termux Android terminal emulator. Its primary purpose is to enhance the security of your Termux environment and provide a personalized startup experience. This script was created by @THEDARKGEEKDC.

## Features

*   **Secure Login:** Implements login with a username and password.
*   **Password Hashing:** Protects passwords using SHA256 hashing algorithm.
*   **OTP Recovery:** Offers One-Time Password (OTP) based account recovery via email (configured for Gmail SMTP).
*   **Customizable Welcome Banner:** Displays a dynamic welcome message including system information (time, user, IP address, uptime, shell) and a random hacker quote.
*   **Input Sanitization:** Includes basic input sanitization to prevent unintended script behavior.
*   **Login Security:** Features login attempt limits and temporary account lockout after multiple failed attempts.
*   **Event Logging:** Logs important events like login attempts, OTP requests, and errors to `~/.config/.termux-login/login.log` and `~/.config/.termux-login/setup.log`.
*   **Password Management:** Allows users to change their password securely after logging in.
*   **Author Contact:** Provides a direct link to contact the author (@THEDARKGEEKDC).

## How it Works

The TERMUX-LOGIN system consists of two main scripts: `setup.sh` and `login.sh`.

*   **`setup.sh` (Setup Script):**
    *   **Dependency Installation:** Automatically installs necessary packages: `zsh`, `figlet`, `lolcat`, `espeak`, `openssl`, `msmtp`, and `shuf`.
    *   **User Configuration:** Prompts the user to set up:
        *   A username for login.
        *   A password (which is then hashed using SHA256).
        *   A Gmail address and a 16-digit App Password. This email address is used for sending OTPs (e.g., for setup verification) and also serves as the designated email for receiving account recovery OTPs.
    *   **Storage:** Securely stores the hashed user credentials (including the hashed Gmail address for recovery) and the SMTP configuration in the `~/.config/.termux-login/` directory. The primary credentials file is `crdintals`, and SMTP settings are in `.msmtprc`.
    *   **Script Deployment:** Copies the `login.sh` script to the `~/.config/.termux-login/` directory.
    *   **Startup Integration:** Modifies the `.zshrc` file to automatically execute `login.sh` every time a new Termux session starts.
    *   **Cleanup:** Removes the cloned `TERMUX-LOGIN` repository folder from the home directory after setup.

*   **`login.sh` (Login Script):**
    *   **Welcome Banner:** On execution, it first displays a dynamic welcome banner. This banner includes:
        *   A greeting ("Mr DK").
        *   Current time.
        *   Username and local IP address.
        *   Public IP address (fetched using `curl`).
        *   System uptime.
        *   Current shell.
        *   A randomly selected hacker quote.
    *   **Main Menu:** Presents the user with the following options:
        1.  **Login:** Prompts for username and password. Compares the SHA256 hash of the input with the stored hash. Allows a limited number of attempts before a temporary lockout.
        2.  **Change Password:** Allows the user to change their password after successfully entering their old password.
        3.  **Recover Account:** Initiates the account recovery process. It asks for the Gmail address registered during setup and sends an OTP to it. Upon successful OTP verification, the user can set a new password.
        4.  **Contact @THEDARKGEEKDC:** Opens the author's Linktree page (`https://linktr.ee/thedarkgeekdc`) using `xdg-open`.
    *   **Security:**
        *   Uses SHA256 for hashing passwords.
        *   Sanitizes user inputs to prevent basic injection attacks.
        *   Traps `Ctrl+C` (INT) and `Ctrl+Z` (TSTP) signals to prevent interruption of the login/setup process.
    *   **Logging:** Records login attempts, OTP actions, and errors in `~/.config/.termux-login/login.log`.

## Prerequisites

*   **Termux Application:** Must be installed on an Android device.
*   **Internet Connection:** Required for:
    *   Downloading and installing dependencies during setup (`setup.sh`).
    *   Sending and receiving OTPs for account recovery (`login.sh` and `setup.sh`).
    *   Fetching the public IP address for the welcome banner (`login.sh`).
*   **Required Packages:** The `setup.sh` script will attempt to automatically install the following. However, if issues arise, you might need to install them manually using `pkg install <package-name>`:
    *   `zsh`
    *   `figlet`
    *   `lolcat`
    *   `openssl` (provides `sha256sum` used for hashing)
    *   `msmtp` (for sending emails/OTPs)
    *   `shuf` (for OTP generation)
    *   `curl` (for fetching public IP in `login.sh`)
    *   `git` (for cloning the repository)
    *   `coreutils` (provides various essential utilities like `stty`, `awk`, `date`, `whoami`, `uptime`, `mkdir`, `rm`, `mv`, `cp`, `grep`, `cut`, `echo`, `sleep`, `cat`, `chmod` which are used extensively. Usually pre-installed).

## Installation

1.  **Update and Upgrade Packages:**
    Open Termux and ensure your package lists and installed packages are up to date:
    ```bash
    pkg update -y && pkg upgrade -y
    ```

2.  **Install Git and Zsh:**
    The setup script requires `zsh`. `git` is needed to clone the repository.
    ```bash
    pkg install git zsh -y
    ```

3.  **Clone the Repository:**
    Clone the TERMUX-LOGIN repository to your Termux home directory.
    ```bash
    git clone https://github.com/Thedarkgeekdc2/TERMUX-LOGIN
    ```

4.  **Navigate into the Directory:**
    Change your current directory to the cloned folder.
    ```bash
    cd TERMUX-LOGIN
    ```

5.  **Run the Setup Script:**
    Execute the setup script to begin the installation and configuration process.
    ```bash
    bash setup.sh
    ```

6.  **Follow On-Screen Prompts:**
    The `setup.sh` script will guide you through:
    *   Installing necessary dependencies.
    *   Setting your desired username and password.
    *   Configuring your Gmail account (email address and App Password). This Gmail address will be used for sending OTPs and for account recovery.

7.  **Restart Termux:**
    After the setup is complete, the script will automatically try to start the login interface. For the changes to `.zshrc` to take full effect and ensure the login script runs every time you open Termux, **it's recommended to restart Termux.** You can do this by typing `exit` and pressing Enter, then closing and reopening the Termux app.

## Usage

Once TERMUX-LOGIN is installed, it will run automatically every time you start a new Termux session, presenting you with a menu.

*   **Logging In:**
    1.  At the menu, select option `1` (Login).
    2.  Enter your username when prompted.
    3.  Enter your password when prompted.
    4.  If successful, you will see a welcome banner and gain access to the shell.
    5.  If unsuccessful, you will be notified, and after multiple failed attempts, your account will be temporarily locked.

*   **Changing Password:**
    1.  At the menu, select option `2` (Change Password).
    2.  Enter your current (old) password.
    3.  If correct, you will be prompted to enter a new password.
    4.  Re-enter the new password to confirm.
    5.  Your password will be updated.

*   **Recovering Account:**
    1.  At the menu, select option `3` (Recover Account).
    2.  Enter the Gmail address you configured during setup.
    3.  An OTP (One-Time Password) will be sent to this Gmail address (check spam/junk folders too).
    4.  Enter the 6-digit OTP received in your email.
    5.  If the OTP is correct, you will be prompted to set a new username and password for your account.

*   **Contacting Author:**
    1.  At the menu, select option `4` (Contact @THEDARKGEEKDC).
    2.  This will attempt to open the author's Linktree page (`https://linktr.ee/thedarkgeekdc`) in your default browser using `xdg-open`.

## Configuration

The primary configuration of TERMUX-LOGIN is performed during the initial run of the `setup.sh` script. This includes:

*   **User Credentials:** Setting your username and password.
*   **Gmail Address for OTP & Recovery:** You will configure a Gmail address and an App Password. This Gmail address serves two purposes:
    1.  It's used by `msmtp` to send OTPs (e.g., for verifying the email during setup).
    2.  It's the designated email address where you will receive OTPs if you need to recover your account.
*   **SMTP Configuration for OTP Sending:**
    *   You will be prompted to enter your Gmail address and a **Gmail App Password**.
    *   **Important:** For sending OTPs via Gmail, you **must** generate an "App Password" from your Google Account settings. This is a 16-digit password that grants specific access to your Google Account. It's more secure than using your regular password. Search online for "Google App Passwords" for instructions on how to generate one.
    *   These SMTP settings are stored in `~/.config/.termux-login/.msmtprc`. This file is configured for Gmail's SMTP server (`smtp.gmail.com`) on port `587` with TLS encryption.
    *   The `msmtp.log` file in the same directory logs email sending status.

**Configuration Files:** All configuration files are stored within the `~/.config/.termux-login/` directory:
*   `crdintals`: Stores the hashed username, password, and the hashed Gmail address used for recovery.
*   `.msmtprc`: Contains SMTP settings for OTP emails (using the configured Gmail address as the sender).
*   `login.log`: Records `login.sh` script events.
*   `setup.log`: Records `setup.sh` script events.
*   `msmtp.log`: Logs email sending activities by `msmtp`.

**Modifying Configuration:**
*   To change your login password, use the "Change Password" option from the login menu.
*   To change your Gmail address (used for sending/receiving OTPs) or SMTP settings:
    *   Carefully edit the `.msmtprc` (for SMTP sender settings) and `crdintals` (for the hashed recovery email) files directly. This is recommended for advanced users.
    *   Alternatively, re-run the `setup.sh` script. **Warning:** Re-running setup will delete your existing configuration, requiring you to set up everything again, including username, password, and the Gmail configuration.

## Troubleshooting

*   **OTP Not Received:**
    *   **Check Internet Connection:** Ensure your Android device has an active internet connection.
    *   **Check Spam/Junk Folder:** The OTP email might have been filtered into your spam or junk mail folder of the Gmail account you configured.
    *   **Verify Gmail Address:** Ensure the Gmail address entered during setup was correct and is the one you are checking.
    *   **Gmail App Password:** Double-check that you have generated and correctly entered the 16-digit Gmail App Password during setup. Your regular Gmail password will not work.
    *   **Check `msmtp.log`:** The `~/.config/.termux-login/msmtp.log` file may contain error messages from `msmtp` that can help diagnose email sending issues.
    *   **Less Secure App Access (Not Recommended):** Using an App Password is the **recommended and more secure method**. While some Google Accounts might allow "Less Secure App Access," this is not advisable. TERMUX-LOGIN is designed for use with App Passwords.

*   **`xdg-open` Not Found Error:**
    *   This error appears if the `xdg-open` utility (used to open web links) is not installed.
    *   The script logs this. To enable the "Contact @THEDARKGEEKDC" feature (option 4 in `login.sh`), install `xdg-utils`:
        ```bash
        pkg install xdg-utils
        ```

*   **Invalid Credentials or Password Mismatch:**
    *   Carefully re-enter your username and password, paying attention to case sensitivity.
    *   If you have forgotten your password, use the "Recover Account" (Option 3) feature.

*   **Errors During `setup.sh`:**
    *   **Dependency Installation Failure:** Ensure you have a stable internet connection. If specific packages fail to install, try installing them manually (e.g., `pkg install msmtp`).
    *   **Permission Issues:** Ensure Termux has the necessary storage permissions. You can usually grant this from your Android device's app settings for Termux.
    *   If setup is interrupted, you might need to remove the `~/.config/.termux-login` directory and the `TERMUX-LOGIN` repository folder and run `bash setup.sh` again.

*   **"Cannot interrupt login!" or "Cannot interrupt setup!" Message:**
    *   This is an **intended security feature.** The script traps `Ctrl+C` (SIGINT) and `Ctrl+Z` (SIGTSTP) to prevent users from easily bypassing the login or setup process. You must complete the prompts or, if stuck, close and reopen the Termux session.

*   **Figlet/Lolcat Banner Not Appearing Correctly:**
    *   `setup.sh` installs `figlet` and `lolcat`. If missing, the script uses a basic banner. Try reinstalling:
        ```bash
        pkg install figlet lolcat
        ```

*   **Login Script Not Running on Termux Start:**
    *   `setup.sh` adds `bash ~/.config/.termux-login/login.sh` to your `~/.zshrc` file.
    *   Confirm this line is present in `~/.zshrc`. If not, add it manually.
    *   Ensure Zsh is your default Termux shell. If using Bash, add the line to `~/.bashrc` (though the script is designed for Zsh).

## Contributing

Contributions to TERMUX-LOGIN are welcome! If you have ideas for improvements, new features, or bug fixes, please feel free to:

1.  **Fork the repository** on GitHub.
2.  **Create a new branch** for your changes (e.g., `git checkout -b feature/your-feature-name`).
3.  **Make your changes** and commit them with clear, descriptive messages.
4.  **Push your branch** to your forked repository.
5.  **Submit a pull request** to the main TERMUX-LOGIN repository (`Thedarkgeekdc2/TERMUX-LOGIN`).

You can also report issues or suggest features by opening an issue on the GitHub repository page.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## Author/Contact

*   **Author:** THEDARKGEEKDC
*   **GitHub Profile:** [https://github.com/Thedarkgeekdc2](https://github.com/Thedarkgeekdc2)
*   **Contact (Linktree):** [https://linktr.ee/thedarkgeekdc](https://linktr.ee/thedarkgeekdc)
