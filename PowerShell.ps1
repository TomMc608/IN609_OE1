# Define variables
$sourceDir = "C:\Users\Tom\Desktop\IN609_OE1"
$destinationDir = ".\Files_Backup"
$logFile = ".\robocopy_log.txt"
$emailTo = "Tommciver@hotmail.com"
$smtpServer = "127.0.0.1"
$smtpPort = 25
$emailFrom = "noreply@example.com"

# Function to send an email notification
function Send-EmailNotification ($subject, $body) {
    $mailMessage = New-Object System.Net.Mail.MailMessage
    $mailMessage.From = $emailFrom
    $mailMessage.To.Add($emailTo)
    $mailMessage.Subject = $subject
    $mailMessage.Body = $body

    $smtpClient = New-Object System.Net.Mail.SmtpClient($smtpServer, $smtpPort)
    $smtpClient.Send($mailMessage)
}

# Function to run Robocopy and update the log file
function Run-Robocopy {
    & robocopy $sourceDir $destinationDir /MIR /LOG+:$logFile
}

# Run Robocopy once to create the log file and sync the directories
Run-Robocopy

# Start a file watcher loop to monitor file system changes
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $sourceDir
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true

# Register events
$changedEvent = Register-ObjectEvent -InputObject $watcher -EventName Changed -Action {
    Run-Robocopy
}

$createdEvent = Register-ObjectEvent -InputObject $watcher -EventName Created -Action {
    Run-Robocopy
}

$deletedEvent = Register-ObjectEvent -InputObject $watcher -EventName Deleted -Action {
    Run-Robocopy
}

$renamedEvent = Register-ObjectEvent -InputObject $watcher -EventName Renamed -Action {
    Run-Robocopy
}

# Main loop
$processedEntries = @{}
while ($true) {
    try {
        $logEntries = Get-Content $logFile -ErrorAction Stop
    } catch {
        Start-Sleep -Seconds 60
        continue
    }

    foreach ($entry in $logEntries) {
        if (-not $processedEntries.ContainsKey($entry)) {
            $processedEntries[$entry] = $true

            if ($entry -match "New\s+File" -or $entry -match "Deleted") {
                $action = if ($entry -match "New\s+File") { "added" } else { "deleted" }
                $file = ($entry -split '\s+', 4)[-1]
                Write-Host "Processing entry: $entry"

                $subject = "File ${action}: $file"
                $body = "The following file has been ${action}:`n`n$entry"

                try {
                    Send-EmailNotification -subject $subject -body $body
                } catch {
                    Write-Host "Error sending email: $_"
                }
            }
        }
    }

    Start-Sleep -Seconds 10
}

# Clean up
Unregister-Event -SourceIdentifier $changedEvent.Name
Unregister-Event -SourceIdentifier $createdEvent.Name
Unregister-Event -SourceIdentifier $deletedEvent.Name
Unregister-Event -SourceIdentifier $renamedEvent.Name
