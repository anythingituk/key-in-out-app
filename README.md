# Key In/Out App

Public-ready starter project for a staff-only key return and key collection app built with Microsoft Power Apps and SharePoint Lists.

The app is designed for an internal staff workflow:

- choose whether a transaction is a key return or key collection
- search active tenant records by name
- identify the correct tenant by property and unit
- confirm the selected tenant
- write a key transaction record to SharePoint

No real tenant data, staff data, SharePoint URLs, credentials, or business-specific names should be committed to this repository.

## Repository Contents

| Path | Purpose |
|---|---|
| `docs/requirements.md` | Generic functional requirements and acceptance criteria |
| `docs/sharepoint-setup.md` | Step-by-step SharePoint setup guidance |
| `docs/power-apps-build-guide.md` | Step-by-step Power Apps build instructions |
| `docs/power-apps-studio-navigation.md` | Power Apps Studio click-path guide for common setup tasks |
| `docs/github-publication.md` | Step-by-step GitHub publishing guidance |
| `powerapps/formulas.md` | Power Fx formulas for the app screens and controls |
| `sharepoint/install-pnp-module.ps1` | Optional repo-local PnP PowerShell installer |
| `sharepoint/register-pnp-interactive-app.ps1` | Helper to create the Entra app registration required by PnP PowerShell |
| `sharepoint/provision-lists.ps1` | PnP PowerShell script to create the SharePoint Lists |
| `sharepoint/import-sample-tenants.ps1` | Optional script to import fake sample tenant data |
| `data/sample-tenants.csv` | Fake data for testing only |
| `SECURITY.md` | Public repository privacy rules |

## Prerequisites

- A Microsoft 365 tenant with SharePoint and Power Apps access
- Permission to create or manage SharePoint Lists on the target site
- PowerShell 7.4 or later
- PnP PowerShell module
- Git
- A GitHub account

Install PnP PowerShell if needed:

```powershell
Install-Module PnP.PowerShell -Scope CurrentUser -Force -AllowClobber
```

PnP PowerShell requires PowerShell 7.4 or later. Check your version with:

```powershell
$PSVersionTable.PSVersion
```

If needed, install PowerShell 7 on Windows:

```powershell
winget install --id Microsoft.PowerShell --source winget
```

Installing PowerShell 7 does not change an already-open Windows PowerShell 5.1 window. Start PowerShell 7 by running:

```powershell
pwsh
```

Then check the version again:

```powershell
$PSVersionTable.PSVersion
```

If your computer blocks installation into the normal PowerShell module folder, install the dependency into this repo instead:

```powershell
.\sharepoint\install-pnp-module.ps1
```

Current PnP PowerShell interactive login also requires an Entra app registration. Create one with:

```powershell
.\sharepoint\register-pnp-interactive-app.ps1 -Tenant "contoso.onmicrosoft.com"
```

Copy the returned client ID and pass it to the provisioning script:

```powershell
.\sharepoint\provision-lists.ps1 `
  -SiteUrl "https://contoso.sharepoint.com/sites/key-management" `
  -Tenant "contoso.onmicrosoft.com" `
  -ClientId "00000000-0000-0000-0000-000000000000"
```

## Step 1: Create the SharePoint Lists

Run this from the repository root, replacing the URL with your SharePoint site URL:

```powershell
.\sharepoint\provision-lists.ps1 -SiteUrl "https://contoso.sharepoint.com/sites/key-management"
```

If your Microsoft 365 tenant requires a registered Entra app for PnP PowerShell authentication, pass its client ID:

```powershell
.\sharepoint\provision-lists.ps1 `
  -SiteUrl "https://contoso.sharepoint.com/sites/key-management" `
  -ClientId "00000000-0000-0000-0000-000000000000"
```

The script creates:

- `TenantTracker`
- `KeyTransactions`

## Step 2: Optionally Import Fake Test Data

Use this only in a development or test SharePoint site:

```powershell
.\sharepoint\import-sample-tenants.ps1 -SiteUrl "https://contoso.sharepoint.com/sites/key-management"
```

Do not import `data/sample-tenants.csv` into a production tenant unless you intentionally want fake records.

## Step 3: Build the Power App

Follow [docs/power-apps-build-guide.md](docs/power-apps-build-guide.md) and copy the formulas from [powerapps/formulas.md](powerapps/formulas.md).

Recommended screen flow:

1. Transaction type
2. Staff tenant search
3. Tenant confirmation
4. Key details and submission

## Step 4: Publish This Folder to GitHub

Follow [docs/github-publication.md](docs/github-publication.md).

The short version is:

```powershell
git status
git add .
git commit -m "Initial Power Apps SharePoint key management scaffold"
```

Create a new public GitHub repository named `key-in-out-app`, then connect and push:

```powershell
git remote add origin https://github.com/YOUR-USERNAME/key-in-out-app.git
git branch -M main
git push -u origin main
```

## Public Repository Safety Rules

- Do not commit real tenant records.
- Do not commit exported app packages that contain environment-specific metadata unless reviewed first.
- Do not commit SharePoint site URLs if they identify your organisation.
- Do not commit screenshots showing tenant data.
- Use fake `example.com` email addresses in samples and documentation.

## License

This project uses the MIT License. In plain terms, others can use, copy, change, and redistribute the project, including commercially, as long as they keep the license notice. The project is provided without warranty.
