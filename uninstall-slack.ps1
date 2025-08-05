$computers = Get-Content -Path "C:\computers.txt"

foreach ($computer in $computers) {
    if (Test-NetConnection -ComputerName $computer -Port 5985 -WarningAction SilentlyContinue) {
        Invoke-Command -ComputerName $computer -ScriptBlock {
            function Get-PSChildName {
                param ([string]$ProgramName)
                $UninstallPaths = @(
                    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
                    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
                    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
                )
                foreach ($Path in $UninstallPaths) {
                    $ProgramInfo = Get-ItemProperty -Path $Path -ErrorAction SilentlyContinue | 
                    Where-Object { $_.DisplayName -like "*$ProgramName*" }
                    if ($ProgramInfo) {
                        return $ProgramInfo.PSChildName
                    }
                }
                return $null
            }

            # Remover carpetas por usuario
            Get-ChildItem -Path "C:\Users" -Directory | ForEach-Object {
                $user = $_.Name
                $path = "C:\Users\$user\AppData\Local\slack"
                if (Test-Path -Path $path) {
                    $updatePath = "C:\Users\$user\AppData\Local\slack\Update.exe"
                    if (Test-Path -Path $updatePath) {
                        & $updatePath --uninstall --silent --force --quiet
                        Start-Sleep -Seconds 2
                    }
                    Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
                    Remove-Item -Path "C:\Users\$user\AppData\Roaming\Slack" -Recurse -Force -ErrorAction SilentlyContinue
                    Write-Output "Slack uninstalled for user $user on $env:COMPUTERNAME"
                }
            }

            # Desinstalar Slack máquina solo una vez
            $PSChildName = Get-PSChildName -ProgramName "Slack (Machine - MSI)"
            if ($PSChildName) {
                Start-Process msiexec.exe -ArgumentList "/X", "`"$PSChildName`"", "/qn", "/norestart" -Wait
                Write-Output "Slack uninstalled for machine on $env:COMPUTERNAME"
                Start-Sleep -Seconds 2
            }
            else {
                Write-Output "Slack uninstall string not found for machine on $env:COMPUTERNAME"
            }
        }
    }
    else {
        Write-Output "$computer is not reachable on port 5985"
    }
}
