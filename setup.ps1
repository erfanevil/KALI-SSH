<#
.SYNOPSIS
    KALI-SSH One-Click Setup & Key Exchange
    Developer: EncDev (ENC) (Telegram: https://t.me/jc_org)
#>

$Host.UI.RawUI.WindowTitle = "KALI-SSH Setup"

Write-Host " ========================================================" -ForegroundColor Cyan
Write-Host "           KALI-SSH Initial Setup & Key Exchange         " -ForegroundColor Green
Write-Host "                      [ Owner: ENC ]                     " -ForegroundColor Yellow
Write-Host "                 [ Telegram: t.me/jc_org ]               " -ForegroundColor White
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
$vmx = ""
$user = ""
$pass = ""

if (Test-Path $configFile) {
    try {
        $cfg = Get-Content $configFile -Raw | ConvertFrom-Json
        if ($cfg.vmware_path -and (Test-Path $cfg.vmware_path)) { $vmrun = $cfg.vmware_path }
        if ($cfg.vmx_path -and $cfg.vmx_path -notmatch "path\\to\\your" -and (Test-Path $cfg.vmx_path)) { $vmx = $cfg.vmx_path }
        if ($cfg.guest_username -and $cfg.guest_username -notmatch "your_username") { $user = $cfg.guest_username }
        if ($cfg.guest_password -and $cfg.guest_password -notmatch "your_password") { $pass = $cfg.guest_password }
    } catch {}
}

if (-not $vmx -or (-not (Test-Path $vmx))) {
    Write-Host ""
    $vmx = (Read-Host " [?] Enter full path to your Kali .vmx file").Trim('"')
}

if (-not $user) {
    $user = Read-Host " [?] Enter Kali Linux Username (default: kali)"
    if ([string]::IsNullOrWhiteSpace($user)) { $user = "kali" }
}

if (-not $pass) {
    $pass = Read-Host " [?] Enter Kali Linux Password" -MaskInput
}

if ((Test-Path $vmrun) -and (Test-Path $vmx)) {
    Write-Host " [*] Installing SSH public key into Kali Linux authorized_keys..." -ForegroundColor Gray
    $pubKey = (Get-Content "$keyFile.pub").Trim()
    & $vmrun -gu $user -gp $pass runProgramInGuest $vmx /bin/bash -c "mkdir -p /home/$user/.ssh && chmod 700 /home/$user/.ssh && echo '$pubKey' >> /home/$user/.ssh/authorized_keys && chmod 600 /home/$user/.ssh/authorized_keys" 2>$null
    Write-Host " [+] Passwordless SSH key deployed successfully!" -ForegroundColor Green

    $saveChoice = Read-Host " [?] Save these settings to config.json? (Y/n)"
    if ($saveChoice -ne "n" -and $saveChoice -ne "N") {
        $newConfig = [PSCustomObject]@{
            vmx_path       = $vmx
            vmware_path    = $vmrun
            guest_username = $user
            guest_password = $pass
            fallback_ip    = "192.168.1.100"
            auto_start_vm  = $true
            ssh_port       = 22
        }
        $newConfig | ConvertTo-Json -Depth 4 | Set-Content $configFile -Encoding UTF8
        Write-Host " [+] Settings saved." -ForegroundColor Green
    }
} else {
    Write-Host " [!] Error: Invalid VMware or VMX path specified." -ForegroundColor Red
}

Write-Host ""
Write-Host " [✓] Setup completed! You can now launch Kali-SSH.bat anytime." -ForegroundColor Cyan
Pause
