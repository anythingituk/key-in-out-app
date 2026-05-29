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

## App Object Limitation

Code View does not support copying, pasting, or viewing the App object. Set these manually in Power Apps Studio:

- `App.StartScreen`
- `App.OnStart`

## Next Calibration Step

Power Apps Code View YAML can vary by control type and Studio version.

To make generated snippets paste cleanly, copy the Code View output from one simple control in your current app and use it as the reference format.

Good calibration controls:

- a basic button
- a text label
- a blank screen with one button

Once the format is confirmed, generate one snippet per screen.
