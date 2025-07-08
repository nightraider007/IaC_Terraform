# === Comprehensive VM Network & Firewall Diagnostic and Fix Script ===

Write-Host "=== Starting VM Network & Firewall Diagnostics ===" -ForegroundColor Cyan

# 1. IP Configuration
Write-Host "`n1. IP Configuration:" -ForegroundColor Green
Get-NetIPAddress | Where-Object {$_.AddressFamily -eq "IPv4"} | Format-Table InterfaceAlias, IPAddress, PrefixLength, AddressState

# 2. Default Gateway
Write-Host "`n2. Default Gateway:" -ForegroundColor Green
Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Format-Table ifIndex, DestinationPrefix, NextHop, RouteMetric, PolicyStore

# 3. Public IP check (try external call)
Write-Host "`n3. Public IP from VM (external check):" -ForegroundColor Green
try {
    $publicIp = (Invoke-RestMethod -Uri "http://ipinfo.io/ip").Trim()
    Write-Host $publicIp
} catch {
    Write-Host "Unable to retrieve public IP." -ForegroundColor Yellow
}

# 4. Test DNS resolution for external domain
Write-Host "`n4. Test DNS resolution for 'www.google.com':" -ForegroundColor Green
try {
    Resolve-DnsName www.google.com | Select-Object -First 3
    Write-Host "DNS resolution successful" -ForegroundColor Green
} catch {
    Write-Host "DNS resolution failed" -ForegroundColor Red
}

# 5. Firewall Rules: check and create if missing
Write-Host "`n5. Firewall Rules Status and Creation:" -ForegroundColor Green

$rules = @(
    @{Name='Allow RDP (3389)'; Port=3389; Protocol='TCP'},
    @{Name='Allow HTTP (80)'; Port=80; Protocol='TCP'},
    @{Name='Allow ICMPv4'; Port=$null; Protocol='ICMPv4'}
)

foreach ($rule in $rules) {
    $existingRule = Get-NetFirewallRule -DisplayName $rule.Name -ErrorAction SilentlyContinue
    if ($existingRule) {
        Write-Host "Rule '$($rule.Name)' is ENABLED" -ForegroundColor Green
    } else {
        Write-Host "Rule '$($rule.Name)' NOT FOUND, creating..." -ForegroundColor Yellow
        if ($rule.Protocol -eq 'ICMPv4') {
            New-NetFirewallRule -DisplayName $rule.Name -Direction Inbound -Protocol ICMPv4 -IcmpType 8 -Action Allow
        } else {
            New-NetFirewallRule -DisplayName $rule.Name -Direction Inbound -Protocol $rule.Protocol -LocalPort $rule.Port -Action Allow
        }
        Write-Host "Rule '$($rule.Name)' created and ENABLED" -ForegroundColor Green
    }
}

# 6. Listening Ports for RDP, HTTP
Write-Host "`n6. Listening Ports for RDP (3389) and HTTP (80):" -ForegroundColor Green
Get-NetTCPConnection -LocalPort 3389,80 -State Listen | Format-Table -Property LocalAddress, LocalPort, State, OwningProcess

# 7. ICMP Status
Write-Host "`n7. ICMP Echo Requests Allowed?" -ForegroundColor Green
try {
    $icmpRule = Get-NetFirewallRule | Where-Object { $_.DisplayName -like "*ICMP*" -and $_.Enabled -eq "True" }
    if ($icmpRule) {
        Write-Host "ICMP Echo Requests allowed" -ForegroundColor Green
    } else {
        Write-Host "ICMP Echo Requests NOT allowed" -ForegroundColor Red
    }
} catch {
    Write-Host "Unable to determine ICMP rule status" -ForegroundColor Yellow
}

# 8. Test connectivity to Azure Metadata Service
Write-Host "`n8. Testing connectivity to Azure Metadata Service..." -ForegroundColor Green
try {
    $mdsResponse = Invoke-RestMethod -Headers @{"Metadata"="true"} -Uri "http://169.254.169.254/metadata/instance?api-version=2021-02-01"
    Write-Host "Metadata service reachable" -ForegroundColor Green
} catch {
    Write-Host "Metadata service NOT reachable" -ForegroundColor Red
}

# Summary
Write-Host "`n=== Diagnostic Summary ===" -ForegroundColor Cyan
Write-Host "- Confirm firewall rules for RDP, HTTP, and ICMP are enabled."
Write-Host "- Ensure listening services are active on ports 3389 and 80."
Write-Host "- Confirm VM can resolve DNS and access external network."
Write-Host "- Confirm Azure Metadata service is reachable."
Write-Host "- Validate default gateway and IP configuration."
Write-Host "`nScript complete." -ForegroundColor Cyan
