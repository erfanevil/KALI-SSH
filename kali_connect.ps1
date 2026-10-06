<#
.SYNOPSIS
    KALI-SSH - Automated VMware to Kali Linux SSH Bridge
    Developer: EncDev (ENC)
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

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$configFile = Join-Path $scriptDir "config.json"

# Default VMware executable path detection
$defaultVmrun = "C:\Program Files\VMware\VMware Workstation\vmrun.exe"
if (-not (Test-Path $defaultVmrun)) {
    $altVmrun = "C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe"
    if (Test-Path $altVmrun) { $defaultVmrun = $altVmrun }
}

$vmrun = $defaultVmrun
$vmx = ""
$user = ""
$pass = ""
$fallbackIP = "192.168.1.100"

# Read existing configuration if available
$configData = $null
if (Test-Path $configFile) {
    try {
        $configData = Get-Content $configFile -Raw | ConvertFrom-Json
        if ($configData.vmware_path -and (Test-Path $configData.vmware_path)) { $vmrun = $configData.vmware_path }
        if ($configData.vmx_path -and $configData.vmx_path -notmatch "path\\to\\your" -and (Test-Path $configData.vmx_path)) { $vmx = $configData.vmx_path }
        if ($configData.guest_username -and $configData.guest_username -notmatch "your_username") { $user = $configData.guest_username }
        if ($configData.guest_password -and $configData.guest_password -notmatch "your_password") { $pass = $configData.guest_password }
        if ($configData.fallback_ip -and $configData.fallback_ip -notmatch "192.168.x") { $fallbackIP = $configData.fallback_ip }
    } catch {
        Write-Host " [!] Warning: Error parsing config.json." -ForegroundColor DarkYellow
    }
}

# Prompt for VMware executable if not found
if (-not (Test-Path $vmrun)) {
    Write-Host " [?] VMware 'vmrun.exe' not found automatically." -ForegroundColor Yellow
    $vmrun = Read-Host " [*] Enter full path to vmrun.exe"
    while (-not (Test-Path $vmrun)) {
        Write-Host " [!] Path not found, please try again." -ForegroundColor Red
        $vmrun = Read-Host " [*] Enter full path to vmrun.exe"
    }
}

# Prompt for VMX file path if not set or invalid
if (-not $vmx -or (-not (Test-Path $vmx))) {
    Write-Host ""
    Write-Host " [?] Kali Linux .vmx path is required." -ForegroundColor Yellow
    
    # Try searching for a default Kali VMX
    $suggestedVMX = Get-ChildItem -Path "$env:USERPROFILE\Documents\Virtual Machines", "C:\linux", "D:\", "E:\" -Filter "*.vmx" -Recurse -Depth 3 -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
    if ($suggestedVMX) {
        Write-Host " [*] Detected candidate: $suggestedVMX" -ForegroundColor Gray
        $inputVMX = Read-Host " [*] Press Enter to accept candidate, or type full path"
        if ([string]::IsNullOrWhiteSpace($inputVMX)) {
            $vmx = $suggestedVMX
        } else {
            $vmx = $inputVMX.Trim('"')
        }
    } else {
        $vmx = (Read-Host " [*] Enter full path to your Kali .vmx file").Trim('"')
    }

    while (-not (Test-Path $vmx)) {
        Write-Host " [!] File not found: '$vmx'" -ForegroundColor Red
        $vmx = (Read-Host " [*] Enter full path to your Kali .vmx file").Trim('"')
    }
}

# Prompt for Username if not set
if (-not $user) {
    Write-Host ""
    $user = Read-Host " [?] Enter Kali Linux Username (default: kali)"
    if ([string]::IsNullOrWhiteSpace($user)) { $user = "kali" }
}

# Prompt for Password if not set
if (-not $pass) {
    $pass = Read-Host " [?] Enter Kali Linux Password" -MaskInput
    if ([string]::IsNullOrWhiteSpace($pass)) { $pass = "kali" }
}

# Ask to save configuration
if ($configData.guest_username -match "your_username" -or (-not (Test-Path $configFile))) {
    Write-Host ""
    $saveChoice = Read-Host " [?] Save these settings to config.json for next time? (Y/n)"
    if ($saveChoice -ne "n" -and $saveChoice -ne "N") {
        $newConfig = [PSCustomObject]@{
            vmx_path       = $vmx
            vmware_path    = $vmrun
            guest_username = $user
            guest_password = $pass
            fallback_ip    = $fallbackIP
            auto_start_vm  = $true
            ssh_port       = 22
        }
        $newConfig | ConvertTo-Json -Depth 4 | Set-Content $configFile -Encoding UTF8
        Write-Host " [+] Configuration saved to config.json." -ForegroundColor Green
    }
}

Write-Host ""
Write-Host " [*] Checking Virtual Machine status..." -ForegroundColor Gray
$runningVMs = & $vmrun list

if ($runningVMs -notmatch [regex]::Escape($vmx)) {
    Write-Host " [>] Kali Linux is offline. Booting up headless..." -ForegroundColor Yellow
    & $vmrun start $vmx nogui
    Write-Host " [*] Waiting for Kali network services to start..." -ForegroundColor Gray
    Start-Sleep -Seconds 12
} else {
    Write-Host " [+] Kali Linux is already running." -ForegroundColor Green
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
