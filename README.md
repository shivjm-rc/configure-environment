# Configure PC

## Windows

WinRM default ports: 5986 (HTTP), 5987 (HTTPS).

1. (Windows) Install/update PowerShell.
2. (Windows) Install WSL2.
3. (WSL2) Install Ansible.
4. (Windows) Set up WinRM. Optional: change port.
5. (Windows) Restrict WinRM port access using firewall.
6. (WSL2) Run Ansible (<kbd>wsl -- …</kbd>).

### Example PowerShell firewall rule

```powershell
$FirewallParam = @{
     DisplayName = 'Custom WinRM Port Rule'
     Direction = 'Inbound'
     LocalPort = 
     Protocol = 'TCP'
     Action = 'Allow'
     Program = 'System'
 }
 New-NetFirewallRule @FirewallParam
```
