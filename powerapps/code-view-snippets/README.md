# Power Apps Code View Snippets

Power Apps Studio Code View can create controls from pasted YAML.

This folder is for paste-ready snippets generated for the app screens.

## Current Plan

Create the app screens manually:

- `scrWelcome`
- `scrTransactionType`
- `scrTenantSearch`
- `scrTenantConfirm`
- `scrKeyDetails`
- `scrSuccess`

Then paste generated controls into each screen.

## Snippets

Paste these files into the matching screen:

| Screen | Snippet |
|---|---|
| `scrWelcome` | `scrWelcome.yaml` |
| `scrTransactionType` | `scrTransactionType.yaml` |
| `scrTenantSearch` | `scrTenantSearch.yaml` |
| `scrTenantConfirm` | `scrTenantConfirm.yaml` |
| `scrKeyDetails` | `scrKeyDetails.yaml` |
| `scrSuccess` | `scrSuccess.yaml` |

The snippets use modern controls:

- `ModernText@1.0.0`
- `ModernButton@1.0.0`
- `ModernTextInput@1.0.0`
- `ModernNumberInput@1.0.0`
- `ModernDataGrid@1.1.0`

## Paste Steps

1. Open the target screen in Power Apps Studio.
2. Select the screen in Tree view.
3. Paste the full YAML from the matching snippet with `Ctrl+V`.
4. If Power Apps asks for clipboard permission, allow it.
5. Save the app after each successful paste.

## App Object Limitation

Code View does not support copying, pasting, or viewing the App object. Set these manually in Power Apps Studio:

- `App.StartScreen`
- `App.OnStart`

## Manual Controls Still Needed

These are still manual until their exact Code View YAML is confirmed:

- idle timeout timers
- tenant pen input
- staff pen input

The `scrKeyDetails.yaml` submit button saves the transaction without signatures in this first pasteable version. Add the pen input controls manually and then update the submit formula from `powerapps/formulas.md` if signatures are needed immediately.

## Calibration Notes

Power Apps Code View YAML can vary by control type and Studio version.

The first calibration sample for this app was:

```yaml
- Button1:
    Control: ModernButton@1.0.0
    Properties:
      LayoutMinHeight: =16
      LayoutMinWidth: =16
```

If a snippet fails to paste, copy the Code View output from one simple control in your current app and use it as the reference format.

Good calibration controls:

- a basic button
- a text label
- a blank screen with one button

Once the format is confirmed, generate one snippet per screen.
