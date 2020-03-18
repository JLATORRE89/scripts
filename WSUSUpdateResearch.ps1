# Get Windows Update Version
Get-WUAVersion
# Check for Pending reboot
Get-WUIsPendingReboot
# Last install date
Get-WULastInstallationDate
# Last successful Scan Date
Get-WULastScanSuccessDate
# Start a scan of updates against the current system
Start-WUScan 
# Install a specific KB.
Install-WUUpdates -AsJob KB4537572

# Get supportedmodule commandlets
Get-Command -Module WindowsUpdateProvider

# https://docs.microsoft.com/en-us/windows/win32/wua_sdk/portal-client
# Get update service object information
$ServiceManager = (New-Object -com "Microsoft.Update.ServiceManager")
$ServiceManager.Services