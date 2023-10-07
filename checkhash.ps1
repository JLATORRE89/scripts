# example to check a hash in Powershell
$testHash = Get-FileHash .\xcp-ng-8.2.1.iso
$hash = "93853aba9a71900fe43fd5a0082e2af6ab89acd14168f058ffc89d311690a412"
if ($testHash.Hash -like $hash) { write-host "good hash" }
