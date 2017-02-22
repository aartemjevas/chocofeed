$ErrorActionPreference = 'Stop'
try {

    [System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials 
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/aartemjevas/chocofeed/master/helpers.ps1'))
    $toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

    $Package = Get-Content "$toolsDir\Package.json" | Out-String | ConvertFrom-Json 
    $url = Get-URL -Arch 32
    $url64 = Get-URL -Arch 64

    
    $packageArgs = @{
      packageName   = $Package.Packagename
      fileType      = $Package.Filetype
      url           = $url
      url64bit      = $url64
      softwareName  = $Package.softwareName
      checksum      = $Package.Checksum32
      checksumType  = 'md5' 
      checksum64    = $Package.Checksum64
      checksumType64= 'md5' 
      silentArgs    = ""
      validExitCodes= @(0, 3010, 1641)
    }

    Install-ChocolateyPackage @packageArgs

} 

catch {
    throw $_.expression.message
}

