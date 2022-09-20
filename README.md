# <span style="color:green">**Backup and Restore Configuration Files On Cisco ASA Firewall.**</span>
#### <span style="color:white">**You can use a script to back up and restore the configuration files on your ASA, including all extensions that you import via the import webvpn CLI, the CSD configuration XML files, and the DAP configuration XML file. For security reasons, we do not recommend that you perform automated backups of digital keys and certificates or the local CA key.**</span>
#### <span style="color:white">**This section provides instructions for doing so and includes a sample script that you can use as is or modify as your environment requires. The sample script is specific to a Linux system. To use it for a Microsoft Windows system, you need to modify it using the logic of the sample.**</span>
#### <span style="color:white">**The existing CLI lets you back up and restore individual files using the copy, export, and import commands. It does not, however, have a facility that lets you back up all ASA configuration files in one operation. Running the script facilitates the use of multiple CLIs.**</span>

### <span style="color:yellow">**Prerequisites :**</span>

#### <span style="color:white">**To use a script to back up and restore an ASA configuration, first perform the following tasks:**</span>
```
- Install Perl with an Expect module.
- Install an SSH client that can reach the ASA.
- Install a TFTP server to send files from the ASA to the backup site.
```
#### <span style="color:white">**Another option is to use a commercially available tool. You can put the logic of this script into such a tool.**</span>

### <span style="color:yellow">**Running the Script :**</span>


#### <span style="color:white">**The system prompts you for values for each option. Alternatively, you can enter values for the options when you enter the Perl scriptname command before you press Enter. Either way, the script requires that you enter a value for each option.**</span>
#### <span style="color:white">**The script starts running, printing out the commands that it issues, which provides you with a record of the CLIs. You can use these CLIs for a later restore, which is particularly useful if you want to restore only one or two files.</span>
#### <span style="color:white">**Function: Backup/restore configuration/extensions to/from a TFTP server.**</span>
#### <span style="color:white">**Description: The objective of this script is to show how to back up configurations/extensions before the backup/restore command is developed.**</span>
#### <span style="color:white">**It currently backs up the running configuration, all extensions imported via “import webvpn” command, the CSD configuration XML file, and the DAP configuration XML file. Requirements Perl with Expect, SSH to the ASA, and a TFTP server.**</span>


```
$ sudo ./backup-asa.sh -option option_value

 -h: ASA hostname or IP address
 -u: User name to log in via SSH
 -w: Password to log in via SSH
 -e: The Enable password on the security appliance
 -p: Global configuration mode prompt
 -s: Host name or IP address of the TFTP server to store the configurations
 -r: Restore with an argument that specifies the file name. This file is produced during backup.
```
#### <span style="color:white">**If you don't enter an option, the script will prompt for it prior to backup. Make sure that you can SSH to the ASA.**</span>

[![License](https://img.shields.io/badge/License-MIT-blue)](#license "Go to license section") 
