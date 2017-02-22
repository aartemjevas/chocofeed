Function Download-RemoteFile {
    [CmdletBinding()]
    param([string]$URL,
          [string]$Destination,
          [string]$Checksum)

    try {
        Invoke-WebRequest -UseBasicParsing $URL -OutFile $Destination -ErrorAction Stop
        $fileHash = Get-FileHash -Path $Destination -Algorithm MD5 | 
            Select-Object -ExpandProperty Hash

        if ($fileHash -eq $Checksum) {
            Write-Verbose "Hashes match"
            Write-Verbose $Destination
        }
        else {
            Remove-Item $Destination
            throw "Hashes does not match"
        }    
    } catch {
        throw $_.exception.message
    }
}
Function Save-RemoteContent {
    [CmdletBinding()]
    param([string]$Path,
          [switch]$Force)

    $PackagesPaths = Get-ChildItem -Path "$PSScriptRoot\Packages" -Directory
    foreach ($PackagesPath in $PackagesPaths) {
        try {
            $Package = Get-Content "$($PackagesPath.fullname)\tools\package.json" | 
                ConvertFrom-Json -ErrorAction Stop

            Write-Verbose ('-'*60)
            Write-Verbose "PACKAGE: $($Package.Packagename) v$($Package.Version)"
            Write-Verbose ('-'*60)

            $saveTo =  "$Path\$($Package.Packagename)\$($Package.Version)"
            if (!(Test-Path $saveTo)) {
                $null = mkdir $saveTo
            }
            
            if (!([string]::IsNullOrEmpty($Package.DownloadURL32))) {
               if ((Test-Path "$saveTo\$($Package.Filename32)") -and (-not $Force)) {
                    Write-Verbose "File $saveTo\$($Package.Filename32) already exists"
               }
               else {
                   Download-RemoteFile -URL $Package.DownloadURL32 -Destination "$saveTo\$($Package.Filename32)" -Checksum $Package.Checksum32               
               }

            }
            if (!([string]::IsNullOrEmpty($Package.DownloadURL64))) {
               if ((Test-Path "$saveTo\$($Package.Filename64)") -and (-not $Force)) {
                    Write-Verbose "File $saveTo\$($Package.Filename64) already exists"
               }
               else {
                   Download-RemoteFile -URL $Package.DownloadURL64 -Destination "$saveTo\$($Package.Filename64)" -Checksum $Package.Checksum64               
               }
            }   
        } 
        catch {
            throw $_.exception.message
        }
    }
}