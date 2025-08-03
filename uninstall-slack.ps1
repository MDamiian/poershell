$computers = Get-Content -Path "C:\computers.txt"

foreach ($computer in $computers) {
    if (Test-NetConnection -ComputerName $computer -Port 5985 -WarningAction SilentlyContinue) {
        Invoke-Command -ComputerName $computer -ScriptBlock {
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
        }
    }

    else {
        Write-Output "$computer is not reachable on port 5985"
    }
}