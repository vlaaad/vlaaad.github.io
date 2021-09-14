$free_version = (curl -s https://clojars.org/api/artifacts/vlaaad/reveal | ConvertFrom-Json).latest_release
$pro_version = (curl -s https://clojars.org/api/artifacts/dev.vlaaad/reveal-pro | ConvertFrom-Json).latest_release

(Get-Content .\reveal.md) | ForEach-Object {$_ -replace 'vlaaad/reveal {:mvn/version ".+"',"vlaaad/reveal {:mvn/version `"$free_version`""} | Set-Content .\reveal.md
(Get-Content .\reveal-pro.md) | ForEach-Object {$_ -replace 'dev.vlaaad/reveal-pro {:mvn/version ".+"',"dev.vlaaad/reveal-pro {:mvn/version `"$free_version`""} | Set-Content .\reveal-pro.md

git add . 
git commit -am "$free_version"
git push