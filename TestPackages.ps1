Function Get-NewPackage {
    [CmdletBinding()]
    param()
    
    $nupkg = Get-ChildItem -Path $PSScriptRoot\packages -Filter "*.nupkg" -File
    Write-Output $nupkg  
}

function Test-Package {

    #https://github.com/majkinetor/au

    $validExitCodes = @(0, 1605, 1614, 1641, 3010)
    $packages += ls "$PSScriptRoot\tmpPackageDir\*.nupkg" | Split-Path -Leaf | % { ($_ -replace '((\\.\\d+)+(-[^-\\.]+)?).nupkg', ':$1').Replace(':.', ':') }
    Write-Verbose "$('=' * 60)" 
    Write-Verbose ("{0}`n{1}`n{0}`n" -f ('='*60), "TESTING FOLLOWING PACKAGES: $packages")
    Write-Verbose "$('=' * 60)"

    Write-Verbose "Cleaning test results directory"
    $res = @()
    foreach ($package in $packages) {
        $p = $package -split ':'; $name = $p[0]; $ver = $p[1]
        Write-Verbose ("{0}`n{1}`n" -f ('-'*60), "PACKAGE: $package")

        Write-Verbose ('-'*60) "`n"

        Write-Verbose 'TESTING INSTALL FOR' $package

        $choco_cmd = "choco install -fy $name --allow-downgrade"
        $choco_cmd += if ($ver) { " --version $ver" }
        $choco_cmd += ' --source "''{0}''"' -f "$PSScriptRoot\tmpPackageDir"

        Write-Verbose "CMD: $choco_cmd"
        $LastExitCode = 0
        iex $choco_cmd
        $exitCode = $LastExitCode

        if ($validExitCodes -contains $exitCode) {
            $res += [pscustomobject]@{'Packagename'= $package ;'Status' = 'success'}
            Write-Verbose "Exit code for $package was $exitCode"
        } else {
            $res += [pscustomobject]@{'Packagename'= $package ;'Status' = 'failed'}
        }
 
        Write-Output $res
    }

}

$null = mkdir "$PSScriptRoot\tmpPackageDir"
Get-NewPackage | Move-Item -Destination "$PSScriptRoot\tmpPackageDir"
Test-Package