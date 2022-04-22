$free_version = (curl -s https://clojars.org/api/artifacts/vlaaad/reveal | ConvertFrom-Json).latest_release
$pro_version = (curl -s https://clojars.org/api/artifacts/dev.vlaaad/reveal-pro | ConvertFrom-Json).latest_release

Get-ChildItem -Filter *.md | ForEach-Object {
    
    (Get-Content $_.Name) 
      | ForEach-Object { $_ -replace 'vlaaad/reveal {:mvn/version ".+"', "vlaaad/reveal {:mvn/version `"$free_version`"" } 
      | ForEach-Object { $_ -replace '\[vlaaad/reveal ".+"\]', "[vlaaad/reveal `"$free_version`"]" }
      | ForEach-Object { $_ -replace 'dev.vlaaad/reveal-pro {:mvn/version ".+"', "dev.vlaaad/reveal-pro {:mvn/version `"$pro_version`"" }
      | Set-Content $_.Name
}


git add . 
git commit -am "Free: ``$free_version``, Pro: ``$pro_version``"
# git push