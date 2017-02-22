Function Test-URL {
    [CmdletBinding()]
    param([string]$URL)

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
        Write-Output $False
    }
    else {
        Write-Output $True
    }
}

Function Get-InternalURL {
    [CmdletBinding()]
    param()

    try {
        $netAdapters = Get-CimInstance Win32_NetworkAdapterConfiguration -ErrorAction Stop 
        $ip = ($netAdapters.IPAddress | Select-String -Pattern "10.10*").tostring().trim()

        switch -Wildcard ($ip){
            "10.101*" { $URL = "http://riga.choco-cache.local" }
            "10.102*" { $URL = "http://vilnius.choco-cache.local" }
            "10.103*" { $URL = "http://kaunas.choco-cache.local" }
            "10.104*" { $URL = "http://tallinn.choco-cache.local" }
            "10.105*" { $URL = "http://tartu.choco-cache.local" }
            "10.106*" { $URL = "http://kiev.choco-cache.local" }
            "10.107*" { $URL = "http://malaga.choco-cache.local" }
            "10.108*" { $URL = "http://malaga.choco-cache.local" }
            "10.109*" { $URL = "http://alicante.choco-cache.local" }
            default { $URL = $null }
        }

        Write-Output $URL

    } catch {
        throw $_.Exception.Message
    }
}