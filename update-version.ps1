$version = (curl https://clojars.org/api/artifacts/vlaaad/reveal | ConvertFrom-Json).latest_release

(Get-Content .\reveal.md) | ForEach-Object {$_ -replace 'vlaaad/reveal {:mvn/version ".+"',"vlaaad/reveal {:mvn/version `"$version`""} | Set-Content .\reveal.md

git add . 
git commit -am "$version"
git push