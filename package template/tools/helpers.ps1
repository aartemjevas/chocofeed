Function Get-ChocoCacheURL
{
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

        }

        if ([string]::IsNullOrEmpty($URL))
        {
            Write-Error "Failed to determine apprepo server"
        } else {
            Write-Output $URL
        }
    } catch {
        throw $Error[0].Exception
    }
}

[string]$PackageJSON = Get-Content (Join-Path ((Get-Item $PSScriptRoot).Parent.FullName) "package.json") -Encoding UTF8 -ErrorAction Stop
$package = ConvertFrom-Json $PackageJSON
