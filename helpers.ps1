Function Test-URL {
    [CmdletBinding()]
    param([string]$URL
    )

     $paramHash = @{
     UseBasicParsing = $True
     DisableKeepAlive = $True
     Uri = $URL
     Method = 'Head'
     ErrorAction = 'stop'
     TimeoutSec = 5
    }
    $test = Invoke-WebRequest @paramHash
    if ($test.statuscode -ne 200) {
        Write-Output $false
    }
    else {
        Write-Output $True
    }
}
Function Get-URL {
    [CmdletBinding()]
    param([ValidateSet("32","64")]
          [string]$Arch
    )
    $InternalServer = Get-InternalServer
    switch ($Arch) {
        "32" {
            if ($InternalServer -eq $null) {
                $url = $Package.DownloadURL32
            }
            else {
                $url = "$InternalServer/$($Package.Packagename)/$($Package.Version)/$($Package.Filename32)"
                if (!(Test-URL -URL $url)) {
                    Write-Verbose "URL $url not found. Switching to $($Package.DownloadURL32)"
                    $url = $Package.DownloadURL32
                }
            }
        }
        "64" {
            if ($InternalServer -eq $null) {
                $url = $Package.DownloadURL64
            }
            else {
                 $url = "$InternalServer/$($Package.Packagename)/$($Package.Version)/$($Package.Filename64)"
                if (!(Test-URL -URL $url)) {
                     Write-Verbose "URL $url not found. Switching to $($Package.DownloadURL64)"
                    $url = $Package.DownloadURL64
                }
            }        
        }
    }
    Write-Output $url
        
}

Function Get-InternalServer {
    [CmdletBinding()]
    param()

    try {
        $netAdapters = Get-CimInstance Win32_NetworkAdapterConfiguration -ErrorAction Stop 
        $ip = ($netAdapters.IPAddress | Select-String -Pattern "10.10*").tostring().trim()

        switch -Wildcard ($ip){
            "10.101*" { $URL = "http://riga.choco-cache.local/files" }
            "10.102*" { $URL = "http://vilnius.choco-cache.local/files" }
            "10.103*" { $URL = "http://kaunas.choco-cache.local/files" }
            "10.104*" { $URL = "http://tallinn.choco-cache.local/files" }
            "10.105*" { $URL = "http://tartu.choco-cache.local/files" }
            "10.106*" { $URL = "http://kiev.choco-cache.local/files" }
            "10.107*" { $URL = "http://malaga.choco-cache.local/files" }
            "10.108*" { $URL = "http://malaga.choco-cache.local/files" }
            "10.109*" { $URL = "http://alicante.choco-cache.local/files" }
            default { $URL = $null }
        }

        Write-Output $URL

    } catch {
        throw $_.Exception.Message
    }
}