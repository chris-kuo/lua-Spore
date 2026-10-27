
# Spore.OpenAPI

---

# Reference

With this module, lua-Spore becomes a
[OpenAPI](https://www.openapis.org/)
client for Lua.

__LIMITATION__ : external references are not supported.

## Global Functions

#### new_from_openapi( desc, [, { options } [, tag]] )

Instanciate a ReST client from a
[OpenAPI](https://www.openapis.org/)
specification defined by an URL or a filename (encoded in YAML).

The optional table `options` allows to overwrite some parameters of the description
(see `Spore.new_from_spec`).

The optional `tag` allows to keep only methods/operations having this tag.

```lua
local openapi = require 'Spore.OpenAPI'
local client = openapi.new_from_openapi http://petstore3.swagger.io/api/v3/openapi.yaml
local pet = openapi.new_from_openapi(http://petstore3.swagger.io/api/v3/openapi.yaml, {}, 'pet')
```

#### convert( doc [, tag] )

Converts a
[OpenAPI](https://www.openapis.org/)
specification into a SPORE specification (both are represented by a table).

The optional `tag` allows to keep only methods/operations having this tag.

## Utilities

#### openapi2spore url

Converts a
[OpenAPI](https://www.openapis.org/)
sprecification into a SPORE specification.
By this way, the SPORE specification could be edited/modified before use.

```sh
$ openapi2spore http://petstore3.swagger.io/api/v3/openapi.yaml > petstore.json
$ openapi2spore --tag pet   http://petstore3.swagger.io/api/v3/openapi.yaml > pet.json
$ openapi2spore --tag store http://petstore3.swagger.io/api/v3/openapi.yaml > store.json
$ openapi2spore --tag user  http://petstore3.swagger.io/api/v3/openapi.yaml > user.json
```

# Examples

## OpenAPI Petstore

```lua
local openapi = require 'Spore.OpenAPI'

local store = openapi.new_from_openapi('http://petstore3.swagger.io/api/v3/openapi.yaml', {}, 'store')
store:enable 'Format.JSON'
local inventory = store:getInventory()
print(inventory.body)

local user = openapi.new_from_openapi('http://petstore3.swagger.io/api/v3/openapi.yaml', {}, 'user')
local login = user:loginUser{username='user', password='user'}
print(login.status)
print(login.body)

local logout = user:logoutUser()
print(logout.status)
```
