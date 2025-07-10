# setup-webfiles.ps1
Write-Host "Downloading web content..."

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/your-org/your-repo/main/web/index.html" -OutFile "C:\inetpub\wwwroot\index.html"

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/your-org/your-repo/main/web/logo.png" -OutFile "C:\inetpub\wwwroot\logo.png"

Write-Host "Web content deployed to C:\inetpub\wwwroot"
