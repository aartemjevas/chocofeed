$ErrorActionPreference = 'Stop'; # stop on all errors
[System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials 
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/aartemjevas/chocofeed/master/helpers.ps1'))
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$Package = Get-Content "$toolsDir\Package.json" | Out-String | ConvertFrom-Json 
$url = Get-URL -Arch 32
$url64 = Get-URL -Arch 64
# ---------------- Function definitions ------------------
 
function GetUninstallPath () {
  $regUninstallDir = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\'
  $regUninstallDirWow64 = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\'
 
  $uninstallPaths = $(Get-ChildItem $regUninstallDir).Name
 
  if (Test-Path $regUninstallDirWow64) {
    $uninstallPaths += $(Get-ChildItem $regUninstallDirWow64).Name
  }
 
  $uninstallPath = $uninstallPaths -match
    "Mozilla Firefox [\d\.]+ \([^\s]+ [a-zA-Z\-]+\)" | Select-Object -First 1
  return $uninstallPath
}
 
 
function AlreadyInstalled($version) {
  $uninstallEntry = $(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla " +
    "Firefox ${version}*"
  )
  $uninstallEntryWow64 = $(
    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Mozilla " +
    "Firefox ${version}*"
  )
 
  if ((Test-Path $uninstallEntry) -or (Test-Path $uninstallEntryWow64)) {
    return $true
  }
 
  return $false
}
 
function Get-32bitOnlyInstalled {
  $systemIs64bit = Get-ProcessorBits 64
 
  if (-Not $systemIs64bit) {
    return $false
  }
 
  $registryPaths = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
  )
 
  $installedVersions = Get-ChildItem $registryPaths | Where-Object {
    $_.Name -match 'Mozilla Firefox [\d\.]+ \(x(64|86)'
  }
 
  if (
    $installedVersions -match 'x86' `
    -and $installedVersions -notmatch 'x64' `
    -and $systemIs64bit
  ) {
    return $true
  }
}
 
# ----------------------------------
 
$alreadyInstalled = AlreadyInstalled($version)
 
if (Get-32bitOnlyInstalled) {
  Write-Output $(
    'Detected the 32-bit version of Firefox on a 64-bit system. ' +
    'This package will continue to install the 32-bit version of Firefox ' +
    'unless the 32-bit version is uninstalled.'
  )
}
 
if ($alreadyInstalled) {
  Write-Output $(
    "Firefox $version is already installed. " +
    'No need to download an re-install again.'
  )
} else {
    if ((Get-32bitOnlyInstalled) -or (Get-ProcessorBits 32)) {
      $fURL = $url
      $fChecksum = $package.Checksum32
    } else {
      $fURL = $url64
      $fChecksum = $package.Checksum64
    }
  $packageArgs = @{
    packageName   = $package.Packagename
    fileType      = $package.Filetype
    url           = $url
    url64bit      = $url64
    softwareName  = $package.softwareName
    checksum      = $package.Checksum32
    checksumType  = 'md5' 
    checksum64    = $package.Checksum64
    checksumType64= 'md5' 
    silentArgs    = "-ms"
    validExitCodes= @(0, 3010, 1641)
  }

  Install-ChocolateyPackage @packageArgs
}

