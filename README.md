# powershell-default-printer
A simple PowerShell script to set the default printer on Windows.

## Usage
1. Clone repository
2. Edit config file and add networks and according printers + set fallback printer
3. Open Task-Scheduler
4. Create a new Task
5. Name: SetDefaultPrinter
6. Trigger: At logon
7. Action: powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Path\to\SetDefaultPrinter.ps1"