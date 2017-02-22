[string]$PackageJSON = Get-Content $PSScriptRoot\package.json -Encoding UTF8 -ErrorAction Stop
$packageSettings = ConvertFrom-Json $PackageJSON

$releases = 'https://www.mozilla.org/en-US/firefox/all/?q=English%20(US)'
$download_page = Invoke-WebRequest -Uri $releases 
$url32 = $download_page.links | Where-object title -eq 'Download for Windows in English (US)' | Select-object -expand href
$url64 = $download_page.links | Where-object title -eq 'Download for Windows 64-bit in English (US)' | Select-object -expand href
[string]$version = ($url32 -split '-')[1]

return [PSObject]@{ 'LatestVersion' = $version; 
                    'URL32' = $url32;
                    'URL64' = $url64 }


