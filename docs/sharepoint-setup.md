# SharePoint Setup

This project uses two SharePoint Lists:

- `TenantTracker`
- `KeyTransactions`

The generated provisioning script creates both lists and the recommended columns.

## Before You Start

You need:

- permission to manage lists on the SharePoint site
- PowerShell 7.4 or later
- PnP PowerShell

Install PnP PowerShell:

```powershell
Install-Module PnP.PowerShell -Scope CurrentUser -Force -AllowClobber
```

If PowerShell prompts you to trust the repository, choose yes only if you are comfortable installing modules from PowerShell Gallery.

Check your PowerShell version:

```powershell
$PSVersionTable.PSVersion
```

If you are running Windows PowerShell 5.1, install PowerShell 7 and run the setup commands from a PowerShell 7 terminal:

```powershell
winget install --id Microsoft.PowerShell --source winget
```

## Provision the Lists

From the repository root:

```powershell
.\sharepoint\provision-lists.ps1 -SiteUrl "https://contoso.sharepoint.com/sites/key-management"
```

Replace the example URL with your SharePoint site URL.

Current PnP PowerShell authentication normally requires your own Entra application client ID for interactive login. If sign-in fails and asks for a client ID, register an Entra app for PnP PowerShell and rerun with:

```powershell
.\sharepoint\provision-lists.ps1 `
  -SiteUrl "https://contoso.sharepoint.com/sites/key-management" `
  -ClientId "00000000-0000-0000-0000-000000000000"
```

The script is idempotent: it checks whether each list and field already exists before creating it.

## Import Fake Test Data

For a development SharePoint site only:

```powershell
.\sharepoint\import-sample-tenants.ps1 -SiteUrl "https://contoso.sharepoint.com/sites/key-management"
```

The sample records use fake names and `example.com` email addresses.

## Production Data Import

For production, prepare a CSV with the same columns as `data/sample-tenants.csv`.

Minimum recommended columns:

- `TenantID`
- `FirstName`
- `LastName`
- `FullName`
- `Email`
- `PropertyName`
- `UnitReference`
- `TenancyYear`
- `TenantStatus`
- `ExpectedMoveInDate`
- `ExpectedMoveOutDate`
- `IsActiveForKeyApp`

Do not commit a production tenant CSV to this repository.

## Permissions

Recommended SharePoint permissions:

- staff app users: contribute access to `KeyTransactions`
- staff app users: read access to `TenantTracker`
- data administrators: edit access to `TenantTracker`
- site owners: full control

Avoid giving tenants access to either list.

## Attachments and Signatures

The provisioning script enables attachments on `KeyTransactions`.

For version 1, the included formulas can store pen input as JSON in multiline text columns. For production, a better pattern is:

1. Submit the transaction record.
2. Send the pen input image data to Power Automate.
3. Save the image as a SharePoint attachment or file.
4. Store the attachment/file reference on the transaction record.
