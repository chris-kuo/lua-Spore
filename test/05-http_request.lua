#!/usr/bin/env lua

require 'Test.Assertion'

plan(8)

local headers = {}
require 'Spore.Protocols'.request = function (req)
    return {
        status  = 200,
        headers = headers,
    }
end  -- mock

local Spore = require 'Spore'

local client = Spore.new_from_spec './test/api.json'

local res = client:get_user_info{ payload = 'opaque data', user = 'john' }
equals( res.headers, headers, "without middleware" )

client:enable 'Format.JSON'
res = client:get_user_info{ payload = 'opaque data', user = 'john' }
equals( res.headers, headers, "with middleware" )

client:enable 'UserAgent'
res = client:get_info()
equals( res.headers, headers, "with middleware" )

local dummy_resp = { status = 200 }
package.loaded['Spore.Middleware.Dummy'] = {
    call = function (_, req)
        return dummy_resp
    end,
}

client:reset_middlewares()
client:enable 'Dummy'
res = client:get_info()
equals( res, dummy_resp, "with dummy middleware" )

dummy_resp.status = 599
res = client:get_info()
equals( res, dummy_resp, "with dummy middleware" )

local async_resp = { status = 201 }
package.loaded['Spore.Middleware.Async'] = {
    call = function(_, req)
        -- mock async task such as http request that runs this in callback
        return coroutine.wrap(function() return coroutine.yield(async_resp) end)
    end,
}

local co = coroutine.create(function()
    res = client:get_info()
    equals( res.status, async_resp.status, "in coro" )
end)
is_thread( co, "coro" )
equals( coroutine.status(co), 'suspended' )

client:reset_middlewares()
client:enable('Async', {thread = co})
while coroutine.status(co) ~= 'dead' do
    coroutine.resume(co)
end
