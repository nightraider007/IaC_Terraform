# === IIS Installation ===
Write-Host "Installing IIS..."
Install-WindowsFeature -Name Web-Server -IncludeManagementTools

# === Firewall Rules ===
Write-Host "Creating firewall rules..."
$rules = @(
    @{Name='Allow RDP'; Port=3389},
    @{Name='Allow HTTP'; Port=80},
    @{Name='Allow HTTPS'; Port=443},
    @{Name='Allow ICMPv4'; Protocol='ICMPv4'}
)

foreach ($rule in $rules) {
    if ($rule.Protocol -eq 'ICMPv4') {
        New-NetFirewallRule -DisplayName $rule.Name -Direction Inbound -Protocol ICMPv4 -IcmpType 8 -Action Allow
    } else {
        New-NetFirewallRule -DisplayName $rule.Name -Direction Inbound -Protocol TCP -LocalPort $rule.Port -Action Allow
    }
}

# === Diagnostics ===
$logFile = "C:\AzureVM-Diagnostics.log"
Write-Host "Running diagnostics..."
Add-Content -Path $logFile -Value "`n===== Azure VM Diagnostics ====="

# 1. IP Info
Add-Content -Path $logFile -Value "`n--- IP Configuration ---"
Get-NetIPAddress | Where-Object { $_.AddressFamily -eq "IPv4" } | Format-Table InterfaceAlias, IPAddress, PrefixLength | Out-File -Append $logFile

# 2. Default Gateway
Add-Content -Path $logFile -Value "`n--- Default Gateway ---"
Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Format-Table ifIndex, NextHop | Out-File -Append $logFile

# 3. Public IP
Add-Content -Path $logFile -Value "`n--- Public IP (External) ---"
try {
    $publicIp = (Invoke-RestMethod -Uri "http://ipinfo.io/ip").Trim()
    Add-Content -Path $logFile -Value "Public IP: $publicIp"
} catch {
    Add-Content -Path $logFile -Value "Unable to retrieve public IP."
}

# 4. DNS Resolution
Add-Content -Path $logFile -Value "`n--- DNS Resolution ---"
try {
    Resolve-DnsName www.google.com | Out-File -Append $logFile
} catch {
    Add-Content -Path $logFile -Value "DNS resolution failed"
}

# 5. IMDS Check
Add-Content -Path $logFile -Value "`n--- Azure Instance Metadata Service ---"
try {
    Invoke-RestMethod -Headers @{"Metadata"="true"} -Uri "http://169.254.169.254/metadata/instance?api-version=2021-02-01"
    Add-Content -Path $logFile -Value "IMDS reachable"
} catch {
    Add-Content -Path $logFile -Value "IMDS NOT reachable"
}

# 6. Listening Ports
Add-Content -Path $logFile -Value "`n--- Listening Ports (RDP/HTTP) ---"
Get-NetTCPConnection -LocalPort 3389,80 -State Listen | Format-Table LocalAddress, LocalPort, State | Out-File -Append $logFile

# 7. ICMP Echo Check
Add-Content -Path $logFile -Value "`n--- ICMP Echo Rule ---"
try {
    $icmpRule = Get-NetFirewallRule | Where-Object { $_.DisplayName -like "*ICMP*" -and $_.Enabled -eq "True" }
    if ($icmpRule) {
        Add-Content -Path $logFile -Value "ICMP Echo Requests allowed"
    } else {
        Add-Content -Path $logFile -Value "ICMP Echo Requests NOT allowed"
    }
} catch {
    Add-Content -Path $logFile -Value "Unable to determine ICMP rule status"
}

# Summary
Add-Content -Path $logFile -Value "`n===== Diagnostics Complete ====="

# Optional: Copy to public user folder for easy access
Copy-Item -Path $logFile -Destination "C:\Users\Public\diagnostics.log" -Force
# Optional: Display the log file path
Write-Host "Diagnostics log saved to: C:\Users\Public\diagnostics.log"  
