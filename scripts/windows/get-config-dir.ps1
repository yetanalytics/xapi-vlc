# Define a function to get the VLC configuration directory
function Get-VLCConfigDirectory {
    # Get the APPDATA environment variable
    $configDir = "$env:APPDATA\vlc\"

    # Check if the directory path is defined
    if (-not $configDir) {
        Write-Error "Could not determine VLC configuration directory."
        return $null
    }

    # Ensure the directory exists; create it if it doesn't
    if (-not (Test-Path -Path $configDir)) {
        try {
            New-Item -ItemType Directory -Path $configDir -Force | Out-Null
        } catch {
            Write-Error "Failed to create directory: $configDir"
            return $null
        }
    }

    # Output the config directory path
    return $configDir
}

# Call the function and store the result in a variable
$configDir = Get-VLCConfigDirectory

# Display the configuration directory path if successful
if ($configDir) {
    Write-Output "VLC configuration directory: $configDir"
}