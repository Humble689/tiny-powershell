# Tiny Shell - A custom PowerShell shell implementation

# Initialize command history and colors
$script:commandHistory = @()
$script:currentDirectory = Get-Location
$script:promptColor = "Green"
$script:pathColor = "Yellow"
$script:textColor = "White"
$script:errorColor = "Red"
$script:welcomeColor = "Cyan"

function Write-Prompt {
    $host.UI.RawUI.ForegroundColor = $script:promptColor
    Write-Host "tiny-shell" -NoNewline
    $host.UI.RawUI.ForegroundColor = $script:pathColor
    Write-Host " $($pwd.Path)" -NoNewline
    $host.UI.RawUI.ForegroundColor = $script:textColor
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
            "mkdir" {
                if ($args.Count -eq 0) {
                    Write-Host "Usage: mkdir [directory_name]" -ForegroundColor $script:errorColor
                    return
                }
                New-Item -ItemType Directory -Path $args[0] -Force | Out-Null
                Write-Host "Created directory: $($args[0])" -ForegroundColor $script:textColor
            }
            "touch" {
                if ($args.Count -eq 0) {
                    Write-Host "Usage: touch [file_name]" -ForegroundColor $script:errorColor
                    return
                }
                if (-not (Test-Path $args[0])) {
                    New-Item -ItemType File -Path $args[0] -Force | Out-Null
                    Write-Host "Created file: $($args[0])" -ForegroundColor $script:textColor
                } else {
                    (Get-Item $args[0]).LastWriteTime = Get-Date
                    Write-Host "Updated timestamp for: $($args[0])" -ForegroundColor $script:textColor
                }
            }
            "color" {
                if ($args.Count -lt 2) {
                    Write-Host "Usage: color [prompt|path|text|error|welcome] [color]" -ForegroundColor $script:errorColor
                    Write-Host "Available colors: Black, DarkBlue, DarkGreen, DarkCyan, DarkRed, DarkMagenta, DarkYellow, Gray, DarkGray, Blue, Green, Cyan, Red, Magenta, Yellow, White" -ForegroundColor $script:errorColor
                    return
                }
                
                $element = $args[0].ToLower()
                $newColor = $args[1]
                
                switch ($element) {
                    "prompt" { $script:promptColor = $newColor }
                    "path" { $script:pathColor = $newColor }
                    "text" { $script:textColor = $newColor }
                    "error" { $script:errorColor = $newColor }
                    "welcome" { $script:welcomeColor = $newColor }
                    default {
                        Write-Host "Invalid color element. Use: prompt, path, text, error, or welcome" -ForegroundColor $script:errorColor
                    }
                }
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
        Write-Host "Error: $_" -ForegroundColor $script:errorColor
    }
}

# Main shell loop
Write-Host "Welcome to Tiny Shell!" -ForegroundColor $script:welcomeColor
Write-Host "Type 'exit' to quit" -ForegroundColor $script:welcomeColor
Write-Host "Type 'color [element] [color]' to change colors" -ForegroundColor $script:welcomeColor
Write-Host "Type 'mkdir [name]' to create directory" -ForegroundColor $script:welcomeColor
Write-Host "Type 'touch [name]' to create file" -ForegroundColor $script:welcomeColor
Write-Host "" # empty line

while ($true) {
    Write-Prompt
    $command = Read-Host
    
    if ($command) {
        Invoke-Command -command $command
    }
} 