# giflib

Lua bindings to [GIFLIB](http://giflib.sourceforge.net/) for LuaJIT using FFI.

## Installation

You'll need both LuaJIT (any version) and GIFLIB 5 installed. On ArchLinux:

```bash
$ sudo pacman -Sy luajit giflib
```

It's recommended to use LuaRocks to install **giflib**.

```bash
$ luarocks install --server=http://luarocks.org/dev giflib
```

## Basic Usage

This library was created for a very specific usage and does not expose the
entire GIFLIB API. Feel free to create an issue if there's something specific
you need.

```lua
import load_gif from require "giflib"

local gif = assert(load_gif("test.gif"))
gif:write_first_frame("test-frame-1.gif")
gif:close()
```

**TODO: more documentation**
