# Configure PC

1. (Windows) [Install/update PowerShell.](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.3#installing-the-msi-package)
2. (Windows) Optimize PowerShell performance if possible (requires ngen.exe).
3. (Windows) [Set up OpenSSH-Win64.](./files/setup-ssh.ps1) (Set `ansible_shell_type=powershell` in Ansible invocations.)
4. (Windows) Install Hyper-V. Admin PowerShell: `Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All`.
5. (Windows) Install WSL2: `wsl --install && Restart-Computer`.
6. (Ubuntu) Install Ansible `python3 -m pip install --user ansible`.
7. (Ubuntu) Create hosts file, substituting IP and using correct port:
   ```
   [windows]
   10.0.0.50:55949
   ```
8. (Ubuntu) Copy SSH private key to WSL filesystem and run `chmod 0600`.
9. (Ubuntu) Run `ansible-galaxy role install -r requirements.yml &&
   ansible-galaxy collection install -r requirements.yml`.
10. (Ubuntu) Run Ansible (<kbd>wsl -- …</kbd>).

## Windows

## TODO

- Add vcpkg and install `llvm[clang,clang-tools-extra]`

### Optimize PowerShell performance

https://docs.ansible.com/ansible/latest/user_guide/windows_performance.html#optimize-powershell-performance-to-reduce-ansible-task-overhead

```powershell
function Optimize-PowershellAssemblies {
  # NGEN powershell assembly, improves startup time of powershell by 10x
  $old_path = $env:path
  try {
    $env:path = [Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()
    [AppDomain]::CurrentDomain.GetAssemblies() | % {
      if (! $_.location) {continue}
      $Name = Split-Path $_.location -leaf
      if ($Name.startswith("Microsoft.PowerShell.")) {
        Write-Progress -Activity "Native Image Installation" -Status "$name"
        ngen install $_.location | % {"`t$_"}
      }
    }
  } finally {
    $env:path = $old_path
  }
}
Optimize-PowershellAssemblies
```

### Old style: WinRM

WinRM default ports: 5986 (HTTP), 5987 (HTTPS).

1. (Windows) Set up WinRM. Optional: change port.
2. (Windows) Restrict WinRM port access using firewall.

#### Example PowerShell firewall rule

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

### Working Ansible invocation

```bash
ansible all -i '10.0.0.50,' -m ansible.builtin.setup --private-key id_rsa -u A -e ansible_shell_type=powershell
```

## Intended refactoring

Single YAML list of packages with different attributes, e.g.:

```yaml
- name: some-package
  apt: "some-package==1.2.3"
  scoop: "some-package"
- name: some-other-package
  cargo:
      name: "some-other-package"
      git: "some-repo"
      features: ["feature1", "feature2"]
```

Use custom filters and modules to pull this apart.
