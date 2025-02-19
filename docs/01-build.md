# Building a plugin using zigr2p

zigr2p is built using the latest Mach nominated Zig version, which is currently `2024.11.0-mach`, or `0.14.0-dev.2577+271452d22`.

Check the latest Mach nominated Zig version and how to download it on [Mach's website](https://machengine.org/docs/nominated-zig/).

## Build parameters

### Required

- `Dname` - The name of your plugin.
- `Dctx` - The context for which your plugin is built:
    - `dedicated` - server plugin
    - `client` - client plugin
    - `both` - server & client plugin

### Optional

- `DlogName` - The name displayed in the Northstar console when logging. The value of this parameter is automatically converted to an uppercase string. If left undefined, it will inherit the value of `Dname`.
- `DdepName` - Dependency name. This is used by other plugins that depend on this plugin to identify it. If left undefined, it will inherit the value of `Dname`.
- `Dcolor` - Colour used for the name displayed in the Northstar console when logging. If left undefined, the colour used will be the Northstar default one.

## Building from the template (preferred)
- Clone the [template's](https://github.com/okvdai/zigr2p-template/) source
- Modify the `build.zig` and `root.zig` as per your requirements
- Run the `zig build` command

## Building from this repository's source

- Clone this repository's source in your favoured way
- Run the `zig build` command, for example `zig build -Dname=test -Dctx=both`
