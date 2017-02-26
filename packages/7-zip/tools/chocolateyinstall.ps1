$ErrorActionPreference = 'Stop'
try {
    $toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
    . $toolsDir\helpers.ps1
    $Package = Get-Content "$toolsDir\package.json" | Out-String | ConvertFrom-Json 
    $url = Get-URL -Arch 32
    $url64 = Get-URL -Arch 64



    $packageArgs = @{
      packageName   = $Package.Packagename
      fileType      = 'msi'
      url           = "$url"
      url64bit      = "$url64"
      softwareName  = "7-zip*"
      checksum      = $Package.Checksum32
      checksumType  = 'md5' 
      checksum64    = $Package.Checksum64
      checksumType64= 'md5' 
      silentArgs    = "/quiet /norestart REMOVE_PREVIOUS=YES /l*v `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).MsiInstall.log`""
      validExitCodes= @(0, 3010, 1641)
    }

    Install-ChocolateyPackage @packageArgs

} 

catch {
    throw $_.exception.message
}

