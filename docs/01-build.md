# Building a plugin using zigr2p

zigr2p is built using the latest Mach nominated Zig version, which is currently `2024.11.0-mach`, or `0.14.0-dev.2577+271452d22`.

Check the latest Mach nominated Zig version and how to download it on (Mach's website)[https://machengine.org/docs/nominated-zig/].

To build a plugin, you must execute `zig build` with at least its required parameters.

## Build parameters

# Required

- `Dname` - The name of your plugin.
- `Dctx` - The context for which your plugin is built:
    - `dedicated` - server plugin
    - `client` - client plugin
    - `both` - server & client plugin

# Optional

- `DlogName` - The name displayed in the Northstar console when logging. This **should** be a 9 character uppercase letter string, but it doesn't have to be. If left undefined, it will inherit the value of `Dname`.
- `DdepName` - Dependency name. This is used by other plugins that depend on this plugin to identify it. If left undefined, it will inherit the value of `Dname`.
- `Dcolor` - Colour used for the name displayed in the Northstar console when logging. If left undefined, the colour used will be the Northstar default one.