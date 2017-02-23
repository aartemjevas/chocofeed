
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
            Write-Output "exit code was valid"
            $script:testRes += [pscustomobject]@{  'Packagename'= $($package.Packagename);
                                        'Status' = 'success'; 
                                        'exitcode' = $LastExitCode}
        } else {
            Write-Output "exit code was not valid"
            $script:testRes += [pscustomobject]@{  'Packagename'= $($package.Packagename);
                                        'Status' = 'failed'; 
                                        'existcode' = $LastExitCode}
        }
    } 
    catch {
     
    }

}

foreach ($path in (Get-ChildItem -Path "$PSScriptRoot\packages" -Directory)) {
    Write-Verbose $path.name
    if (Test-Path "$($path.fullname)\*.nupkg") {
       $chocoOutput = Test-Package -Path $path.fullname
       Write-Verbose $($chocoOutput | Out-String)
    } 
}
