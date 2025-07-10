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
Write-Host "Running diagnostics..."

# 1. IP Info
Get-NetIPAddress | Where-Object { $_.AddressFamily -eq "IPv4" } | Format-Table InterfaceAlias, IPAddress, PrefixLength | Out-File -Append C:\AzureVM-Diagnostics.log

# 2. Default Gateway
Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Format-Table ifIndex, NextHop | Out-File -Append C:\AzureVM-Diagnostics.log

# 3. External IP
try {
    $publicIp = (Invoke-RestMethod -Uri "http://ipinfo.io/ip").Trim()
    Add-Content -Path C:\AzureVM-Diagnostics.log -Value "Public IP: $publicIp"
} catch {
    Add-Content -Path C:\AzureVM-Diagnostics.log -Value "Unable to get public IP"
}

# 4. DNS resolution
try {
    Resolve-DnsName www.google.com | Out-File -Append C:\AzureVM-Diagnostics.log
} catch {
    Add-Content -Path C:\AzureVM-Diagnostics.log -Value "DNS resolution failed"
}

# 5. IMDS check
try {
    Invoke-RestMethod -Headers @{"Metadata"="true"} -Uri "http://169.254.169.254/metadata/instance?api-version=2021-02-01"
    Add-Content -Path C:\AzureVM-Diagnostics.log -Value "IMDS reachable"
} catch {
    Add-Content -Path C:\AzureVM-Diagnostics.log -Value "IMDS NOT reachable"
}

Add-Content -Path C:\AzureVM-Diagnostics.log -Value "`nDiagnostics complete."
