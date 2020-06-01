local typedefs = require "kong.db.schema.typedefs"


return {
  name = "ip-header-restriction",
  fields = {
    { protocols = typedefs.protocols_http },
    { config = {
        type = "record",
        fields = {
          { headers = { type = "array", elements = typedefs.header_name, required = true }, },
          { whitelist = { type = "array", elements = typedefs.cidr_v4, }, },
          { blacklist = { type = "array", elements = typedefs.cidr_v4, }, },
        },
      },
    },
  },
  entity_checks = {
    { only_one_of = { "config.whitelist", "config.blacklist" }, },
    { at_least_one_of = { "config.whitelist", "config.blacklist" }, },
  },
}

