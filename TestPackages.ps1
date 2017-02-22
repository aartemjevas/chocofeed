
Function Test-Package {
    [CmdletBinding()]
    param([string]$Path)
    try {
        $package = Get-Content $Path\tools\package.json | ConvertFrom-Json
        Write-Verbose ('-'*60)
        Write-Verbose "TESTING $($package.Packagename) v$($package.Version)"
        Write-Verbose ('-'*60)
        $LastExitCode = 0
        $validExitCodes = @(0, 1605, 1614, 1641, 3010)
        Invoke-Expression "choco install $($package.Packagename) --version $($package.Version) --source $Path -yf"
        if ($validExitCodes -contains $LastExitCode) {
            $res += [pscustomobject]@{  'Packagename'= $($package.Packagename);
                                        'Status' = 'success'; 
                                        'exitcode' = $LastExitCode}
            Write-Verbose "Exit code for $package was $exitCode"
        } else {
            $res += [pscustomobject]@{  'Packagename'= $($package.Packagename);
                                        'Status' = 'failed'; 
                                        'existcode' = $LastExitCode}
        }
        Write-Output $res
    } 
    catch {
     
    }

}

foreach ($path in (Get-ChildItem -Path "$PSScriptRoot\packages" -Directory)) {
    Write-Verbose $path.name
    if (Test-Path "$($path.fullname)\*.nupkg") {
        Test-Package -Path $path.fullname
    } 
}
