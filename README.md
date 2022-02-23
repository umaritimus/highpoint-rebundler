# highpoint-rebundler
Rebundle highpoint deliverables into a single bundle

## Requirements
1. Create `manifest.json` in the current working directory (see `manifest.example.json`).

> _Note:_ Ensure that the bundle `filename` is reflecting the Highpoint release version and all the `path`s are correctly specified in unix format.

## Deployment

1. Examine `HPT_BUNDLE/manifest.json` to confirm the bundled Highpoint versions
1. Copy `HPT_BUNDLE/class` to the designated classpath
1. Add other `HPT_BUNDLE/*` objects to version/change control

