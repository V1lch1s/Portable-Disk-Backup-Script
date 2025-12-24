# Portable Disk Backup Script 💽
### PowerShell module for backing up a removable Disk Drive
<img src="./assets/powershell.png" alt="PowerShell Icon" width="100" />

<img src="./assets/plus.png" alt="Plus Icon" width="50" />

<img src="./assets/HDD.jpeg" alt="Hard Disk Drive" width="100" />

## How to use?
### 1. Change the Origin and destination disk letters in the script
### 2. Write the route to your installation of SysInternalsSuite\du.exe
<img src="./assets/Steps1-2.jpg" alt="PowerShell Icon" width="600" />

### 3. List the folders in the Origin Routes
<img src="./assets/Step3.jpg" alt="Step 3" width="600" />

### 4. Save the modified script 💾
### 5. Run inside the Power Shell Console with Administrator's privileges
<img src="./assets/PS1Exec.jpg" alt="PowerShell Script Execution" width="600" />

# ⚠️ Note
### I assume that you just want to copy all the files and folders from your Portable disk, and Your disk format is GPT with the Windows' default file system NTFS.

# ⚠ Requirement
### This script needs SysInternalsSuite installed in your PC to work properly.
Take it from the official site: https://learn.microsoft.com/es-es/sysinternals/downloads/sysinternals-suite

### Then Add the installation path to the environmental variables (Windows).
Start > Settings > System > About > Advanced System Settings (Right burguer menu) > Environmental Variables > System Variables > Path > Add your installation path "Z:\SysinternalsSuite"

### Confirm it works in Power Shell
<img src="./assets/DU.jpg" alt="Disk Usage from SysinternalsSuite" width="500" />
