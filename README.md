# Tiny Shell

A custom PowerShell shell implementation that provides a simplified command-line interface with basic command handling capabilities.

## Features

- Custom prompt showing current directory
- Command history tracking
- Basic command support:
  - `cd`: Change directory
  - `ls`: List directory contents
  - `pwd`: Print working directory
  - `clear`: Clear the screen
  - `history`: Show command history
  - `exit`: Exit the shell
- Support for native PowerShell commands
- Error handling with colored output

## Usage

1. Open PowerShell
2. Navigate to the directory containing `tiny_shell.ps1`
3. Run the script:
   ```powershell
   .\tiny_shell.ps1
   ```

## Commands

- `cd [path]`: Change to the specified directory. If no path is provided, changes to home directory
- `ls`: List files and directories in the current location
- `pwd`: Display the current working directory
- `clear`: Clear the terminal screen
- `history`: Display command history
- `exit`: Exit the shell

## Customization

The shell prompt can be customized by modifying the `Write-Prompt` function in the script. The current implementation shows:
- Shell name in green
- Current directory in yellow
- Command prompt in whit  e  ashkjv

## Error Handling

The shell includes basic error handling that will display error messages in red when commands fail to execute properly. 