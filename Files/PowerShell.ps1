# Define variables
$logFile = "C:\ID609_OE1\robocopy_log.txt"
$emailTo = "your_email@example.com"
$smtpServer = "*"
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

# Function to create a Windows event log entry
function New-EventLogEntry ($message, $eventID, $entryType) {
    Create-EventSource
    Write-EventLog -LogName Application -Source "RobocopyMonitor" -EventId $eventID -Message $message -EntryType $entryType
}

# Function to create the event source if it doesn't exist
function Create-EventSource {
    if (-not (Get-EventLog -LogName Application -Source "RobocopyMonitor" -ErrorAction SilentlyContinue)) {
        New-EventLog -LogName Application -Source "RobocopyMonitor"
    }
}

# Main loop
$processedEntries = @{}
while ($true) {
    try {
        $logEntries = Get-Content $logFile -ErrorAction Stop
    } catch {
        New-EventLogEntry -message "Failed to read log file: $_" -eventID 1001 -entryType Error
        Start-Sleep -Seconds 60
        continue
    }

    foreach ($entry in $logEntries) {
        if (-not $processedEntries.ContainsKey($entry)) {
            $processedEntries[$entry] = $true

            if ($entry -match "New\s+File" -or $entry -match "Deleted") {
                 $action = if ($entry -match "New\s+File") { "added" } else { "deleted" }
                 $file = ($entry -split '\s+', 4)[-1]


                $subject = "File ${action}: $file"
                $body = "The following file has been ${action}:`n`n$entry"

                try {
                    Send-EmailNotification -subject $subject -body $body
                    New-EventLogEntry -message $subject -eventID 1000 -entryType Information
                } catch {
                    New-EventLogEntry -message "Failed to send email notification: $_" -eventID 1002 -entryType Error
                }
            }
            
        }
    }

    Start-Sleep -Seconds 60
}
