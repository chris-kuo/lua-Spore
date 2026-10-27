
# Spore.Swagger

---

# Reference

With this module, lua-Spore becomes a
[Swagger / OpenAPI](https://www.openapis.org/)
client for Lua.

## Global Functions

#### new_from_swagger( desc, [, { options } [, tag]] )

Instanciate a ReST client from a
[Swagger / OpenAPI](https://www.openapis.org/)
specification defined by an URL or a filename (encoded in JSON).

The optional table `options` allows to overwrite some parameters of the description
(see `Spore.new_from_spec`).

The optional `tag` allows to keep only methods/operations having this tag.

```lua
local swagger = require 'Spore.Swagger'
local client = swagger.new_from_swagger http://petstore3.swagger.io/api/v3/openapi.json
local pet = swagger.new_from_swagger(http://petstore3.swagger.io/api/v3/openapi.json, {}, 'pet')
```

#### convert( doc [, tag] )

Converts a
[Swagger / OpenAPI](https://www.openapis.org/)
specification into a SPORE specification (both are represented by a table).

The optional `tag` allows to keep only methods/operations having this tag.

## Utilities

#### swagger2spore url

Converts a
[Swagger / OpenAPI](https://www.openapis.org/)
sprecification into a SPORE specification.
By this way, the SPORE specification could be edited/modified before use.

```sh
$ swagger2spore http://petstore3.swagger.io/api/v3/openapi.json > petstore.json
$ swagger2spore --tag pet   http://petstore3.swagger.io/api/v3/openapi.json > pet.json
$ swagger2spore --tag store http://petstore3.swagger.io/api/v3/openapi.json > store.json
$ swagger2spore --tag user  http://petstore3.swagger.io/api/v3/openapi.json > user.json
```

# Examples

## Swagger Petstore

```lua
local swagger = require 'Spore.Swagger'

local store = swagger.new_from_swagger('http://petstore.swagger.io/v2/swagger.json', {}, 'store')
store:enable 'Format.JSON'
local inventory = store:getInventory()
print(inventory.body)

local user = swagger.new_from_swagger('http://petstore.swagger.io/v2/swagger.json', {}, 'user')
local login = user:loginUser{username='user', password='user'}
print(login.status)
print(login.body)

local logout = user:logoutUser()
print(logout.status)
```

## OpenAPI Petstore

```lua
local swagger = require 'Spore.Swagger'

local store = swagger.new_from_swagger('http://petstore3.swagger.io/api/v3/openapi.json', {}, 'store')
store:enable 'Format.JSON'
local inventory = store:getInventory()
print(inventory.body)

local user = swagger.new_from_swagger('http://petstore3.swagger.io/api/v3/openapi.json', {}, 'user')
local login = user:loginUser{username='user', password='user'}
print(login.status)
print(login.body)

local logout = user:logoutUser()
print(logout.status)
```
