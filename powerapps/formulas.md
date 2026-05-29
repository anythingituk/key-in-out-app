# Power Fx Formulas

Use these formulas in a canvas app connected to the `TenantTracker` and `KeyTransactions` SharePoint Lists.

## App `OnStart`

```powerfx
Set(varTransactionType, Blank());
Set(varSelectedTenant, Blank());
Set(varLastTransactionId, Blank())
```

## Screen: `scrTransactionType`

### `btnReturnKeys.Text`

```powerfx
"Return Keys"
```

### `btnReturnKeys.OnSelect`

```powerfx
Set(varTransactionType, "Return");
Set(varSelectedTenant, Blank());
Reset(txtTenantSearch);
Navigate(scrTenantSearch, ScreenTransition.Fade)
```

### `btnCollectKeys.Text`

```powerfx
"Collect Keys"
```

### `btnCollectKeys.OnSelect`

```powerfx
Set(varTransactionType, "Collection");
Set(varSelectedTenant, Blank());
Reset(txtTenantSearch);
Navigate(scrTenantSearch, ScreenTransition.Fade)
```

## Screen: `scrTenantSearch`

### `txtTenantSearch.HintText`

```powerfx
"Search tenant name..."
```

### `galTenantResults.Items`

```powerfx
With(
    {
        searchText: Trim(txtTenantSearch.Text)
    },
    If(
        Len(searchText) < 2,
        Filter(TenantTracker, false),
        SortByColumns(
            Filter(
                TenantTracker,
                IsActiveForKeyApp = true &&
                (
                    StartsWith(FullName, searchText) ||
                    StartsWith(FirstName, searchText) ||
                    StartsWith(LastName, searchText)
                ) &&
                (
                    (
                        varTransactionType = "Return" &&
                        (
                            TenantStatus.Value = "Outgoing" ||
                            TenantStatus.Value = "Current"
                        )
                    ) ||
                    (
                        varTransactionType = "Collection" &&
                        (
                            TenantStatus.Value = "Incoming" ||
                            TenantStatus.Value = "Current"
                        )
                    )
                )
            ),
            "LastName",
            SortOrder.Ascending
        )
    )
)
```

If your `TenantStatus` column is stored as plain text rather than a SharePoint choice, use `TenantStatus` instead of `TenantStatus.Value`.

### Result title label `Text`

```powerfx
ThisItem.FullName
```

### Result subtitle label `Text`

```powerfx
If(
    IsBlank(ThisItem.UnitReference),
    ThisItem.PropertyName,
    ThisItem.UnitReference & ", " & ThisItem.PropertyName
)
```

### Result masked email label `Text`

```powerfx
If(
    IsBlank(ThisItem.Email) || !IsMatch(ThisItem.Email, Match.Email),
    "",
    Left(ThisItem.Email, Min(3, Find("@", ThisItem.Email) - 1)) &
    "*****" &
    Mid(ThisItem.Email, Find("@", ThisItem.Email), Len(ThisItem.Email))
)
```

### Result status label `Text`

```powerfx
ThisItem.TenantStatus.Value
```

If your `TenantStatus` column is stored as plain text rather than a SharePoint choice, use:

```powerfx
ThisItem.TenantStatus
```

### `galTenantResults.OnSelect`

```powerfx
Set(varSelectedTenant, ThisItem)
```

### `galTenantResults.TemplateFill`

```powerfx
If(
    !IsBlank(varSelectedTenant) && ThisItem.TenantID = varSelectedTenant.TenantID,
    RGBA(230, 244, 255, 1),
    RGBA(255, 255, 255, 1)
)
```

### `btnSearchContinue.DisplayMode`

```powerfx
If(
    IsBlank(varSelectedTenant),
    DisplayMode.Disabled,
    DisplayMode.Edit
)
```

### `btnSearchContinue.OnSelect`

```powerfx
Navigate(scrTenantConfirm, ScreenTransition.Fade)
```

### `btnSearchBack.OnSelect`

```powerfx
Set(varSelectedTenant, Blank());
Navigate(scrTransactionType, ScreenTransition.Fade)
```

## Screen: `scrTenantConfirm`

### Selected tenant name label `Text`

```powerfx
varSelectedTenant.FullName
```

### Selected property label `Text`

```powerfx
varSelectedTenant.PropertyName
```

### Selected unit label `Text`

```powerfx
varSelectedTenant.UnitReference
```

### Selected masked email label `Text`

```powerfx
If(
    IsBlank(varSelectedTenant.Email) || !IsMatch(varSelectedTenant.Email, Match.Email),
    "",
    Left(varSelectedTenant.Email, Min(3, Find("@", varSelectedTenant.Email) - 1)) &
    "*****" &
    Mid(varSelectedTenant.Email, Find("@", varSelectedTenant.Email), Len(varSelectedTenant.Email))
)
```

### Transaction type label `Text`

```powerfx
If(
    varTransactionType = "Return",
    "Key Return",
    "Key Collection"
)
```

### `btnConfirmBack.OnSelect`

```powerfx
Navigate(scrTenantSearch, ScreenTransition.Fade)
```

### `btnConfirmContinue.OnSelect`

```powerfx
Navigate(scrKeyDetails, ScreenTransition.Fade)
```

## Screen: `scrKeyDetails`

### Tenant name display `Text`

```powerfx
varSelectedTenant.FullName
```

### Property/unit display `Text`

```powerfx
If(
    IsBlank(varSelectedTenant.UnitReference),
    varSelectedTenant.PropertyName,
    varSelectedTenant.UnitReference & ", " & varSelectedTenant.PropertyName
)
```

### `btnKeyDetailsBack.OnSelect`

```powerfx
Navigate(scrTenantConfirm, ScreenTransition.Fade)
```

### `btnSubmitTransaction.DisplayMode`

```powerfx
If(
    IsBlank(varSelectedTenant) || IsBlank(varTransactionType),
    DisplayMode.Disabled,
    DisplayMode.Edit
)
```

### `btnSubmitTransaction.OnSelect`

```powerfx
Set(
    varLastTransactionId,
    Text(Now(), "yyyymmddhhmmss") & "-" & Left(Text(GUID()), 8)
);

Patch(
    KeyTransactions,
    Defaults(KeyTransactions),
    {
        Title: varLastTransactionId,
        TransactionID: varLastTransactionId,
        TransactionType: { Value: varTransactionType },
        TenantID: varSelectedTenant.TenantID,
        TenantName: varSelectedTenant.FullName,
        TenantEmail: varSelectedTenant.Email,
        PropertyName: varSelectedTenant.PropertyName,
        UnitReference: varSelectedTenant.UnitReference,
        FDCount: Value(Coalesce(txtFDCount.Text, "0")),
        RKCount: Value(Coalesce(txtRKCount.Text, "0")),
        FobCount: Value(Coalesce(txtFobCount.Text, "0")),
        MailboxKeyCount: Value(Coalesce(txtMailboxKeyCount.Text, "0")),
        OtherKeysDescription: txtOtherKeysDescription.Text,
        TenantSignatureJson: JSON(penTenantSignature.Image, JSONFormat.IncludeBinaryData),
        StaffName: User().FullName,
        StaffSignatureJson: JSON(penStaffSignature.Image, JSONFormat.IncludeBinaryData),
        SubmittedAt: Now(),
        Notes: txtNotes.Text
    }
);

Reset(txtFDCount);
Reset(txtRKCount);
Reset(txtFobCount);
Reset(txtMailboxKeyCount);
Reset(txtOtherKeysDescription);
Reset(txtNotes);
Reset(penTenantSignature);
Reset(penStaffSignature);
Set(varSelectedTenant, Blank());
Set(varTransactionType, Blank());
Navigate(scrSuccess, ScreenTransition.Fade)
```

If your `TransactionType` column is stored as plain text rather than a SharePoint choice, use:

```powerfx
TransactionType: varTransactionType
```

## Screen: `scrSuccess`

### Success transaction reference label `Text`

```powerfx
"Transaction reference: " & varLastTransactionId
```

### New transaction button `OnSelect`

```powerfx
Navigate(scrTransactionType, ScreenTransition.Fade)
```
