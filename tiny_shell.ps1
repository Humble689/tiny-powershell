# Tiny Shell - A custom PowerShell shell implementation

# Initialize command history
$script:commandHistory = @()
$script:currentDirectory = Get-Location

function Write-Prompt {
    $host.UI.RawUI.ForegroundColor = "Green"
    Write-Host "tiny-shell" -NoNewline
    $host.UI.RawUI.ForegroundColor = "Yellow"
    Write-Host " $($pwd.Path)" -NoNewline
    $host.UI.RawUI.ForegroundColor = "White"
    Write-Host " > " -NoNewline
}

function Invoke-Command {
    param (
        [string]$command
    )
    
    # adds command history
    $script:commandHistory += $command
    
    # Split command into parts
    $parts = $command -split '\s+'
    $cmd = $parts[0]
    $args = $parts[1..($parts.Length-1)]
    
    try {
        switch ($cmd.ToLower()) {
            "cd" {
                if ($args.Count -eq 0) {
                    Set-Location $HOME
                } else {
                    Set-Location $args[0]
                }
                $script:currentDirectory = Get-Location
            }
            # lists files in current directory
            "ls" {
                Get-ChildItem | Format-Table Name, Length, LastWriteTime
            }
            "pwd" {
                Write-Host $pwd.Path
            }
            "clear" {
                Clear-Host
            }
            "history" {
                $script:commandHistory | ForEach-Object { Write-Host $_ } # lists command history
            }
            "exit" {
                exit
            }
            default {
                # Try to execute as a native PowerShell command
                Invoke-Expression $command
            }
        }
    }
    catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
}

# Main shell loop
Write-Host "Welcome to Tiny Shell!" -ForegroundColor Cyan
Write-Host "Type 'exit' to quit" -ForegroundColor Cyan
Write-Host "" # empty line

while ($true) {
    Write-Prompt
    $command = Read-Host
    
    if ($command) {
        Invoke-Command -command $command
    }
} 