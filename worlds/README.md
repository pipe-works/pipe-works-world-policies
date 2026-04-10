# Worlds Artifact Layout

Artifacts are grouped by world and scope:

- `worlds/<world_id>/<scope>/publish_<manifest_hash>.json`
- `worlds/<world_id>/<scope>/latest.json`

`publish_<manifest_hash>.json` files are immutable snapshots.
`latest.json` points at the current selected snapshot for that scope.

Pointer contract:

- `artifact_file` should name the sibling artifact file in the same directory.
- `artifact_path` should be portable and repo-relative, for example
  `worlds/<world_id>/<scope>/publish_<manifest_hash>.json`.
- Do not commit workstation-specific absolute paths into `latest.json`.
