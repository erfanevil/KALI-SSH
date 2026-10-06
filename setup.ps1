<#
.SYNOPSIS
    KALI-SSH One-Click Setup & Key Exchange
    Author: ENC (Telegram: https://t.me/jc_org)
#>

$Host.UI.RawUI.WindowTitle = "KALI-SSH Setup"

Write-Host " ========================================================" -ForegroundColor Cyan
Write-Host "           KALI-SSH Initial Setup & Key Exchange         " -ForegroundColor Green
Write-Host "                      [ Owner: ENC ]                     " -ForegroundColor Yellow
Write-Host " ========================================================" -ForegroundColor Cyan
Write-Host ""

$sshDir = "$env:USERPROFILE\.ssh"
$keyFile = "$sshDir\id_ed25519"

if (-not (Test-Path $sshDir)) {
    New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
}

if (-not (Test-Path $keyFile)) {
    Write-Host " [*] Generating Windows SSH Ed25519 keypair..." -ForegroundColor Gray
    ssh-keygen -t ed25519 -N '""' -f $keyFile
} else {
    Write-Host " [+] Existing SSH key found at: $keyFile" -ForegroundColor Green
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$configFile = Join-Path $scriptDir "config.json"
$vmrun = "C:\Program Files\VMware\VMware Workstation\vmrun.exe"
$vmx = "C:\linux\kali.vmx"
$user = "enc"
$pass = "qaz"

if (Test-Path $configFile) {
    try {
        $cfg = Get-Content $configFile -Raw | ConvertFrom-Json
        if ($cfg.vmware_path) { $vmrun = $cfg.vmware_path }
        if ($cfg.vmx_path) { $vmx = $cfg.vmx_path }
        if ($cfg.guest_username) { $user = $cfg.guest_username }
        if ($cfg.guest_password) { $pass = $cfg.guest_password }
    } catch {}
}

if ((Test-Path $vmrun) -and (Test-Path $vmx)) {
    Write-Host " [*] Installing SSH public key into Kali Linux authorized_keys..." -ForegroundColor Gray
    $pubKey = (Get-Content "$keyFile.pub").Trim()
    & $vmrun -gu $user -gp $pass runProgramInGuest $vmx /bin/bash -c "mkdir -p /home/$user/.ssh && chmod 700 /home/$user/.ssh && echo '$pubKey' >> /home/$user/.ssh/authorized_keys && chmod 600 /home/$user/.ssh/authorized_keys" 2>$null
    Write-Host " [+] Passwordless SSH key deployed successfully!" -ForegroundColor Green
}

Write-Host ""
Write-Host " [✓] Setup completed! You can now run Kali-SSH.bat anytime." -ForegroundColor Cyan
Pause
