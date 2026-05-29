[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Tenant,

    [string]$ApplicationName = "key-in-out-app-pnp-powershell",

    [string[]]$SharePointDelegatePermissions = @("AllSites.FullControl"),

    [switch]$DeviceLogin
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-PowerShellVersion {
    $minimumVersion = [version]"7.4.0"

    if ($PSVersionTable.PSVersion -lt $minimumVersion) {
        throw "PnP.PowerShell requires PowerShell 7.4 or later, but this session is $($PSVersionTable.PSVersion). If PowerShell 7 is installed, start it with: pwsh"
    }
}

function Add-RepoModulePath {
    $repoRoot = Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")
    $repoModulePath = Join-Path $repoRoot ".psmodules"

    if ((Test-Path -LiteralPath $repoModulePath) -and ($env:PSModulePath -notlike "*$repoModulePath*")) {
        $env:PSModulePath = "$repoModulePath;$env:PSModulePath"
    }
}

function Assert-PnPModule {
    if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
        throw "PnP.PowerShell is not installed. Run this in PowerShell 7.4 or later: .\sharepoint\install-pnp-module.ps1"
    }
}

Assert-PowerShellVersion
Add-RepoModulePath
Assert-PnPModule
Import-Module PnP.PowerShell

$registrationParams = @{
    ApplicationName               = $ApplicationName
    Tenant                        = $Tenant
    SharePointDelegatePermissions = $SharePointDelegatePermissions
}

if ($DeviceLogin) {
    $registrationParams["DeviceLogin"] = $true
}

$result = Register-PnPEntraIDAppForInteractiveLogin @registrationParams

Write-Host ""
Write-Host "Registration complete. Copy the client ID from the output above or below."
Write-Host "Use it with:"
Write-Host ".\sharepoint\provision-lists.ps1 -SiteUrl `"https://contoso.sharepoint.com/sites/key-management`" -Tenant `"$Tenant`" -ClientId `"<CLIENT-ID>`""
Write-Host ""

$result
