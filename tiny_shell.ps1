# Tiny Shell - A custom PowerShell shell implementation

# Initialize command history and colors
$script:commandHistory = @()
$script:currentDirectory = Get-Location
$script:promptColor = "Green"
$script:pathColor = "Yellow"
$script:textColor = "White"
$script:errorColor = "Red"
$script:welcomeColor = "Cyan"

# Initialize aliases
$script:aliases = @{
    "ll" = "ls -l"
    "la" = "ls -a"
    ".." = "cd .."
    "..." = "cd ../.."
}

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
    
    # Check for history command with ! prefix
    if ($command -match '^!(\d+)$') {
        $index = [int]$Matches[1]
        if ($index -ge 0 -and $index -lt $script:commandHistory.Count) {
            $command = $script:commandHistory[$index]
            Write-Host "Executing: $command" -ForegroundColor $script:textColor
        } else {
            Write-Host "History index out of range" -ForegroundColor $script:errorColor
            return
        }
    }
    
    # Check for aliases
    if ($script:aliases.ContainsKey($command)) {
        $command = $script:aliases[$command]
    }
    
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
            "ls" {
                if ($args -contains "-l") {
                    Get-ChildItem | Format-Table Mode, Length, LastWriteTime, Name
                } elseif ($args -contains "-a") {
                    Get-ChildItem -Force | Format-Table Name, Length, LastWriteTime
                } else {
                    Get-ChildItem | Format-Table Name, Length, LastWriteTime
                }
            }
            "pwd" {
                Write-Host $pwd.Path
            }
            "clear" {
                Clear-Host
            }
            "history" {
                for ($i = 0; $i -lt $script:commandHistory.Count; $i++) {
                    Write-Host "$i : $($script:commandHistory[$i])"
                }
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
            "rm" {
                if ($args.Count -eq 0) {
                    Write-Host "Usage: rm [file_or_directory]" -ForegroundColor $script:errorColor
                    return
                }
                Remove-Item -Path $args[0] -Recurse -Force
                Write-Host "Removed: $($args[0])" -ForegroundColor $script:textColor
            }
            "mv" {
                if ($args.Count -lt 2) {
                    Write-Host "Usage: mv [source] [destination]" -ForegroundColor $script:errorColor
                    return
                }
                Move-Item -Path $args[0] -Destination $args[1] -Force
                Write-Host "Moved $($args[0]) to $($args[1])" -ForegroundColor $script:textColor
            }
            "cp" {
                if ($args.Count -lt 2) {
                    Write-Host "Usage: cp [source] [destination]" -ForegroundColor $script:errorColor
                    return
                }
                Copy-Item -Path $args[0] -Destination $args[1] -Force
                Write-Host "Copied $($args[0]) to $($args[1])" -ForegroundColor $script:textColor
            }
            "cat" {
                if ($args.Count -eq 0) {
                    Write-Host "Usage: cat [file_name]" -ForegroundColor $script:errorColor
                    return
                }
                Get-Content -Path $args[0]
            }
            "echo" {
                if ($args.Count -lt 2) {
                    Write-Host "Usage: echo [text] > [file_name]" -ForegroundColor $script:errorColor
                    return
                }
                $text = $args[0..($args.Count-2)] -join " "
                $file = $args[-1]
                Set-Content -Path $file -Value $text
                Write-Host "Wrote to file: $file" -ForegroundColor $script:textColor
            }
            "date" {
                Get-Date
            }
            "whoami" {
                Write-Host $env:USERNAME
            }
            "sysinfo" {
                Write-Host "System Information:" -ForegroundColor $script:textColor
                Write-Host "OS: $((Get-CimInstance Win32_OperatingSystem).Caption)"
                Write-Host "Version: $((Get-CimInstance Win32_OperatingSystem).Version)"
                Write-Host "Architecture: $((Get-CimInstance Win32_OperatingSystem).OSArchitecture)"
                Write-Host "Computer Name: $env:COMPUTERNAME"
                Write-Host "User: $env:USERNAME"
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
            "help" {
                Write-Host "Available Commands:" -ForegroundColor $script:textColor
                Write-Host "cd [path] - Change directory"
                Write-Host "ls [-l|-a] - List files (use -l for details, -a for hidden files)"
                Write-Host "pwd - Show current directory"
                Write-Host "clear - Clear screen"
                Write-Host "history - Show command history"
                Write-Host "mkdir [name] - Create directory"
                Write-Host "touch [name] - Create file"
                Write-Host "rm [name] - Remove file/directory"
                Write-Host "mv [source] [dest] - Move/rename file"
                Write-Host "cp [source] [dest] - Copy file"
                Write-Host "cat [file] - View file contents"
                Write-Host "echo [text] > [file] - Write to file"
                Write-Host "date - Show current date/time"
                Write-Host "whoami - Show current user"
                Write-Host "sysinfo - Show system information"
                Write-Host "color [element] [color] - Change colors"
                Write-Host "help - Show this help message"
                Write-Host "exit - Exit shell"
                Write-Host ""
                Write-Host "Aliases:" -ForegroundColor $script:textColor
                Write-Host "ll - ls -l (detailed listing)"
                Write-Host "la - ls -a (show hidden files)"
                Write-Host ".. - cd .. (parent directory)"
                Write-Host "... - cd ../.. (grandparent directory)"
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
Write-Host "Type 'help' for available commands" -ForegroundColor $script:welcomeColor
Write-Host "Type 'exit' to quit" -ForegroundColor $script:welcomeColor
Write-Host "" # empty line

while ($true) {
    Write-Prompt
    $command = Read-Host
    
    if ($command) {
        Invoke-Command -command $command
    }
} 