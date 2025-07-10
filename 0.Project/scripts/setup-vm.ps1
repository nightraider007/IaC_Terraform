# ===================================================================
# setup-vm.ps1
#   Installs IIS, configures firewall, runs diagnostics, deploys web files
# ===================================================================

# --- 1. INSTALL IIS ---
Write-Host "=== Installing IIS ===" -ForegroundColor Cyan
Import-Module ServerManager
Install-WindowsFeature -Name Web-Server -IncludeManagementTools

# --- 2. OPEN FIREWALL PORTS ---
Write-Host "=== Configuring Firewall Rules ===" -ForegroundColor Cyan
$rules = @(
  @{Name='Allow RDP';    Protocol='TCP'; Port=3389},
  @{Name='Allow HTTP';   Protocol='TCP'; Port=80},
  @{Name='Allow HTTPS';  Protocol='TCP'; Port=443},
  @{Name='Allow ICMPv4'; Protocol='ICMPv4'; Port=$null}
)

foreach ($rule in $rules) {
  if ($rule.Protocol -eq 'ICMPv4') {
    New-NetFirewallRule -DisplayName $rule.Name `
                       -Direction Inbound `
                       -Protocol ICMPv4 `
                       -IcmpType 8 `
                       -Action Allow `
                       -ErrorAction SilentlyContinue
  }
  else {
    New-NetFirewallRule -DisplayName $rule.Name `
                       -Direction Inbound `
                       -Protocol $rule.Protocol `
                       -LocalPort $rule.Port `
                       -Action Allow `
                       -ErrorAction SilentlyContinue
  }
  Write-Host "  → $($rule.Name) configured"
}

# --- 3. RUN DIAGNOSTICS ---
$logFile = "C:\AzureVM-Diagnostics.log"
Write-Host "=== Running Diagnostics (log → $logFile) ===" -ForegroundColor Cyan
"`n===== Azure VM Diagnostics =====" | Out-File $logFile -Encoding utf8

# IP Configuration
"`n--- IP Configuration ---" | Out-File $logFile -Append
Get-NetIPAddress `
  | Where-Object AddressFamily -EQ "IPv4" `
  | Format-Table InterfaceAlias, IPAddress, PrefixLength `
  | Out-File -Append $logFile

# Default Gateway
"`n--- Default Gateway ---" | Out-File $logFile -Append
Get-NetRoute -DestinationPrefix "0.0.0.0/0" `
  | Format-Table ifIndex, NextHop `
  | Out-File -Append $logFile

# External Public IP
"`n--- Public IP (external) ---" | Out-File $logFile -Append
try {
  $publicIp = (Invoke-RestMethod -Uri "http://ipinfo.io/ip").Trim()
  "Public IP: $publicIp" | Out-File -Append $logFile
} catch {
  "Unable to retrieve public IP" | Out-File -Append $logFile
}

# DNS resolution
"`n--- DNS Resolution ---" | Out-File $logFile -Append
try {
  Resolve-DnsName www.google.com `
    | Select-Object -First 3 `
    | Out-File -Append $logFile
} catch {
  "DNS resolution failed" | Out-File -Append $logFile
}

# Azure Metadata Service
"`n--- Azure Metadata Service ---" | Out-File $logFile -Append
try {
  Invoke-RestMethod -Headers @{Metadata='true'} `
                    -Uri "http://169.254.169.254/metadata/instance?api-version=2021-02-01"
  "IMDS reachable" | Out-File -Append $logFile
} catch {
  "IMDS NOT reachable" | Out-File -Append $logFile
}

# Listening Ports Check
"`n--- Listening Ports (RDP, HTTP) ---" | Out-File $logFile -Append
Get-NetTCPConnection -LocalPort 3389,80 -State Listen `
  | Format-Table LocalAddress, LocalPort, State `
  | Out-File -Append $logFile

# ICMP Rule Verification
"`n--- ICMP Rule Status ---" | Out-File $logFile -Append
try {
  $icmpRule = Get-NetFirewallRule `
               | Where-Object DisplayName -Like "*ICMP*" `
               | Where-Object Enabled -EQ "True"
  if ($icmpRule) {
    "ICMP Echo Requests allowed" | Out-File -Append $logFile
  } else {
    "ICMP Echo Requests NOT allowed" | Out-File -Append $logFile
  }
} catch {
  "Unable to determine ICMP rule status" | Out-File -Append $logFile
}

"`n===== Diagnostics Complete =====" | Out-File -Append $logFile
Write-Host "Diagnostics logged to $logFile" -ForegroundColor Green

# --- 4. DEPLOY WEB CONTENT ---
Write-Host "=== Deploying Web Content ===" -ForegroundColor Cyan
$fileBase = "https://raw.githubusercontent.com/nightraider007/IaC_Terraform/main/0.Project/iis_uploads"
Invoke-WebRequest -Uri "$fileBase/index.htm" -OutFile "C:\inetpub\wwwroot\index.htm"
Invoke-WebRequest -Uri "$fileBase/Eco.png"   -OutFile "C:\inetpub\wwwroot\Eco.png"
Write-Host "Web content deployed to C:\inetpub\wwwroot" -ForegroundColor Green
