#!/usr/bin/env lua

require 'Test.Assertion'

plan(16)

if not require_ok 'Spore.Middleware.Cookie.Session' then
    skip_rest "no Spore.Middleware.Cookie.Session"
    os.exit()
end
local mw = require 'Spore.Middleware.Cookie.Session'
is_table( mw.store, "store" )

local req = require 'Spore.Request'.new({
    SERVER_NAME = 'services.org',
    PATH_INFO = '/path',
    spore = {
        caller = 'fake',
        url_scheme = 'http',
        method = {
            unattended_params = true,
        },
        params = {},
    }
})
is_table( req, "Spore.Request.new" )
is_table( req.headers )

local cb = mw.call({}, req)
is_function( cb )

local resp = {
    status = 200,
    headers = {},
}
local set_cookie = {}
resp.headers['set-cookie'] = table.concat(set_cookie, ', ')
cb(resp)
is_nil( req.headers['cookie'] )

cb = mw.call({}, req)
is_function( cb )

set_cookie[#set_cookie+1] = "name1=value1; SameSite=Lax; Secure; HttpOnly"
resp.headers['set-cookie'] = table.concat(set_cookie, ', ')

cb(resp)
equals( mw.store.name1, 'value1' )

cb = mw.call({}, req)
equals( req.headers['cookie'], "name1=value1" )
is_function( cb )

set_cookie[#set_cookie+1] = "name2=value2; SameSite=Lax; Secure"
resp.headers['set-cookie'] = table.concat(set_cookie, ', ')

cb(resp)
equals( mw.store.name2, 'value2' )

cb = mw.call({}, req)
matches( req.headers['cookie'], "name%d=value%d; name%d=value%d" )
is_function( cb )

set_cookie[#set_cookie+1] = "name1=; SameSite=Lax"
resp.headers['set-cookie'] = table.concat(set_cookie, ', ')

cb(resp)
is_nil( mw.store.name1 )

cb = mw.call({}, req)
equals( req.headers['cookie'], "name2=value2" )
is_function( cb )
