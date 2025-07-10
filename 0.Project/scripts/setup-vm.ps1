# ===================================================================
# setup-vm.ps1  — Placeholder script for VM post‑provisioning
# ===================================================================

# Write a header to the log
$logPath = "C:\setup-vm-placeholder.log"
"========================================" | Out-File   $logPath -Encoding utf8
"Placeholder setup-vm.ps1 started at $(Get-Date)" | Out-File   $logPath -Append -Encoding utf8

# Example operations (currently no‑ops)
Write-Host "Running placeholder VM setup script..."  
"    [INFO] Placeholder step 1: no action"      | Out-File   $logPath -Append -Encoding utf8
"    [INFO] Placeholder step 2: no action"      | Out-File   $logPath -Append -Encoding utf8

# Finalize
"Placeholder setup-vm.ps1 completed at $(Get-Date)" | Out-File   $logPath -Append -Encoding utf8
"========================================`n"          | Out-File   $logPath -Append -Encoding utf8

Write-Host "Placeholder script run complete; log available at $logPath"
