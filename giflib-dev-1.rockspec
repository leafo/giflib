package = "giflib"
version = "dev-1"

source = {
  url = "git://github.com/leafo/giflib.git",
}

description = {
  summary = "LuaJIT FFI binding to giflib",
  license = "MIT",
  maintainer = "Leaf Corcoran <leafot@gmail.com>",
}

dependencies = {
  "lua == 5.1", -- how to do luajit?
}

build = {
  type = "builtin",
  modules = {
    ["giflib"] = "giflib/init.lua",
    ["giflib.lib"] = "giflib/lib.lua",
  }
}
