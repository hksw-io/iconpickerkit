# AGENTS.md

Instructions for agents working in this repository.

## Media and demo

Run `swift run --package-path Demo GenerateMedia` from the repository root in a logged-in macOS
session. It rewrites the
`IconPickerRow` stills in `Docs/Media`, which are Mac renders. The `IconPickerView` stills and the
demo are captured from the iOS 27.2 Simulator (iPhone 17 Pro), because a Mac render at phone width
would not show iOS touch sizing.

`./Demo/run-demo.sh` builds a real Mac app and opens it (Dock and Cmd-Tab). Catalog is the full picker with color and search pinned; its Demo section shows an app's own icons. Form row is the compact control, which cannot draw those. The inspector hint plus **Delay 2 seconds** starts canned suggestions after a pause so you can scroll first. **Reload** runs that again. Turn Delay off to use the on-device model.

## Releases

- A minor release may contain a breaking change, marked **Breaking** in `CHANGELOG.md`, so consumers pin exact versions.
