#!/usr/bin/env lua

require 'Test.Assertion'

if not pcall(require, 'lyaml') then
    skip_all 'no lyaml'
end

plan(29)

local doc = [[
openapi: 3.0.0
info:
  title: api3
  version: v3
  description: api3 for unit test
tags:
  - name: tagged
    description: filtered
servers:
  - url: 'http://services.org:9999/restapi'
paths:
  /show:
    parameters:
      - name: user
        in: query
        required: true
    get:
      operationId: get_info
      summary: blah
      description: 'blah, blah'
      tags:
        - tagged
      parameters:
        - name: border
          in: query
          required: false
      responses:
        '200':
          description: Ok.
]]
require 'Spore.Protocols'.slurp = function ()
    return doc
end -- mock

require 'Spore'.new_from_lua = function (t)
    return t
end --mock

local m = require 'Spore.OpenAPI'
is_table( m, "Spore.OpenAPI" )
equals( m, package.loaded['Spore.OpenAPI'] )

is_function( m.new_from_openapi )
is_function( m.convert )

local spec = m.new_from_openapi('mock', {}, 'tagged')
equals( spec.name, 'api3' )
equals( spec.version, 'v3' )
equals( spec.description, 'filtered' )
equals( spec.base_url, 'http://services.org:9999/restapi' )
local meth = spec.methods.get_info
is_table( meth )
equals( meth.path, '/show' )
equals( meth.method, 'GET' )
equals( meth.description, 'blah' )
array_equals( meth.required_params, { 'user' } )
array_equals( meth.optional_params, { 'border' } )
array_equals( meth.expected_status, { 200 } )

spec = m.new_from_openapi('mock', {}, 'bad tag')
is_nil( spec.methods.get_info, "empty spec.methods" )

spec = m.new_from_openapi('mock')
is_table( spec.methods.get_info )
equals( spec.description, 'api3 for unit test' )

doc = [[
openapi: 3.0.0
info:
  title: api3
  version: v3
  description: api3 for unit test
tags:
  - name: tagged
    description: filtered
servers:
  - url: 'http://services.org:9999/restapi'
paths:
  /show:
    get:
      operationId: get_info
      summary: blah
      description: 'blah, blah'
      tags:
        - tagged
      parameters:
        - $ref: '#/components/parameters/user'
        - $ref: '#/components/parameters/border'
      responses:
        '200':
          description: Ok.
components:
  parameters:
    user:
      name: user
      in: query
      required: true
    border:
      name: border
      in: query
      required: false
]]

spec = m.new_from_openapi('mock')
equals( spec.name, 'api3' )
equals( spec.version, 'v3' )
equals( spec.description, 'api3 for unit test' )
equals( spec.base_url, 'http://services.org:9999/restapi' )
meth = spec.methods.get_info
is_table( meth )
equals( meth.path, '/show' )
equals( meth.method, 'GET' )
equals( meth.description, 'blah' )
array_equals( meth.required_params, { 'user' } )
array_equals( meth.optional_params, { 'border' } )
array_equals( meth.expected_status, { 200 } )
