$releases = 'http://www.7-zip.org/download.html'
$download_page = Invoke-WebRequest -Uri $releases
$msiLinks = $download_page.links | ? {$_.href -like "*msi"} | Select-Object -First 2
$url32 = "http://www.7-zip.org/$($msiLinks[0].href)"
$url64 = "http://www.7-zip.org/$($msiLinks[1].href)"
[string]$version = ($msiLinks[0].href).Replace('a/7z','').replace('.msi','').insert(2,'.')

return [PSCustomObject]@{ 'Version' = $version; 
                    'DownloadUrl32' = $url32;
                    'DownloadUrl64' = $url64 }


