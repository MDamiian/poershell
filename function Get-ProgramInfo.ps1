 function Get-ProgramInfo {
    param (
        [string]$ProgramName
    )
    $UninstallPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    foreach ($Path in $UninstallPaths) {
        $Programs = Get-ItemProperty -Path $Path -ErrorAction SilentlyContinue |
                    Where-Object { $_.DisplayName -like "*$ProgramName*" }
        foreach ($program in $Programs) {
            [PSCustomObject]@{
                DisplayName     = $program.DisplayName
                DisplayVersion  = $program.DisplayVersion
                PSChildName       = $program.PSChildName
                UninstallString = $program.UninstallString
            }
        }
    }
}

Get-ProgramInfo -ProgramName "Slack"