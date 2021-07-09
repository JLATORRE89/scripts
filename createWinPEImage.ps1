# Creates a WinPE image to be used for booting a broken system or running anti-malware tools.
# Requires powershell 5.1 or greater. Items marked with TODO require implementation. Items marked with FIX are broken.
# Date Written: 2021/07/09

# Mount Image for changes
function MountImage() {
    Write-Host "Mounting WinPE Image..."
    Dism /Mount-Image /ImageFile:"C:\WinPE_amd64\media\sources\boot.wim" /index:1 /MountDir:"C:\WinPE_amd64\mount"
}

#TODO: Install drivers from Network Share
function InstallDrivers() {
    Write-Host "Install Drivers Function not implemented."
    # Copy Driver Files, must be an INF file.
    # Drivers can be found using device manager from another Computer. The path is usually: C:\Windows\System32\DriverStore\FileRepository.
    # It is best to copy these files from an offline system. Systems running in HEADLESS mode only need Network and Storage Drivers.
    # Use Robocopy to create backup of drivers not in use.
    #robocopy C:\Windows\System32\DriverStore\FileRepository C:\Users\Public\Documents\drivers /b
    # Create Compressed Archive to ship drivers to remote host
    #Compress-Archive -LiteralPath C:\Users\Public\Documents\drivers -DestinationPath C:\Users\Public\Documents -CompressionLevel Fastest
    # Install drivers from folder using DISM
    #Dism /Image:C:\WinPE_amd64\mount /Add-Driver /Driver:C:\Users\Public\Documents\drivers /Recurse /forceunsigned
}
# Add Unattend file:
function SetUnattend() {
    Write-Host "Adding Unattend File..."
    Dism /Image:"C:\WinPE_amd64\mount" /Apply-Unattend:"C:\Users\Public\Documents\myunattend.xml"
}

# TODO: Install Software from remote File Share or Define Software share in Unattend File.
function InstallSoftware() {
    Write-Host "Install Software Function not implemented."
}

# Set Lanaguage:
function SetLanguages() {
    Write-Host "Setting Default Language to en-US..."
    Dism /Image:"C:\WinPE_amd64\mount" /Set-UILang:en-US
}

# Add powershell and other tools to image base.
function AddPackages() {
    Write-Host "Adding Standard Addon Packages..."
    Dism /Add-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-WMI.cab"
    Dism /Add-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-WMI_en-us.cab"
    Dism /Add-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-NetFX.cab"
    Dism /Add-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-NetFX_en-us.cab"
    Dism /Add-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-Scripting.cab"
    Dism /Add-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-Scripting_en-us.cab"
    Dism /Add-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-PowerShell.cab"
    Dism /Add-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-PowerShell_en-us.cab"
    Dism /Add-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-StorageWMI.cab"
    Dism /Add-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-StorageWMI_en-us.cab"
    Dism /Add-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-DismCmdlets.cab"
    Dism /Add-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-DismCmdlets_en-us.cab"
}
function RemovePackages() {
    Write-Host "Removing Standard Addon Packages..."
    Dism /Remove-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-WMI.cab"
    Dism /Remove-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-WMI_en-us.cab"
    Dism /Remove-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-NetFX.cab"
    Dism /Remove-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-NetFX_en-us.cab"
    Dism /Remove-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-Scripting.cab"
    Dism /Remove-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-Scripting_en-us.cab"
    Dism /Remove-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-PowerShell.cab"
    Dism /Remove-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-PowerShell_en-us.cab"
    Dism /Remove-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-StorageWMI.cab"
    Dism /Remove-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-StorageWMI_en-us.cab"
    Dism /Remove-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-DismCmdlets.cab"
    Dism /Remove-Package /Image:"C:\WinPE_amd64\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-DismCmdlets_en-us.cab"
}

# Unmount and write changes to the base image.
function UnmountImage() {
    Write-Host "Unmounting WinPE Image..."
    Dism /Unmount-Image /MountDir:C:\WinPE_amd64\mount /Commit
    cd "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment"
    
}

#TODO: Fix make media function
function MakeMedia() {
    Write-Host "Creating WinPE Media..."
    #FIX: Start Process does not execute Make Media script correctly with arguments.
    & "MakeWinPEMedia.cmd /ISO C:\WinPE_amd64 C:\WinPE_amd64.iso"
    Start-Process -FilePath cmd -ArgumentList "MakeWinPEMedia.cmd", "/ISO", "C:\WinPE_amd64", "C:\WinPE_amd64.iso" -PassThru -Verb RunAs -Wait
    Get-Process -Id 4560
}

function Main() {
    # Change working directory to default Install Kit Directory (2021/07/03)
    cd "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools"
    MountImage
    InstallDrivers
    SetUnattend
    InstallSoftware
    SetLanguages
    AddPackages
    UnmountImage
}

Main