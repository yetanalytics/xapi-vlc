# Load the Get-VLCConfigDirectory function from get-config-dir.ps1
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$scriptDir\get-config-dir.ps1"

# Get the VLC configuration directory
$configDir = Get-VLCConfigDirectory
if (-not $configDir) {
    Write-Error "Failed to retrieve VLC configuration directory."
    exit 1
}

# Get the project root directory
$projectRoot = Split-Path -Parent (Split-Path -Parent $scriptDir)

# Define the source template and target paths
$sourceTemplate = "$projectRoot\templates\xapi.json.template"
$targetTemplatePath = Join-Path -Path $configDir -ChildPath "xapi.json.template"

# Copy the template to the config directory
try {
    Copy-Item -Path $sourceTemplate -Destination $targetTemplatePath -Force
    Write-Output "Template copied to: $targetTemplatePath"
} catch {
    Write-Error "Failed to copy template: $($_.Exception.Message)"
    exit 1
}

# Define the source Lua file path
$sourceFile = "$projectRoot\xapi.lua"

# Check if the source Lua file exists
if (-not (Test-Path -Path $sourceFile)) {
    Write-Error "Error: $sourceFile not found."
    exit 1
}

# Define the target directory for VLC extensions
$targetDir = Join-Path -Path "$env:APPDATA\vlc" -ChildPath "lua\extensions"

# Ensure the target directory exists
if (-not (Test-Path -Path $targetDir)) {
    try {
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        Write-Output "Created VLC extensions directory at: $targetDir"
    } catch {
        Write-Error "Failed to create VLC extensions directory: $($_.Exception.Message)"
        exit 1
    }
}

# Copy the Lua file to the target directory
try {
    Copy-Item -Path $sourceFile -Destination $targetDir -Force
    Write-Output "xapi.lua has been successfully copied to $targetDir. Restart VLC to enable extension."
} catch {
    Write-Error "Error: Failed to copy xapi.lua"
    exit 1
}

# Pause at the end to allow the user to review logs
Add-Type -AssemblyName PresentationFramework
[System.Windows.MessageBox]::Show("xapi.lua has been successfully copied to $targetDir. Restart VLC to enable extension.", "xAPI VLC Installer") | Out-Null