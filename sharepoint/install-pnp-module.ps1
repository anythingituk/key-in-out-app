[CmdletBinding()]
param(
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-PowerShellVersion {
    $minimumVersion = [version]"7.4.0"

    if ($PSVersionTable.PSVersion -lt $minimumVersion) {
        throw "PnP.PowerShell requires PowerShell 7.4 or later, but this session is $($PSVersionTable.PSVersion). If PowerShell 7 is installed, start it with: pwsh"
    }
}

Assert-PowerShellVersion

$repoRoot = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")
$moduleRoot = Join-Path $repoRoot ".psmodules"
$pnpModulePath = Join-Path $moduleRoot "PnP.PowerShell"

if ((Test-Path -LiteralPath $pnpModulePath) -and -not $Force) {
    Write-Host "PnP.PowerShell already exists in: $pnpModulePath"
    Write-Host "Use -Force to reinstall."
    return
}

if ((Test-Path -LiteralPath $pnpModulePath) -and $Force) {
    Remove-Item -LiteralPath $pnpModulePath -Recurse -Force
}

if (-not (Test-Path -LiteralPath $moduleRoot)) {
    New-Item -ItemType Directory -Path $moduleRoot | Out-Null
}

if (Get-Command Save-PSResource -ErrorAction SilentlyContinue) {
    Save-PSResource -Name PnP.PowerShell -Path $moduleRoot -TrustRepository
}
elseif (Get-Command Save-Module -ErrorAction SilentlyContinue) {
    Save-Module -Name PnP.PowerShell -Path $moduleRoot -Force
}
else {
    throw "Neither Save-PSResource nor Save-Module is available. Install or update PowerShellGet/PSResourceGet."
}

$env:PSModulePath = "$moduleRoot;$env:PSModulePath"
Import-Module PnP.PowerShell -ErrorAction Stop

$module = Get-Module -Name PnP.PowerShell
Write-Host "Installed PnP.PowerShell $($module.Version) to $moduleRoot"
