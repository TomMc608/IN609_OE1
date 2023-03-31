# Define variables
$sourceDir = "C:\Windows\Files"
$destinationDir = "C:\Windows\Files_Backup"
$logFile = "C:\IN609_OE1\robocopy_log.txt"

# Set up Robocopy options
$robocopyOptions = "/MIR /TEE /ETA /LOG+:`"$logFile`" /NP"

# Run Robocopy in a separate terminal window and recheck for file system changes
Start-Process -FilePath "robocopy.exe" -ArgumentList "`"$sourceDir`" `"$destinationDir`" $robocopyOptions /R:0 /W:0 /MON:1" -WindowStyle Hidden
