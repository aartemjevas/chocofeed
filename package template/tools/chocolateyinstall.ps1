$ErrorActionPreference = 'Stop'
. .\helpers.ps1
$baseURL = Get-ChocoCacheURL
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url        = $baseURL + "/" + $package.Packagename + "/" + $package.Version + "/" +  $package.Filename32 
if (!([string]::IsNullOrEmpty($package.Filename64))) {
    $url64      = $baseURL + "/" + $package.Packagename + "/" + $package.Version + "/" +  $package.Filename64 
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
  silentArgs    = ""
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs
