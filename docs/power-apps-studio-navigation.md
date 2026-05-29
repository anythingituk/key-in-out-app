# Power Apps Studio Navigation

This guide covers the common Power Apps Studio tasks that are hard to find when building the canvas app manually.

## What Can Be Scripted

Can be scripted:

- SharePoint Lists and columns
- sample tenant imports
- documentation
- Power Fx formulas to copy into controls
- pasteable Power Apps Code View YAML for controls/screen contents
- Git repository setup

Not reliably scriptable as a normal PowerShell-only workflow:

- creating arbitrary canvas screens and controls from PowerShell
- wiring the entire canvas app without Power Apps Studio
- importing hand-written canvas YAML as a fully supported app build process

Power Apps Studio Code View is the useful middle ground: generated YAML can be copied, edited outside Studio, and pasted back into a screen to create controls. Microsoft documents two important limits: the App object cannot be viewed/copied/pasted through Code View, and the Code View popup itself is not an editor.

Microsoft also supports canvas app source files for source control, but generated `.pa.yaml` files are read-only outside supported Git integration workflows. The Power Platform CLI can download, pack, and unpack app files, but `pack` and `unpack` are deprecated, so this project avoids relying on fragile generated `.msapp` internals.

## Recommended Build Approach

1. Create each screen manually in Power Apps Studio.
2. Use Code View YAML snippets to paste screen contents where available.
3. Set App-level properties manually, especially `App.StartScreen` and `App.OnStart`.
4. Add SharePoint data sources manually.
5. Test with the fake SharePoint records.
6. Export the finished app package for backup once it works.

## Code View Workflow

Code View can speed up screen building.

Use this pattern:

1. Create or select a screen.
2. Right-click the screen or a control in Tree view.
3. Select **View code**.
4. Use **Copy code** to copy existing YAML.
5. Edit the YAML outside Power Apps Studio if needed.
6. Paste YAML into the target screen with `Ctrl+V`.

For this project, the most practical approach is:

1. Create the screens manually with the correct names.
2. Paste generated controls into each screen using Code View/YAML.
3. Manually set `App.StartScreen` and `App.OnStart`.

If generated YAML fails to paste, create one simple control in your app, choose **View code**, and use that as the reference format for that environment.

## Show Tree View

Use the left rail and select **Tree view**.

Tree view is where you rename screens and controls.

## Rename a Screen or Control

1. Open **Tree view**.
2. Select the screen or control.
3. Select the three-dot menu.
4. Choose **Rename**.
5. Enter the exact name from the guide.

Example screen names:

- `scrWelcome`
- `scrTransactionType`
- `scrTenantSearch`
- `scrTenantConfirm`
- `scrKeyDetails`
- `scrSuccess`

## Set the Start Screen

1. In **Tree view**, select **App** at the top.
2. In the property dropdown near the formula bar, choose **StartScreen**.
3. Set the formula to:

```powerfx
scrWelcome
```

If `StartScreen` is not visible in the dropdown, use the search box in the property dropdown and type `StartScreen`.

## Set App OnStart

1. In **Tree view**, select **App**.
2. In the property dropdown, choose **OnStart**.
3. Paste the `App.OnStart` formula from `powerapps/formulas.md`.
4. Select the **Run OnStart** command from the app menu after saving the formula.

## Add SharePoint Data Sources

1. Open the **Data** panel.
2. Select **Add data**.
3. Search for **SharePoint**.
4. Connect to the target SharePoint site.
5. Select these lists:
   - `TenantTracker`
   - `KeyTransactions`

## Add a Button

1. Select **Insert**.
2. Select **Button**.
3. Rename it in Tree view.
4. Use the property dropdown to set:
   - `Text`
   - `OnSelect`
   - `DisplayMode`, if needed

## Add a Text Input

1. Select **Insert**.
2. Select **Text input**.
3. Rename it in Tree view.
4. Use the property dropdown to set:
   - `HintText`
   - `OnChange`
   - `Default`, if needed

## Add a Gallery

1. Select **Insert**.
2. Select **Gallery**.
3. Choose a vertical gallery.
4. Rename it to `galTenantResults`.
5. Set the gallery `Items` formula.
6. Select controls inside the gallery template and set their `Text` formulas.
7. Set the gallery `OnSelect` and `TemplateFill` formulas.

## Add a Timer

1. Select **Insert**.
2. Search for **Timer**.
3. Add it to the screen.
4. Rename it using the guide.
5. Set:
   - `Duration`
   - `AutoStart`
   - `Repeat`
   - `Visible`
   - `OnTimerEnd`

The timer can sit anywhere on the screen because `Visible` is set to `false`.

## Add Pen Input

1. Select **Insert**.
2. Search for **Pen input**.
3. Add one for the tenant signature and one for staff signature.
4. Rename them:
   - `penTenantSignature`
   - `penStaffSignature`

## Formula Bar Basics

Most setup work follows this pattern:

1. Select a screen or control.
2. Choose the property from the dropdown near the formula bar.
3. Paste the matching Power Fx formula.

If a formula mentions a control that does not exist yet, Power Apps shows an error until that control is created and named correctly.
