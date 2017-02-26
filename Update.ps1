Import-Module $PSScriptRoot\ChocoPackageUpdater\ChocoPackageUpdater.psm1

$packages = @()
$env:ChocoPackageSource = 'https://www.myget.org/F/chocofeed/api/v2'
foreach ($packagePath in Get-ChildItem -Path .\Packages) {
    $packages += Get-ChocoPackage -Path $packagePath.fullname
}

foreach ($package in $packages) { 
    if ($package.needsupdate()) {
        $package.Update()
        Test-ChocoPackage -Path $package.Path
    }
}


