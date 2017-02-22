$VerbosePreference = "Continue"
. $PSScriptRoot\Package.ps1

$PackagePaths = Get-ChildItem -Path "$PSScriptRoot\packages" -Directory
if ([string]::IsNullOrEmpty($PackagePaths)) {
    Write-Verbose "No packages were found"
}
else {
    foreach ($PackagePath in $PackagePaths) {
        $package = [Package]::new($PackagePath.Fullname)
        if ($package.needsupdate()) {
            Write-Verbose ('-'*60)
            Write-Verbose "UPDATING PACKAGE: $($package.Packagename) v$($package.CurrentVersion) to v$($package.LatestVersion)"
            Write-Verbose ('-'*60)
            $package.Update()
        }
    }
}