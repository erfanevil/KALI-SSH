<#
.SYNOPSIS
    KALI-SSH - Automated VMware to Kali Linux SSH Bridge
    Author: ENC
    Telegram: https://t.me/jc_org
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "KALI-SSH | Owner: ENC"

Clear-Host
Write-Host ""
Write-Host " ======================================================================" -ForegroundColor Cyan
Write-Host "  _  __    _    _     ___        ____ ____  _   _ " -ForegroundColor Green
Write-Host " | |/ /   / \  | |   |_ _|      / ___/ ___|| | | |" -ForegroundColor Green
Write-Host " | ' /   / _ \ | |    | | _____ \___ \___ \| |_| |" -ForegroundColor Green
Write-Host " | . \  / ___ \| |___ | ||_____| ___) |___) |  _  |" -ForegroundColor Green
Write-Host " |_|\_\/_/   \_\_____|___|      |____/|____/|_| |_|" -ForegroundColor Green
Write-Host ""
Write-Host "                       [ OWNER : ENC ]" -ForegroundColor Yellow
Write-Host "                  [ Telegram : t.me/jc_org ]" -ForegroundColor White
Write-Host "            Kali Linux Auto-Connector & SSH Bridge" -ForegroundColor DarkCyan
Write-Host " ======================================================================" -ForegroundColor Cyan
Write-Host ""

# Default parameters
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$configFile = Join-Path $scriptDir "config.json"

$vmrun = "C:\Program Files\VMware\VMware Workstation\vmrun.exe"
$vmx = "C:\linux\kali.vmx"
$user = "enc"
$pass = "qaz"
$fallbackIP = "192.168.1.85"

if (Test-Path $configFile) {
    try {
        $cfg = Get-Content $configFile -Raw | ConvertFrom-Json
        if ($cfg.vmware_path) { $vmrun = $cfg.vmware_path }
        if ($cfg.vmx_path) { $vmx = $cfg.vmx_path }
        if ($cfg.guest_username) { $user = $cfg.guest_username }
        if ($cfg.guest_password) { $pass = $cfg.guest_password }
        if ($cfg.fallback_ip) { $fallbackIP = $cfg.fallback_ip }
    } catch {
        Write-Host " [!] Warning: Could not parse config.json, using defaults." -ForegroundColor DarkYellow
    }
}

if (-not (Test-Path $vmrun)) {
    Write-Host " [!] Error: VMware vmrun.exe not found at: $vmrun" -ForegroundColor Red
    Pause
    Exit 1
}

if (-not (Test-Path $vmx)) {
    Write-Host " [!] Error: VM image file not found at: $vmx" -ForegroundColor Red
    Pause
    Exit 1
}

Write-Host " [*] Checking Virtual Machine status..." -ForegroundColor Gray
$runningVMs = & $vmrun list

if ($runningVMs -notmatch [regex]::Escape($vmx)) {
    Write-Host " [>] Kali Linux is offline. Booting up headless..." -ForegroundColor Yellow
    & $vmrun start $vmx nogui
    Write-Host " [*] Waiting for Kali network services to start..." -ForegroundColor Gray
    Start-Sleep -Seconds 12
} else {
    Write-Host " [+] Kali Linux is active." -ForegroundColor Green
}

Write-Host " [*] Detecting Kali IP address..." -ForegroundColor Gray
$kaliIP = (& $vmrun getGuestIPAddress $vmx -wait).Trim()

if (-not $kaliIP -or $kaliIP -match "Error") {
    $kaliIP = $fallbackIP
}
Write-Host " [+] Target IP: $kaliIP" -ForegroundColor Green

Write-Host " [*] Verifying SSH daemon on Kali..." -ForegroundColor Gray
& $vmrun -gu $user -gp $pass runProgramInGuest $vmx /bin/bash -c "echo $pass | sudo -S systemctl enable --now ssh" 2>$null

Write-Host " [*] Testing TCP port 22..." -ForegroundColor Gray
$portCheck = Test-NetConnection -ComputerName $kaliIP -Port 22 -WarningAction SilentlyContinue

if ($portCheck.TcpTestSucceeded) {
    Write-Host " [+] SSH Port 22 is OPEN." -ForegroundColor Green
    Write-Host ""
    Write-Host " [>>>] Establishing SSH session (Owner: ENC)..." -ForegroundColor Magenta
    Write-Host " ======================================================================" -ForegroundColor Cyan
    Start-Sleep -Seconds 1
    ssh -o StrictHostKeyChecking=accept-new "${user}@${kaliIP}"
} else {
    Write-Host " [!] Port 22 unreachable. Check VM network adapter." -ForegroundColor Red
    Pause
}
