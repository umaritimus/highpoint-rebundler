# highpoint-rebundler
Rebundle highpoint deliverables into a single bundle

## Requirements
1. Create `manifest.json` in the current working directory (see `manifest.example.json`).

> _Note:_ Ensure that the bundle `filename` is reflecting the Highpoint release version and all the `path`s are correctly specified in unix format.

## Deployment

1. Once `manifest.json` is created in pwd, execute `rebundle.ps1`
1. Once complete, expand the new bundle at path/filename specified in the manifest
1. Examine `manifest.json` to confirm the bundled Highpoint versions
1. Copy `HPT_BUNDLE/class/*` to the designated classpath (or add the hpt_bundle to dpk manifest)
1. Add other `HPT_BUNDLE/*` objects to version/change control

