<p align="center">
  <h1 align="center">⚡ KALI-SSH ⚡</h1>
  <p align="center">
    <b>Automated, One-Click SSH Bridge from Windows to VMware Kali Linux</b>
  </p>
  <p align="center">
    <img src="https://img.shields.io/badge/Owner-ENC-brightgreen.svg" alt="Owner: ENC">
    <a href="https://t.me/jc_org"><img src="https://img.shields.io/badge/Telegram-@jc__org-blue.svg?logo=telegram" alt="Telegram"></a>
    <img src="https://img.shields.io/badge/Platform-Windows%20%7C%20VMware-blueviolet.svg" alt="Platform">
    <img src="https://img.shields.io/badge/Shell-PowerShell%20%7C%20Bash-informational.svg" alt="Shell">
    <img src="https://img.shields.io/badge/License-MIT-orange.svg" alt="License">
  </p>
</p>

```text
 ======================================================================
  _  __    _    _     ___        ____ ____  _   _ 
 | |/ /   / \  | |   |_ _|      / ___/ ___|| | | |
 | ' /   / _ \ | |    | | _____ \___ \___ \| |_| |
 | . \  / ___ \| |___ | ||_____| ___) |___) |  _  |
 |_|\_\/_/   \_\_____|___|      |____/|____/|_| |_|

                       [ OWNER : ENC ]
                  [ Telegram : t.me/jc_org ]
            Kali Linux Auto-Connector & SSH Bridge
 ======================================================================
```

---

## 📌 معرفی (Overview)
**KALI-SSH** یک ابزار اتوماسیون هوشمند و سریع برای سیستم‌عامل ویندوز است که مدیریت، راه‌اندازی و اتصال پایدار SSH به ماشین مجازی کالی لینوکس (VMware Workstation) را به صورت کاملاً خودکار انجام می‌دهد. 

دیگر نیازی به باز کردن دستی VMware، چک کردن IP یا فعال‌سازی دستی سرویس SSH در ترمینال کالی نیست. با اجرای یک کلیک، تمام مراحل در کسری از ثانیه انجام شده و شل امن SSH پیش روی شما قرار می‌گیرد.

---

## ✨ ویژگی‌ها (Features)

* 🚀 **اتصال تک‌کلیکی (1-Click Launch):** اجرای سریع از طریق فایل `Kali-SSH.bat` بدون نیاز به تنظیمات پیچیده.
* 🤖 **تشخیص خودکار وضعیت ماشین (Auto-Boot):** در صورتی که ماشین مجازی خاموش باشد، ابزار به‌صورت خودکار و در پس‌زمینه (Headless / nogui) کالی را روشن می‌کند.
* 🌐 **کشف داینامیک IP (Dynamic IP Acquisition):** بدون نیاز به داشتن IP ثابت، آدرس آی‌پی کالی را در لحظه از VMware Tools استخراج می‌کند.
* 🔒 **فعال‌سازی خودکار دیمن SSH:** در صورت غیرفعال یا متوقف بودن سرویس SSH در کالی، به صورت ریموت آن را استارت و پایدار می‌کند.
* 🔑 **احراز هویت بدون پسورد (Passwordless Key Auth):** تبادل خودکار کلیدهای امنیتی Ed25519 بین ویندوز و کالی لینوکس.
* ⚙️ **شخصی‌سازی آسان (Configurable):** قابلیت سفارشی‌سازی مسیرها و اطلاعات کاربری از طریق فایل استاندارد `config.json`.

---

## 📋 پیش‌نیازها (Prerequisites)

1. سیستم‌عامل ویندوز ۱۰ یا ۱۱
2. نرم‌افزار **VMware Workstation Pro / Player**
3. ابزار **VMware Tools** (`open-vm-tools`) نصب شده روی ماشین کالی لینوکس
4. کلاینت **OpenSSH** فعال روی ویندوز (به‌طور پیش‌فرض در ویندوز ۱۰ و ۱۱ موجود است)

---

## 🚀 نحوه نصب و راه‌اندازی (Quick Start)

### ۱. کلون کردن ریپازیتوری
```powershell
git clone https://github.com/erfanevil/KALI-SSH.git
cd KALI-SSH
```

### ۲. راه‌اندازی اولیه و تبادل کلید (فقط یک‌بار)
روی اسکریپت `setup.ps1` راست‌کلیک کرده و **Run with PowerShell** را بزنید یا در ترمینال اجرا کنید:
```powershell
powershell -ExecutionPolicy Bypass -File setup.ps1
```
> این اسکریپت کلید عمومی سیستم شما را به `authorized_keys` کالی اضافه می‌کند تا نیازی به وارد کردن مکرر رمز عبور نباشد.

### ۳. اتصال
کافیست روی **`Kali-SSH.bat`** دابل‌کلیک کنید!

---

## ⚙️ تنظیمات (`config.json`)

برای تغییر مسیر ماشین مجازی، نام کاربری یا پورت، فایل `config.json` را مطابق نیاز خود ویرایش کنید:

```json
{
  "vmx_path": "C:\\linux\\kali.vmx",
  "vmware_path": "C:\\Program Files\\VMware\\VMware Workstation\\vmrun.exe",
  "guest_username": "enc",
  "guest_password": "qaz",
  "fallback_ip": "192.168.1.85",
  "auto_start_vm": true,
  "ssh_port": 22
}
```

---

## 🛠️ ساختار پروژه (Repository Structure)

```text
KALI-SSH/
├── Kali-SSH.bat        # لانچر ویندوز جهت دابل‌کلیک
├── kali_connect.ps1    # هسته اسکریپت پاورشل (کشف، استارت و اتصال)
├── setup.ps1           # اسکریپت راه‌اندازی اولیه و تبادل کلید SSH
├── config.json         # فایل پیکربندی پارامترها
├── .gitignore          # نادیده گرفتن فایل‌های حساس و کلیدها
├── LICENSE             # مجوز متن‌باز MIT
└── README.md           # مستندات و راهنمای پروژه
```

---

## 👤 سازنده و مالک (Owner & Credits)

* **Owner & Developer:** **ENC**
* **Telegram Channel / Support:** [@jc_org](https://t.me/jc_org)

---

## 📄 لایسنس (License)
این پروژه تحت پروانه [MIT License](LICENSE) منتشر شده است. استفاده و اشتراک‌گذاری آزاد است.
