# Power Apps Build Guide

This guide creates a canvas app connected to the SharePoint Lists created by `sharepoint/provision-lists.ps1`.

## 1. Create the Canvas App

1. Open Power Apps.
2. Create a new tablet canvas app.
3. Add SharePoint as a data source.
4. Connect to the target SharePoint site.
5. Add these lists:
   - `TenantTracker`
   - `KeyTransactions`

## 2. Create Screens

Create these screens:

| Screen Name | Purpose |
|---|---|
| `scrTransactionType` | Choose return or collection |
| `scrTenantSearch` | Search and select tenant |
| `scrTenantConfirm` | Confirm selected tenant |
| `scrKeyDetails` | Capture key counts, signatures, and notes |
| `scrSuccess` | Show submission success |

## 3. Add Controls

### `scrTransactionType`

Add:

- button `btnReturnKeys`
- button `btnCollectKeys`

### `scrTenantSearch`

Add:

- text input `txtTenantSearch`
- vertical gallery `galTenantResults`
- button `btnSearchContinue`
- button or icon `btnSearchBack`

Set gallery result labels to show:

- `ThisItem.FullName`
- `ThisItem.UnitReference & ", " & ThisItem.PropertyName`
- masked email formula from `powerapps/formulas.md`
- `ThisItem.TenantStatus.Value`

### `scrTenantConfirm`

Add labels for:

- selected tenant name
- property
- unit reference
- masked email
- transaction type

Add:

- button `btnConfirmBack`
- button `btnConfirmContinue`

### `scrKeyDetails`

Add number inputs:

- `txtFDCount`
- `txtRKCount`
- `txtFobCount`
- `txtMailboxKeyCount`

Add text inputs:

- `txtOtherKeysDescription`
- `txtNotes`

Add pen inputs:

- `penTenantSignature`
- `penStaffSignature`

Add:

- button `btnSubmitTransaction`
- button `btnKeyDetailsBack`

## 4. Apply Formulas

Copy the formulas from `powerapps/formulas.md` into the matching control properties.

Build the screens in this order:

1. `scrTransactionType`
2. `scrTenantSearch`
3. `scrTenantConfirm`
4. `scrKeyDetails`
5. `scrSuccess`

## 5. Test

Use a development SharePoint site first.

Test cases:

- Return transaction finds outgoing and current tenants.
- Collection transaction finds incoming and current tenants.
- Search results stay empty until at least two characters are typed.
- Cancelled tenants do not appear.
- Inactive tenants do not appear.
- Continue is disabled until a tenant is selected.
- Confirmation screen shows masked email only.
- Submitted record appears in `KeyTransactions`.
- Tenant ID, name, email, property, and unit are stored on the transaction.

## 6. Publish

When testing is complete:

1. Save the app.
2. Publish the app.
3. Share the app only with authorised staff.
4. Confirm tenants do not have access to the app or lists.
