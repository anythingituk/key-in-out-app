[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SiteUrl,

    [string]$ListName = "TenantTracker",

    [string]$CsvPath = (Join-Path $PSScriptRoot "..\data\sample-tenants.csv"),

    [string]$ClientId,

    [string]$Tenant
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-PnPModule {
    if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
        throw "PnP.PowerShell is not installed. Run: Install-Module PnP.PowerShell -Scope CurrentUser"
    }
}

function Connect-Site {
    param(
        [string]$Url,
        [string]$AppClientId,
        [string]$TenantName
    )

    $connectParams = @{
        Url         = $Url
        Interactive = $true
    }

    if (-not [string]::IsNullOrWhiteSpace($AppClientId)) {
        $connectParams["ClientId"] = $AppClientId
    }

    if (-not [string]::IsNullOrWhiteSpace($TenantName)) {
        $connectParams["Tenant"] = $TenantName
    }

    Connect-PnPOnline @connectParams
}

function ConvertTo-NullableDate {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $null
    }

    return [datetime]$Value
}

function Get-ExistingTenantItem {
    param(
        [string]$TenantId
    )

    $escapedTenantId = [System.Security.SecurityElement]::Escape($TenantId)
    $query = @"
<View>
  <Query>
    <Where>
      <Eq>
        <FieldRef Name='TenantID' />
        <Value Type='Text'>$escapedTenantId</Value>
      </Eq>
    </Where>
  </Query>
  <RowLimit>1</RowLimit>
</View>
"@

    return Get-PnPListItem -List $ListName -Query $query
}

Assert-PnPModule
Import-Module PnP.PowerShell

if (-not (Test-Path -LiteralPath $CsvPath)) {
    throw "CSV file not found: $CsvPath"
}

Connect-Site -Url $SiteUrl -AppClientId $ClientId -TenantName $Tenant

$rows = Import-Csv -LiteralPath $CsvPath

foreach ($row in $rows) {
    $existing = Get-ExistingTenantItem -TenantId $row.TenantID

    if ($existing.Count -gt 0) {
        Write-Host "Skipping existing tenant: $($row.TenantID)"
        continue
    }

    $values = @{
        Title             = $row.FullName
        TenantID          = $row.TenantID
        FirstName         = $row.FirstName
        LastName          = $row.LastName
        FullName          = $row.FullName
        Email             = $row.Email
        PropertyName      = $row.PropertyName
        UnitReference     = $row.UnitReference
        TenancyYear       = $row.TenancyYear
        TenantStatus      = $row.TenantStatus
        IsActiveForKeyApp = [System.Convert]::ToBoolean($row.IsActiveForKeyApp)
    }

    $moveInDate = ConvertTo-NullableDate -Value $row.ExpectedMoveInDate
    if ($null -ne $moveInDate) {
        $values["ExpectedMoveInDate"] = $moveInDate
    }

    $moveOutDate = ConvertTo-NullableDate -Value $row.ExpectedMoveOutDate
    if ($null -ne $moveOutDate) {
        $values["ExpectedMoveOutDate"] = $moveOutDate
    }

    Add-PnPListItem -List $ListName -Values $values | Out-Null
    Write-Host "Imported tenant: $($row.TenantID)"
}

Write-Host "Sample import complete."
