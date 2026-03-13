# Worlds Artifact Layout

Artifacts are grouped by world and scope:

- `worlds/<world_id>/<scope>/publish_<manifest_hash>.json`
- `worlds/<world_id>/<scope>/latest.json`

`publish_<manifest_hash>.json` files are immutable snapshots.
`latest.json` points at the current selected snapshot for that scope.
