if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Output "Installer needs to be run as Administrator. Attempting to relaunch."
    Start-Process -Verb runas -FilePath powershell.exe -ArgumentList "SetupNewWinLabPC.ps1"
    break
}

if (Test-Path ~\AppData\Local\Microsoft\WindowsApps\winget.exe){
    Write-Host "Winget Already Installed"

}
else {
    Write-Host "Running Alternative Installer and Direct Installing"
$ErrorActionPreference = "Stop"
$apiLatestUrl = 'https://api.github.com/repos/microsoft/winget-cli/releases/latest'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Hide the progress bar of Invoke-WebRequest
$oldProgressPreference = $ProgressPreference
$ProgressPreference = 'SilentlyContinue'

$desktopAppInstaller = @{
fileName = 'Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'
url      = $(((Invoke-WebRequest $apiLatestUrl -UseBasicParsing | ConvertFrom-Json).assets | Where-Object { $_.name -match '^Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle$' }).browser_download_url)
hash     = $(Get-LatestHash)
}

$vcLibsUwp = @{
fileName = 'Microsoft.VCLibs.x64.14.00.Desktop.appx'
url      = 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx'
hash     = '6602159c341bafea747d0edf15669ac72df8817299fbfaa90469909e06794256'
}
$uiLibs = @{
    nupkg = @{
        fileName = 'microsoft.ui.xaml.2.7.0.nupkg'
        url = 'https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.7.0'
        hash = "422FD24B231E87A842C4DAEABC6A335112E0D35B86FAC91F5CE7CF327E36A591"
    }
    uwp = @{
        fileName = 'Microsoft.UI.Xaml.2.7.appx'
    }
}
$uiLibs.uwp.file = $PWD.Path + '\' + $uiLibs.uwp.fileName
$uiLibs.uwp.zipPath = '*/x64/*/' + $uiLibs.uwp.fileName

$dependencies = @($desktopAppInstaller, $vcLibsUwp, $uiLibs.nupkg)

foreach ($dependency in $dependencies) {
$dependency.file = $dependency.fileName
Invoke-WebRequest $dependency.url -OutFile $dependency.file
}

$uiLibs.nupkg.file = $PSScriptRoot + '\' + $uiLibs.nupkg.fileName
Add-Type -Assembly System.IO.Compression.FileSystem
$uiLibs.nupkg.zip = [IO.Compression.ZipFile]::OpenRead($uiLibs.nupkg.file)
$uiLibs.nupkg.zipUwp = $uiLibs.nupkg.zip.Entries | Where-Object { $_.FullName -like $uiLibs.uwp.zipPath }
[System.IO.Compression.ZipFileExtensions]::ExtractToFile($uiLibs.nupkg.zipUwp, $uiLibs.uwp.file, $true)
$uiLibs.nupkg.zip.Dispose()

Add-AppxPackage -Path $desktopAppInstaller.file -DependencyPath $vcLibsUwp.file,$uiLibs.uwp.file

Remove-Item $desktopAppInstaller.file
Remove-Item $vcLibsUwp.file
Remove-Item $uiLibs.nupkg.file
Remove-Item $uiLibs.uwp.file
Write-Host "WinGet installed!" -ForegroundColor Green
$ProgressPreference = $oldProgressPreference
Update-EnvironmentVariables

Write-Host "Winget Installed"
}   <# Action when all if and elseif conditions are false #>

if (Get-Command -Name choco -ErrorAction Ignore){
    Write-Host "Chocolatey Already Installed"
    return
}

else {
    Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) -ErrorAction Stop
    powershell choco feature enable -n allowGlobalConfirmation    <# Action when all if and elseif conditions are false #>
}

choco install python3 -y
choco install vcredist140  -y
choco install notepadplusplus.install -y
choco install 7zip.install -y
choco install dotnetfx -y
choco install git -y
choco install gimp -y
choco install autodesk-fusion360 -y
choco install thonny -y
choco install vscode -y
choco install wget -y
choco install windirstat -y
choco install putty -y
choco install curl -y
choco install winscp -y
choco install vlc -y
choco install virtualbox -y
choco install wsl2 -y
choco install rufus -y
choco install github-desktop -y
