# rkt cat-manifest

For debugging or inspection you may want to extract the PodManifest to stdout.

```
# rkt cat-manifest --pretty-print UUID
{
  "acVersion":"0.7.0",
  "acKind":"PodManifest"
...
```

## Options

| Flag | Default | Options | Description |
| --- | --- | --- | --- |
| `--pretty-print` |  `false` | `true` or `false` | Apply indent to format the output |

## Global options

See the table with [global options in general commands documentation](../commands.md#global-options).
