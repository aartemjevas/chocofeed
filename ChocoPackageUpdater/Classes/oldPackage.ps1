class Package {
    [string]$Path
    [string]$PackageName
    [string]$CurrentVersion
    [string]$LatestVersion
    [string]$DownloadUrl32
    [string]$DownloadUrl64
    [string]$Filename32
    [string]$Filename64
    [string]$SoftwareName
    [string]$FileType
    [string]$Checksum32
    [string]$Checksum64
    [string]$TmpFile32Path
    [string]$TmpFile64Path
    [string]$PackagePath
    [bool]$PackageCreated
    hidden [string]$NuspecFile
    hidden [string]$JsonFile
    hidden [string[]]$CurrentNuspecContent
    hidden [string[]]$CurrentJsonContent
    hidden [string[]]$NewNuspecContent
    hidden [string[]]$NewJsonContent
    hidden [string]$CurrentDownloadURL32
    hidden [string]$CurrentDownloadURL64

    Package ([string]$Path){
        $updateScript = Join-Path $Path 'update.ps1'
        if (Test-Path $updateScript) {           
            $packageJson = ConvertFrom-Json -InputObject $(Get-Content "$Path\tools\package.json" | Out-String)

            Write-Verbose "Launching $updateScript"
            $update = &$updateScript
            $this.PackageName = $packageJson.Packagename
            $this.CurrentVersion = $packageJson.Version
            $this.LatestVersion = $update.LatestVersion
            $this.DownloadUrl32 = $update.URL32
            $this.DownloadUrl64 = $update.URL64
            $this.SoftwareName = $packageJson.SoftwareName
            $this.Filename32 = $packageJson.Filename32
            $this.Filename64 = $packageJson.Filename64
            $this.FileType = $packageJson.Filetype 
            $this.Checksum32 = $packageJson.Checksum32
            $this.Checksum64 = $packageJson.Checksum64
            $this.Path = $Path
            $this.JsonFile = "$Path\tools\package.json"
            $this.NuspecFile = $(Get-ChildItem -Path $Path -Filter "*.nuspec").FullName
            $this.CurrentJsonContent = Get-Content -Path $this.JsonFile
            $this.CurrentNuspecContent = Get-Content -Path $this.NuspecFile
            $this.PackageCreated = $false
            $this.CurrentDownloadURL32 = $packageJson.DownloadURL32
            $this.CurrentDownloadURL64 = $packageJson.DownloadURL64

        } 
        else {
            Write-Verbose "This package does not have update script"
        }
        
    }
    [bool] NeedsUpdate() {
        if ( $this.CurrentVersion -ne $this.LatestVersion ) {
            return $true
        }
        else {
            return $false
        }
    }

    [void]Update() {
        Write-Verbose "Removing old nupkg files"
        Get-ChildItem -Path $this.Path -Filter "*.nupkg" | Remove-Item -Force

            if ([string]::IsNullOrEmpty($this.DownloadUrl32) -and [string]::IsNullOrEmpty($this.DownloadUrl32)) {
            $this.Report += "No URLs were found"
            throw "No URLs were found"
            }
            else {
            $Chsm32 = [string]::Empty
            $Chcm64 = [string]::Empty

            if (-Not([string]::IsNullOrEmpty($this.DownloadUrl32)) -and -not([string]::IsNullOrEmpty($this.Filename32))) {
                $this.TmpFile32Path = Join-Path $env:TEMP $this.Filename32
                Invoke-WebRequest -UseBasicParsing $this.DownloadUrl32 -OutFile $this.TmpFile32Path
                Write-Verbose "Saved to $($this.TmpFile32Path)" 
                $Chsm32 = Get-FileHash -Path $this.TmpFile32Path -Algorithm MD5 | Select-Object -ExpandProperty Hash
            }
            if (-Not([string]::IsNullOrEmpty($this.DownloadUrl64)) -and -not([string]::IsNullOrEmpty($this.Filename64))) {
                $this.TmpFile64Path = Join-Path $env:TEMP $this.Filename64
                Invoke-WebRequest -UseBasicParsing $this.DownloadUrl64 -OutFile $this.TmpFile64Path
                Write-Verbose "Saved to $($this.TmpFile64Path)"
                $Chcm64 = Get-FileHash -Path $this.TmpFile64Path -Algorithm MD5 | Select-Object -ExpandProperty Hash
            }        
         
            $this.NewNuspecContent = ($this.CurrentNuspecContent).Replace(  "<version>$($this.CurrentVersion)</version>",
                                                                            "<version>$($this.LatestVersion)</version>") 
            $this.NewJsonContent = ($this.CurrentJsonContent).Replace(  "`"Version`": `"$($this.CurrentVersion)`"",
                                                                        "`"Version`": `"$($this.LatestVersion)`"")
            $this.NewJsonContent = ($this.NewJsonContent).Replace(  "`"Checksum32`": `"$($this.Checksum32)`"",
                                                                    "`"Checksum32`": `"$Chsm32`"")
            $this.NewJsonContent = ($this.NewJsonContent).Replace(  "`"Checksum64`": `"$($this.Checksum64)`"",
                                                                    "`"Checksum64`": `"$Chcm64`"")
            $this.NewJsonContent = ($this.NewJsonContent).Replace(  "`"DownloadURL32`": `"$($this.CurrentDownloadURL32)`"",
                                                                    "`"DownloadURL32`": `"$($this.DownloadUrl32)`"")
            $this.NewJsonContent = ($this.NewJsonContent).Replace(  "`"DownloadURL64`": `"$($this.CurrentDownloadURL64)`"",
                                                                    "`"DownloadURL64`": `"$($this.DownloadUrl64)`"")

            Write-Verbose "Updating $($this.JsonFile)"
            $this.NewJsonContent | Out-File $this.JsonFile
            Write-Verbose "Updating $($this.NuspecFile)"
            $this.NewNuspecContent | out-file $this.NuspecFile         
            $this.CurrentVersion = $this.LatestVersion
            $this.Checksum32 = $Chsm32
            $this.Checksum64 = $Chcm64

            Push-Location $this.Path
            Write-Verbose "Creating package"
            &choco pack
            Pop-Location
            
            $nupkg = "$($this.Path)\$($this.PackageName).$($this.LatestVersion).nupkg" 
            if (!(Test-Path $nupkg)) {
                
                $this.CurrentJsonContent | Out-File $this.JsonFile
                $this.CurrentNuspecContent | Out-File $this.NuspecFile
                throw "Failed to create package"
            }
            else {
                Write-Verbose "$nupkg"
                $this.PackagePath = $nupkg
                $this.PackageCreated = $true
            } 
            }
    }

}