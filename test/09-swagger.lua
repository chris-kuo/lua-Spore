#!/usr/bin/env lua

require 'Test.Assertion'

plan(32)

local doc = [[
{
  "swagger": "2.0",
  "info": {
    "title": "api",
    "version": "v1",
    "description": "api for unit test"
  },
  "tags": [
    {"name": "tagged", "description": "filtered"}
  ],
  "schemes": ["http"],
  "host": "services.org:9999",
  "basePath": "/restapi",
  "paths": {
    "/show": {
      "parameters": [
        {
          "name": "user",
          "in": "query",
          "required": true
        }
      ],
      "get": {
        "operationId": "get_info",
        "summary": "blah",
        "description": "blah, blah",
        "tags": ["tagged"],
        "parameters": [
          {
            "name": "border",
            "in": "query",
            "required": false
          }
        ],
        "responses": {
          "200": {
            "description": "Ok."
          }
        }
      }
    }
  }
}
]]
require 'Spore.Protocols'.slurp = function ()
    return doc
end -- mock

require 'Spore'.new_from_lua = function (t)
    return t
end --mock

local m = require 'Spore.Swagger'
is_table( m, "Spore.Swagger" )
equals( m, package.loaded['Spore.Swagger'] )

is_function( m.new_from_swagger )
is_function( m.convert )

local spec = m.new_from_swagger('mock', {}, 'tagged')
equals( spec.name, 'api' )
equals( spec.version, 'v1' )
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

spec = m.new_from_swagger('mock', {}, 'bad tag')
is_nil( spec.methods.get_info, "empty spec.methods" )

spec = m.new_from_swagger('mock')
is_table( spec.methods.get_info )
equals( spec.description, 'api for unit test' )

doc = [[
{
  "openapi": "3.0.0",
  "info": {
    "title": "api3",
    "version": "v3",
    "description": "api3 for unit test"
  },
  "tags": [
    {"name": "tagged", "description": "filtered"}
  ],
  "servers": [
    {"url": "http://services.org:9999/restapi"}
  ],
  "paths": {
    "/show": {
      "parameters": [
        {
          "name": "user",
          "in": "query",
          "required": true
        }
      ],
      "get": {
        "operationId": "get_info",
        "summary": "blah",
        "description": "blah, blah",
        "tags": ["tagged"],
        "parameters": [
          {
            "name": "border",
            "in": "query",
            "required": false
          }
        ],
        "responses": {
          "200": {
            "description": "Ok."
          }
        }
      }
    }
  }
}
]]

spec = m.new_from_swagger('mock', {}, 'tagged')
equals( spec.name, 'api3' )
equals( spec.version, 'v3' )
equals( spec.description, 'filtered' )
equals( spec.base_url, 'http://services.org:9999/restapi' )
meth = spec.methods.get_info
is_table( meth )
equals( meth.path, '/show' )
equals( meth.method, 'GET' )
equals( meth.description, 'blah' )
array_equals( meth.required_params, { 'user' } )
array_equals( meth.optional_params, { 'border' } )
array_equals( meth.expected_status, { 200 } )

spec = m.new_from_swagger('mock', {}, 'bad tag')
is_nil( spec.methods.get_info, "empty spec.methods" )

spec = m.new_from_swagger('mock')
is_table( spec.methods.get_info )
equals( spec.description, 'api3 for unit test' )

