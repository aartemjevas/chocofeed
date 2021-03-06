$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
[string]$PackageJSON = Get-Content "$toolsDir\package.json" -Encoding UTF8 -ErrorAction Stop
$package = ConvertFrom-Json $PackageJSON

$packageName = $package.Packagename
$fileType = $package.Filetype
$validExitCodes = @(0)
$silentArgs = '-ms'
 
  $regUninstallDir = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\'
  $regUninstallDirWow64 = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\'
   
  $uninstallPaths = $(Get-ChildItem $regUninstallDir).Name
   
  if ( Get-ProcessorBits 64 ) {
      if (Test-Path $regUninstallDirWow64) {
        $uninstallPaths += $(Get-ChildItem $regUninstallDirWow64).Name
      }
  }
 
  $uninstallPath = $uninstallPaths -match
    "Mozilla Firefox [\d\.]+ \([^\s]+ [a-zA-Z\-]+\)" | Select-object -First 1
   
  $firefox_key = ( $uninstallPath.replace('HKEY_LOCAL_MACHINE\','HKLM:\') )
     
  $file = (Get-ItemProperty -Path ( $firefox_key ) ).UninstallString 
   
  Uninstall-ChocolateyPackage -PackageName $packageName -FileType $fileType -SilentArgs $silentArgs -validExitCodes $validExitCodes -File $file
