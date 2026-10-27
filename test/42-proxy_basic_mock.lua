#!/usr/bin/env lua

require 'Test.Assertion'

plan(13)

require 'Spore.Protocols'.request = function (req)
    matches(req.url, "^http://proxy.myorg:8080/restapi/show", "proxy")
    local host = req.headers['host']
    equals( host, 'services.org', "host" )
    local auth = req.headers['proxy-authorization']
    is_string( auth, "proxy-authorization is set" )
    equals( auth:sub(1, 6), "Basic ", "starts by 'Basic '" )
    local unenc = require 'mime'.unb64(auth:sub(7))
    equals( unenc, "john:s3kr3t", "john:s3kr3t" )
    return {
        request = req,
        status  = 200,
        headers = {},
        body    = 'dummy',
    }
end -- mock

os.getenv = function () return 'http://john:s3kr3t@proxy.myorg:8080' end --mock

local Spore = require 'Spore'

if not require_ok 'Spore.Middleware.Proxy.Basic' then
    skip_rest "no Spore.Middleware.Proxy.Basic"
    os.exit()
end

local client = Spore.new_from_spec './test/api.json'
client:enable('Proxy.Basic', {
    proxy    = 'http://proxy.myorg:8080',
    username = 'john',
    password = 's3kr3t',
})

local r = client:get_info()
equals( r.body, 'dummy' )

r = client:get_info()
equals( r.body, 'dummy' )
