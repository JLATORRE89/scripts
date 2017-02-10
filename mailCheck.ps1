## Basic e-mail test Script
## Tested in Powershell version 5.1 Build 14393 Revision 693
Try 
{
    ## Gets date, reads in mail information, port number and test information; sends e-mail.
    $date = Get-Date
    $From = Read-Host "Who is  this e-mail coming from?"
    $To = Read-Host "Who is this e-mail going to?"
    $mailServer = Read-Host "What mail server do you want to test?"
    $serverPort = Read-Host "What port number?"
    $username = Read-Host "Username for mail server"
    ## Read password as secrue string; just in case.
    $password = Read-Host "Password for username:" -AsSecureString
    $subject = "Test Mail from $From"
    $body = "This is a test e-mail sent at: $date"
    ## Use .net smtp library to process request to server.
    $smtp = New-Object System.Net.Mail.SmtpClient($mailServer, $serverPort)

    ## Use SSL for secure authentication.
    $smtp.EnableSsl = $true
    $smtp.Credentials = New-Object System.Net.NetworkCredential($username, $password)
    $smtp.Send($From, $To, $subject, $body)
    Write-Host "Mail Sent."
} 
catch [Exception]
{
    ## Dumps raw error message to console.
    Write-Host -ForegroundColor Red "Error sending mail, see below:"
    echo $_
}