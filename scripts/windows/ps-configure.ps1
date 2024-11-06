# Load the get-config-dir.ps1 script
. "$PSScriptRoot\get-config-dir.ps1"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Function to create the input form
function Show-ConfigForm {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Configuration"
    $form.Size = New-Object System.Drawing.Size(400, 300)
    $form.StartPosition = "CenterScreen"

    # Labels and text boxes
    $labels = @("API Key:", "API Secret:", "API Endpoint:", "Threshold:", "Homepage:")
    $inputs = @{}
    $yPos = 20

    foreach ($labelText in $labels) {
        # Create label
        $label = New-Object System.Windows.Forms.Label
        $label.Text = $labelText
        $label.Location = New-Object System.Drawing.Point(10, $yPos)
        $label.AutoSize = $true
        $form.Controls.Add($label)

        # Create text box
        $textBox = New-Object System.Windows.Forms.TextBox
        $textBox.Size = New-Object System.Drawing.Size(250, 20)
        $textBox.Location = New-Object System.Drawing.Point(120, $yPos)
        $form.Controls.Add($textBox)

        # Store text box in a dictionary
        $inputs[$labelText] = $textBox
        $yPos += 40
    }

    # OK button
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Text = "OK"
    $okButton.Location = New-Object System.Drawing.Point(150, $yPos)
    $okButton.Add_Click({
        $form.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form.Close()
    })
    $form.Controls.Add($okButton)

    # Show the form and get the result
    if ($form.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return @{
            ApiKey = $inputs["API Key:"].Text
            ApiSecret = $inputs["API Secret:"].Text
            ApiEndpoint = $inputs["API Endpoint:"].Text
            Threshold = $inputs["Threshold:"].Text
            Homepage = $inputs["Homepage:"].Text
        }
    }
    return $null
}

# Function to delete a file if it exists
function Delete-IfExists {
    param ([string]$FilePath)
    if (Test-Path -Path $FilePath) {
        Write-Output "File exists: $FilePath"
        Remove-Item -Path $FilePath -Force
        Write-Output "File deleted: $FilePath"
    } else {
        Write-Output "File does not exist: $FilePath"
    }
}

# Get user input via form
$userInput = Show-ConfigForm
if (-not $userInput) {
    Write-Output "Configuration canceled."
    exit
}

# Get VLC config directory
$configDir = Get-VLCConfigDirectory
if (-not $configDir) {
    Write-Error "Failed to retrieve VLC configuration directory."
    exit 1
}

# Define config files
$xapiConfigFile = Join-Path -Path $configDir -ChildPath "xapi-extension-config.txt"
$thresholdConfigFile = Join-Path -Path $configDir -ChildPath "xapi-threshold-config.txt"

# Delete existing config files
Delete-IfExists -FilePath $xapiConfigFile
Delete-IfExists -FilePath $thresholdConfigFile

# Write user inputs to the appropriate config files
if ($userInput.ApiKey) { Add-Content -Path $xapiConfigFile -Value "api_key = $($userInput.ApiKey)" }
if ($userInput.ApiSecret) { Add-Content -Path $xapiConfigFile -Value "api_secret = $($userInput.ApiSecret)" }
if ($userInput.ApiEndpoint) { Add-Content -Path $xapiConfigFile -Value "api_endpoint = $($userInput.ApiEndpoint)" }
if ($userInput.Threshold) { Add-Content -Path $thresholdConfigFile -Value "threshold = $($userInput.Threshold)" }
if ($userInput.Homepage) { Add-Content -Path $xapiConfigFile -Value "api_homepage = $($userInput.Homepage)" }

Write-Output "Config written to $xapiConfigFile and threshold written to $thresholdConfigFile."