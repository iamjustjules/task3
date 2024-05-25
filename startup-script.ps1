# PowerShell commands to configure RDP
Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
