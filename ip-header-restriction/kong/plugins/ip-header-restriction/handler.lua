local plugin = require("kong.plugins.base_plugin"):extend()
local iputils = require "resty.iputils"
local get_headers = ngx.req.get_headers
local inspect = require "inspect"

local FORBIDDEN = 403


-- cache of parsed CIDR values
local cache = {}


local plugin = {}

plugin.PRIORITY = 990
plugin.VERSION = "1.0.0"

local function to_binary_string(octets)
  local bin = ""
  for _, octet in ipairs(octets) do
      bin = bin .. string.char(octet)
  end

  return bin
end

local function get_binary_ip(ip)
  local parsed_ip, octets_or_err = iputils.ip2bin(ip)

  -- failed to parse the IP address
  if not parsed_ip and octets_or_err then
      return nil, octets_or_err
  end

  return to_binary_string(octets_or_err)
end


local function get_request_ip(conf)
  local binary_remote_addr = ngx.var.binary_remote_addr
  local headers = kong.request.get_headers()
  local header_value = ""

  for index, header_name in pairs(conf.headers) do
    if headers[header_name] then
      return get_binary_ip(headers[header_name])
    end
  end

  return binary_remote_addr
end

local function cidr_cache(cidr_tab)
  local cidr_tab_len = #cidr_tab

  local parsed_cidrs = kong.table.new(cidr_tab_len, 0) -- table of parsed cidrs to return

  -- build a table of parsed cidr blocks based on configured
  -- cidrs, either from cache or via iputils parse
  -- TODO dont build a new table every time, just cache the final result
  -- best way to do this will require a migration (see PR details)
  for i = 1, cidr_tab_len do
    local cidr        = cidr_tab[i]
    local parsed_cidr = cache[cidr]

    if parsed_cidr then
      parsed_cidrs[i] = parsed_cidr

    else
      -- if we dont have this cidr block cached,
      -- parse it and cache the results
      local lower, upper = iputils.parse_cidr(cidr)

      cache[cidr] = { lower, upper }
      parsed_cidrs[i] = cache[cidr]
    end
  end

  return parsed_cidrs
end

function plugin:init_worker()
  local ok, err = iputils.enable_lrucache()
  if not ok then
    kong.log.err("could not enable lrucache: ", err)
  end
end

function plugin:access(conf)
  local block = false
  local binary_remote_addr = get_request_ip(conf)

  if not binary_remote_addr then
    return kong.response.exit(FORBIDDEN, { message = "Cannot identify the client IP address, unix domain sockets are not supported." })
  end

  if conf.blacklist and #conf.blacklist > 0 then
    block = iputils.binip_in_cidrs(binary_remote_addr, cidr_cache(conf.blacklist))
  end

  if conf.whitelist and #conf.whitelist > 0 then
    block = not iputils.binip_in_cidrs(binary_remote_addr, cidr_cache(conf.whitelist))
  end

  if block then
    return kong.response.exit(FORBIDDEN, { message = "Your IP address is not allowed" })
  end
end

return plugin
