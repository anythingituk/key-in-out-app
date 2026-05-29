# Power Fx Formulas

Use these formulas in a canvas app connected to the `TenantTracker` and `KeyTransactions` SharePoint Lists.

## App `OnStart`

```powerfx
Set(varTransactionType, Blank());
Set(varSelectedTenant, Blank());
Set(varLastTransactionId, Blank());
Set(varIdleTimeoutMs, 180000);
Set(varLastActivityAt, Now())
```

## App `StartScreen`

```powerfx
scrWelcome
```

## Shared Inactivity Pattern

Use this pattern on the transaction workflow screens so the app returns to the welcome screen after three minutes of inactivity.

Add this line at the start of button, gallery, and input formulas when staff interact with the app:

```powerfx
Set(varLastActivityAt, Now());
```

For a different timeout, change `varIdleTimeoutMs` in `App.OnStart`. For example, five minutes is `300000`.

## Screen: `scrWelcome`

### `scrWelcome.OnVisible`

```powerfx
Set(varTransactionType, Blank());
Set(varSelectedTenant, Blank());
Set(varLastActivityAt, Now())
```

### `btnStart.Text`

```powerfx
"Start key transaction"
```

### `btnStart.OnSelect`

```powerfx
Set(varLastActivityAt, Now());
Navigate(scrTransactionType, ScreenTransition.Fade)
```

## Screen: `scrTransactionType`

### `scrTransactionType.OnVisible`

```powerfx
Set(varLastActivityAt, Now())
```

### `btnReturnKeys.Text`

```powerfx
"Return Keys"
```

### `btnReturnKeys.OnSelect`

```powerfx
Set(varLastActivityAt, Now());
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
Set(varLastActivityAt, Now());
Set(varTransactionType, "Collection");
Set(varSelectedTenant, Blank());
Reset(txtTenantSearch);
Navigate(scrTenantSearch, ScreenTransition.Fade)
```

### `tmrIdleTransactionType.Duration`

```powerfx
10000
```

### `tmrIdleTransactionType.AutoStart`

```powerfx
true
```

### `tmrIdleTransactionType.Repeat`

```powerfx
true
```

### `tmrIdleTransactionType.Visible`

```powerfx
false
```

### `tmrIdleTransactionType.OnTimerEnd`

```powerfx
If(
    DateDiff(varLastActivityAt, Now(), TimeUnit.Milliseconds) >= varIdleTimeoutMs,
    Set(varTransactionType, Blank());
    Set(varSelectedTenant, Blank());
    Navigate(scrWelcome, ScreenTransition.Fade)
)
```

## Screen: `scrTenantSearch`

### `scrTenantSearch.OnVisible`

```powerfx
Set(varLastActivityAt, Now())
```

### `txtTenantSearch.HintText`

```powerfx
"Search tenant name..."
```

### `txtTenantSearch.OnChange`

```powerfx
Set(varLastActivityAt, Now())
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
Set(varLastActivityAt, Now());
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
Set(varLastActivityAt, Now());
Navigate(scrTenantConfirm, ScreenTransition.Fade)
```

### `btnSearchBack.OnSelect`

```powerfx
Set(varLastActivityAt, Now());
Set(varSelectedTenant, Blank());
Navigate(scrTransactionType, ScreenTransition.Fade)
```

### `tmrIdleSearch` properties

Use the same timer settings as `tmrIdleTransactionType`.

Set `tmrIdleSearch.OnTimerEnd` to:

```powerfx
If(
    DateDiff(varLastActivityAt, Now(), TimeUnit.Milliseconds) >= varIdleTimeoutMs,
    Set(varTransactionType, Blank());
    Set(varSelectedTenant, Blank());
    Reset(txtTenantSearch);
    Navigate(scrWelcome, ScreenTransition.Fade)
)
```

## Screen: `scrTenantConfirm`

### `scrTenantConfirm.OnVisible`

```powerfx
Set(varLastActivityAt, Now())
```

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
Set(varLastActivityAt, Now());
Navigate(scrTenantSearch, ScreenTransition.Fade)
```

### `btnConfirmContinue.OnSelect`

```powerfx
Set(varLastActivityAt, Now());
Navigate(scrKeyDetails, ScreenTransition.Fade)
```

### `tmrIdleConfirm` properties

Use the same timer settings as `tmrIdleTransactionType`.

Set `tmrIdleConfirm.OnTimerEnd` to:

```powerfx
If(
    DateDiff(varLastActivityAt, Now(), TimeUnit.Milliseconds) >= varIdleTimeoutMs,
    Set(varTransactionType, Blank());
    Set(varSelectedTenant, Blank());
    Navigate(scrWelcome, ScreenTransition.Fade)
)
```

## Screen: `scrKeyDetails`

### `scrKeyDetails.OnVisible`

```powerfx
Set(varLastActivityAt, Now())
```

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
Set(varLastActivityAt, Now());
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
Set(varLastActivityAt, Now());
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
        FDCount: Coalesce(txtFDCount.Value, 0),
        RKCount: Coalesce(txtRKCount.Value, 0),
        FobCount: Coalesce(txtFobCount.Value, 0),
        MailboxKeyCount: Coalesce(txtMailboxKeyCount.Value, 0),
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

### Input activity tracking

Set these input control `OnChange` properties to update the idle timer:

```powerfx
Set(varLastActivityAt, Now())
```

Apply to:

- `txtFDCount`
- `txtRKCount`
- `txtFobCount`
- `txtMailboxKeyCount`
- `txtOtherKeysDescription`
- `txtNotes`

For pen inputs, set `OnSelect` to:

```powerfx
Set(varLastActivityAt, Now())
```

### `tmrIdleKeyDetails` properties

Use the same timer settings as `tmrIdleTransactionType`.

Set `tmrIdleKeyDetails.OnTimerEnd` to:

```powerfx
If(
    DateDiff(varLastActivityAt, Now(), TimeUnit.Milliseconds) >= varIdleTimeoutMs,
    Set(varTransactionType, Blank());
    Set(varSelectedTenant, Blank());
    Reset(txtFDCount);
    Reset(txtRKCount);
    Reset(txtFobCount);
    Reset(txtMailboxKeyCount);
    Reset(txtOtherKeysDescription);
    Reset(txtNotes);
    Reset(penTenantSignature);
    Reset(penStaffSignature);
    Navigate(scrWelcome, ScreenTransition.Fade)
)
```

## Screen: `scrSuccess`

### `scrSuccess.OnVisible`

```powerfx
Set(varLastActivityAt, Now())
```

### Success transaction reference label `Text`

```powerfx
"Transaction reference: " & varLastTransactionId
```

### New transaction button `OnSelect`

```powerfx
Set(varLastActivityAt, Now());
Navigate(scrTransactionType, ScreenTransition.Fade)
```

### `tmrIdleSuccess` properties

Use the same timer settings as `tmrIdleTransactionType`.

Set `tmrIdleSuccess.OnTimerEnd` to:

```powerfx
If(
    DateDiff(varLastActivityAt, Now(), TimeUnit.Milliseconds) >= varIdleTimeoutMs,
    Set(varLastTransactionId, Blank());
    Navigate(scrWelcome, ScreenTransition.Fade)
)
```
