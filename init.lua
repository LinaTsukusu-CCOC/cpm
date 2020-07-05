local getopt = require("getopt")
local main = require "cpm"

main(getopt({...}, {
    h = "boolean", help = "boolean",
    g = "boolean", global = "boolean",
}))