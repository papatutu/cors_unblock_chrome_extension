# Requires PowerShell 5+
[CmdletBinding()]
param()

Write-Host "Finding Flutter installation directory..."

function Resolve-FlutterDirectory {
    # Try the flutter command first
    $flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($flutterCmd) {
        $flutterDir = [System.IO.Path]::GetDirectoryName([System.IO.Path]::GetDirectoryName($flutterCmd.Path))
        $flutterDir = [string]$flutterDir
        Write-Host "Found Flutter in PATH: $flutterDir"
        return $flutterDir
    }

    $candidateDirs = @(
        Join-Path -Path ([string]$env:USERPROFILE) -ChildPath 'flutter',
        "C:\\src\\flutter",
        "C:\\flutter",
        "C:\\Tools\\flutter"
    )

    foreach ($dir in $candidateDirs) {
        if ([string]::IsNullOrWhiteSpace($dir)) { continue }
        if (Test-Path -Path $dir) {
            Write-Host "Found Flutter at: $dir"
            return $dir
        }
    }

    return $null
}

$flutterDirectory = Resolve-FlutterDirectory
$flutterDirectory = if ($flutterDirectory -is [array]) { $flutterDirectory[0] } else { $flutterDirectory }
$flutterDirectory = [string]$flutterDirectory

if ([string]::IsNullOrWhiteSpace($flutterDirectory)) {
    Write-Error "Flutter installation not found. Please ensure Flutter is installed."
    exit 1
}

$stampFile = Join-Path $flutterDirectory "bin\\cache\\flutter_tools.stamp"
if (Test-Path -Path $stampFile) {
    Write-Host "Deleting flutter_tools.stamp file: $stampFile"
    Remove-Item -Path $stampFile -Force
    Write-Host "flutter_tools.stamp deleted successfully"
} else {
    Write-Host "flutter_tools.stamp file not found at: $stampFile"
}

$snapshotFile = Join-Path $flutterDirectory "bin\\cache\\flutter_tools.snapshot"
if (Test-Path -Path $snapshotFile) {
    Write-Host "Deleting flutter_tools.snapshot file: $snapshotFile"
    Remove-Item -Path $snapshotFile -Force
    Write-Host "flutter_tools.snapshot deleted successfully"
}

Write-Host "Flutter tools will be rebuilt on next flutter command execution"

function Remove-DisableExtensionFlag {
    param(
        [Parameter(Mandatory)]
        [string]$FilePath
    )

    if (-not (Test-Path -Path $FilePath)) { return }

    Write-Host "Processing file: $FilePath"

    $backupPath = "$FilePath.bak"
    Copy-Item -Path $FilePath -Destination $backupPath -Force

    $content = Get-Content -Path $FilePath -Raw -ErrorAction Stop
    $updated = $content.Replace('--disable-extensions', '').Replace('--disable-extension', '')

    if ($content -ne $updated) {
        Set-Content -Path $FilePath -Value $updated -Encoding UTF8
        Write-Host "Removed --disable-extension flags from $FilePath"
    } else {
        Write-Host "No disable-extension flags found in $FilePath"
    }
}

$currentDirectory = [string](Get-Location).Path
$webConfigDirs = @(
    [System.IO.Path]::Combine($flutterDirectory, 'packages', 'flutter_tools', 'lib', 'src', 'web'),
    [System.IO.Path]::Combine($flutterDirectory, 'packages', 'flutter_tools', 'lib', 'src', 'commands'),
    [System.IO.Path]::Combine([string]$env:USERPROFILE, '.flutter'),
    [System.IO.Path]::Combine($currentDirectory, '.dart_tool'),
    [System.IO.Path]::Combine($currentDirectory, 'web')
)

Write-Host "Looking for Flutter web debug configurations..."

foreach ($dir in $webConfigDirs) {
    if (-not (Test-Path -Path $dir)) { continue }

    Write-Host "Checking directory: $dir"

    $filePatterns = @('*.dart', '*.json', '*.yaml', '*.yml')
    foreach ($pattern in $filePatterns) {
        Get-ChildItem -Path $dir -Recurse -File -Filter $pattern -ErrorAction SilentlyContinue |
            Where-Object {
                try {
                    Select-String -Path $_.FullName -Pattern '--disable-extensions', '--disable-extension' -SimpleMatch -Quiet
                } catch {
                    $false
                }
            } |
            ForEach-Object { Remove-DisableExtensionFlag -FilePath $_.FullName }
    }
}

$launchJson = [System.IO.Path]::Combine($currentDirectory, '.vscode', 'launch.json')
if (Test-Path -Path $launchJson) {
    Write-Host "Found VS Code launch configuration"
    Remove-DisableExtensionFlag -FilePath $launchJson
}

Write-Host "Script completed successfully!"
Write-Host "Note: Flutter tools will rebuild automatically on the next flutter command."
Write-Host "Chrome extensions should now be enabled in Flutter web debug mode."
