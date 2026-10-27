#!/usr/bin/env lua

require 'Test.Assertion'

plan(5)

require 'Spore.Protocols'.request = function (req)
    return {
        status  = 222,
        headers = {},
    }
end  -- mock

if not require_ok 'Spore.Middleware.Redirection' then
    skip_rest "no Spore.Middleware.Redirection"
    os.exit()
end
local mw = require 'Spore.Middleware.Redirection'

local req = require 'Spore.Request'.new({ spore = { method = {}, params = {} } })
is_table( req, "Spore.Request.new" )

local cb = mw.call( {}, req )
is_function( cb )

local res = { status = 200, headers = {} }
local r = cb(res)
equals( r, res )

res = { status = 301, headers = { location = "http://next.org" } }
r = cb(res)
equals( r.status, 222 )
