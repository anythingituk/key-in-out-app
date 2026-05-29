[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SiteUrl,

    [string]$TenantTrackerListName = "TenantTracker",

    [string]$KeyTransactionsListName = "KeyTransactions",

    [string]$ClientId,

    [string]$Tenant
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Assert-PowerShellVersion {
    $minimumVersion = [version]"7.4.0"

    if ($PSVersionTable.PSVersion -lt $minimumVersion) {
        throw "PnP.PowerShell requires PowerShell 7.4 or later. Current version: $($PSVersionTable.PSVersion). Install PowerShell 7 with: winget install --id Microsoft.PowerShell --source winget"
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

    if (
        [string]::IsNullOrWhiteSpace($AppClientId) -and
        [string]::IsNullOrWhiteSpace($env:ENTRAID_APP_ID) -and
        [string]::IsNullOrWhiteSpace($env:ENTRAID_CLIENT_ID)
    ) {
        Write-Warning "PnP interactive sign-in may require a registered Entra app client ID. If sign-in fails, rerun with -ClientId or set ENTRAID_APP_ID."
    }

    Connect-PnPOnline @connectParams
}

function Ensure-List {
    param(
        [string]$ListName
    )

    $list = Get-PnPList -Identity $ListName -ErrorAction SilentlyContinue

    if ($null -eq $list) {
        Write-Host "Creating list: $ListName"
        New-PnPList -Title $ListName -Template GenericList -EnableVersioning | Out-Null
    }
    else {
        Write-Host "List already exists: $ListName"
        Set-PnPList -Identity $ListName -EnableVersioning $true | Out-Null
    }

    try {
        Set-PnPField -List $ListName -Identity "Title" -Values @{ Required = $false } | Out-Null
    }
    catch {
        Write-Warning "Could not update Title field settings on $ListName. Continuing."
    }
}

function Test-FieldExists {
    param(
        [string]$ListName,
        [string]$InternalName
    )

    $field = Get-PnPField -List $ListName -Identity $InternalName -ErrorAction SilentlyContinue
    return $null -ne $field
}

function Ensure-Field {
    param(
        [string]$ListName,
        [string]$DisplayName,
        [string]$InternalName,
        [ValidateSet("Text", "Note", "Number", "DateTime", "Boolean")]
        [string]$Type,
        [bool]$Required = $false,
        [bool]$AddToDefaultView = $true
    )

    if (Test-FieldExists -ListName $ListName -InternalName $InternalName) {
        Write-Host "Field already exists: $ListName.$InternalName"
        return
    }

    Write-Host "Creating field: $ListName.$InternalName"
    Add-PnPField `
        -List $ListName `
        -DisplayName $DisplayName `
        -InternalName $InternalName `
        -Type $Type `
        -Required:$Required `
        -AddToDefaultView:$AddToDefaultView | Out-Null
}

function Ensure-ChoiceField {
    param(
        [string]$ListName,
        [string]$DisplayName,
        [string]$InternalName,
        [string[]]$Choices,
        [bool]$Required = $false,
        [bool]$AddToDefaultView = $true
    )

    if (Test-FieldExists -ListName $ListName -InternalName $InternalName) {
        Write-Host "Field already exists: $ListName.$InternalName"
        return
    }

    Write-Host "Creating choice field: $ListName.$InternalName"
    Add-PnPField `
        -List $ListName `
        -DisplayName $DisplayName `
        -InternalName $InternalName `
        -Type Choice `
        -Choices $Choices `
        -Required:$Required `
        -AddToDefaultView:$AddToDefaultView | Out-Null
}

function Try-AddFieldIndex {
    param(
        [string]$ListName,
        [string]$FieldName
    )

    try {
        Add-PnPFieldIndex -List $ListName -Field $FieldName -ErrorAction Stop | Out-Null
        Write-Host "Indexed field: $ListName.$FieldName"
    }
    catch {
        Write-Warning "Could not add index for $ListName.$FieldName. It may already exist or your tenant may not allow it."
    }
}

Assert-PowerShellVersion
Add-RepoModulePath
Assert-PnPModule
Import-Module PnP.PowerShell
Connect-Site -Url $SiteUrl -AppClientId $ClientId -TenantName $Tenant

Ensure-List -ListName $TenantTrackerListName
Ensure-Field -ListName $TenantTrackerListName -DisplayName "Tenant ID" -InternalName "TenantID" -Type Text -Required $true
Ensure-Field -ListName $TenantTrackerListName -DisplayName "First Name" -InternalName "FirstName" -Type Text -Required $true
Ensure-Field -ListName $TenantTrackerListName -DisplayName "Last Name" -InternalName "LastName" -Type Text -Required $true
Ensure-Field -ListName $TenantTrackerListName -DisplayName "Full Name" -InternalName "FullName" -Type Text -Required $true
Ensure-Field -ListName $TenantTrackerListName -DisplayName "Email" -InternalName "Email" -Type Text -Required $true
Ensure-Field -ListName $TenantTrackerListName -DisplayName "Property Name" -InternalName "PropertyName" -Type Text -Required $true
Ensure-Field -ListName $TenantTrackerListName -DisplayName "Unit Reference" -InternalName "UnitReference" -Type Text
Ensure-Field -ListName $TenantTrackerListName -DisplayName "Tenancy Year" -InternalName "TenancyYear" -Type Text -Required $true
Ensure-ChoiceField -ListName $TenantTrackerListName -DisplayName "Tenant Status" -InternalName "TenantStatus" -Choices @("Incoming", "Current", "Outgoing", "Completed", "Cancelled") -Required $true
Ensure-Field -ListName $TenantTrackerListName -DisplayName "Expected Move In Date" -InternalName "ExpectedMoveInDate" -Type DateTime
Ensure-Field -ListName $TenantTrackerListName -DisplayName "Expected Move Out Date" -InternalName "ExpectedMoveOutDate" -Type DateTime
Ensure-Field -ListName $TenantTrackerListName -DisplayName "Is Active For Key App" -InternalName "IsActiveForKeyApp" -Type Boolean -Required $true

Try-AddFieldIndex -ListName $TenantTrackerListName -FieldName "TenantID"
Try-AddFieldIndex -ListName $TenantTrackerListName -FieldName "FullName"
Try-AddFieldIndex -ListName $TenantTrackerListName -FieldName "LastName"
Try-AddFieldIndex -ListName $TenantTrackerListName -FieldName "TenantStatus"
Try-AddFieldIndex -ListName $TenantTrackerListName -FieldName "IsActiveForKeyApp"

Ensure-List -ListName $KeyTransactionsListName
Set-PnPList -Identity $KeyTransactionsListName -EnableAttachments $true | Out-Null
Ensure-Field -ListName $KeyTransactionsListName -DisplayName "Transaction ID" -InternalName "TransactionID" -Type Text -Required $true
Ensure-ChoiceField -ListName $KeyTransactionsListName -DisplayName "Transaction Type" -InternalName "TransactionType" -Choices @("Return", "Collection") -Required $true
Ensure-Field -ListName $KeyTransactionsListName -DisplayName "Tenant ID" -InternalName "TenantID" -Type Text -Required $true
Ensure-Field -ListName $KeyTransactionsListName -DisplayName "Tenant Name" -InternalName "TenantName" -Type Text -Required $true
Ensure-Field -ListName $KeyTransactionsListName -DisplayName "Tenant Email" -InternalName "TenantEmail" -Type Text -Required $true
Ensure-Field -ListName $KeyTransactionsListName -DisplayName "Property Name" -InternalName "PropertyName" -Type Text -Required $true
Ensure-Field -ListName $KeyTransactionsListName -DisplayName "Unit Reference" -InternalName "UnitReference" -Type Text
Ensure-Field -ListName $KeyTransactionsListName -DisplayName "Front Door Key Count" -InternalName "FDCount" -Type Number
Ensure-Field -ListName $KeyTransactionsListName -DisplayName "Room Key Count" -InternalName "RKCount" -Type Number
Ensure-Field -ListName $KeyTransactionsListName -DisplayName "Fob Count" -InternalName "FobCount" -Type Number
Ensure-Field -ListName $KeyTransactionsListName -DisplayName "Mailbox Key Count" -InternalName "MailboxKeyCount" -Type Number
Ensure-Field -ListName $KeyTransactionsListName -DisplayName "Other Keys Description" -InternalName "OtherKeysDescription" -Type Note
Ensure-Field -ListName $KeyTransactionsListName -DisplayName "Tenant Signature JSON" -InternalName "TenantSignatureJson" -Type Note
Ensure-Field -ListName $KeyTransactionsListName -DisplayName "Staff Name" -InternalName "StaffName" -Type Text
Ensure-Field -ListName $KeyTransactionsListName -DisplayName "Staff Signature JSON" -InternalName "StaffSignatureJson" -Type Note
Ensure-Field -ListName $KeyTransactionsListName -DisplayName "Submitted At" -InternalName "SubmittedAt" -Type DateTime
Ensure-Field -ListName $KeyTransactionsListName -DisplayName "Notes" -InternalName "Notes" -Type Note

Try-AddFieldIndex -ListName $KeyTransactionsListName -FieldName "TransactionID"
Try-AddFieldIndex -ListName $KeyTransactionsListName -FieldName "TransactionType"
Try-AddFieldIndex -ListName $KeyTransactionsListName -FieldName "TenantID"
Try-AddFieldIndex -ListName $KeyTransactionsListName -FieldName "SubmittedAt"

Write-Host ""
Write-Host "SharePoint setup complete."
Write-Host "Lists:"
Write-Host "- $TenantTrackerListName"
Write-Host "- $KeyTransactionsListName"
