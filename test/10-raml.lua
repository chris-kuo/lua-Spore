#!/usr/bin/env lua

require 'Test.Assertion'

if not pcall(require, 'lyaml') then
    skip_all 'no lyaml'
end

plan(14)

local doc = [[
#%RAML 1.0
title: api
description: api for unit test
version: v1
baseUri: http://services.org:9999/restapi

/show:
  get:
    displayName: get_info
    description: blah, blah
    queryParameters:
      user:
        required: true
      border:
        required: false
    responses:
      200:

  /{id}:
    get:
      displayName: get_detailed_info
      queryParameters:
        border:
          required: false
      responses:
        200:
]]
require 'Spore.Protocols'.slurp = function ()
    return doc
end -- mock

require 'Spore'.new_from_lua = function (t)
    return t
end --mock

local m = require 'Spore.RAML'
is_table( m, "Spore.RAML" )
equals( m, package.loaded['Spore.RAML'] )

is_function( m.new_from_raml )
is_function( m.convert )

local spec = m.new_from_raml('mock', {})
equals( spec.name, 'api' )
equals( spec.version, 'v1' )
equals( spec.description, 'api for unit test' )
equals( spec.base_url, 'http://services.org:9999/restapi' )
local meth = spec.methods.get_info
is_table( meth )
equals( meth.path, '/show' )
equals( meth.method, 'GET' )

meth = spec.methods.get_detailed_info
is_table( meth )
equals( meth.path, '/show/{id}' )
equals( meth.method, 'GET' )
