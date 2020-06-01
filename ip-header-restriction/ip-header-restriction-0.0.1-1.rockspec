package = "ip-header-restriction"
version = "0.0.1-1"
supported_platforms = {"linux", "macosx"}

source = {
  url = "http://github.com/Kong/kong-plugin.git",
  tag = "0.0.1"
}

description = {
  summary = "Kong plugin to restrict access to endpoint by forwared ip in header.",
  homepage = "https://github.com/williampsena/ip-header-restriction",
  license = "MIT"
}

dependencies = {
  "lua ~> 5.1"
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins.ip-header-restriction.handler"] = "kong/plugins/ip-header-restriction/handler.lua",
    ["kong.plugins.ip-header-restriction.schema"] = "kong/plugins/ip-header-restriction/schema.lua"
  }
}