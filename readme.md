# PowerShell Robocopy File Sync and Change Notification System

This system uses PowerShell, Robocopy, and the FileSystemWatcher to continuously sync a source directory to a backup directory and notify the user of any changes made to the file system. This README file provides instructions on how to set up and run the system.

## Prerequisites

Before running the PowerShell script, you will need to:

1. Install Java on your computer.
2. Run the fakeSMTP-2.0.jar file to start the fake SMTP server. This will allow emails to be sent from the PowerShell script.
3. Create a 'Files' folder and a 'Files_Backup' folder in the PowerShell script's directory. The 'Files' folder will be the source directory that is continuously synced to the 'Files_Backup' folder.
4. Create a 'file_modifier.bat' file in the 'Files' folder. This file should contain the following command:



## Running the Script

To run the PowerShell script:

1. Open PowerShell as an administrator.
2. Navigate to the directory containing the PowerShell script.
3. Run the following command to set the script execution policy:


This allows PowerShell scripts to be run on the computer.
4. Run the PowerShell script using the following command:

This starts the PowerShell script and begins syncing the 'Files' folder to the 'Files_Backup' folder.


## Note

If you receive an error message stating that the execution of scripts is disabled on your system, you will need to change the execution policy to run the PowerShell script. 

If you encounter issues with the email notification system, make sure that the SMTP server settings in the PowerShell script are correct and that the fake SMTP server is running. 


# link to repo 

https://github.com/TomMc608/IN609_OE1


