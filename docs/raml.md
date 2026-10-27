
# Spore.RAML

---

# Reference

This module allows to use a
[RESTful API Modeling Language](https://raml.org/)
document as a SPORE specification.

__LIMITATION__ : inheritance of resources & traits is not supported.

__LIMITATION__ : librairies and their inclusion are not supported.

This module requires [lyaml](https://github.com/gvvaughan/lyaml) (YAML 1.1).

## Global Functions

#### new_from_raml( desc, [, { options }] )

Instanciate a ReST client from a [RAML](https://raml.org/)
document defined by an URL or a filename.

The optional table `options` allows to overwrite some parameters
of the description (see `Spore.new_from_spec`).

```lua
local raml = require 'Spore.RAML'
local client = wadl.new_from_raml 'helloworld.raml'
```

#### convert( raml )

Converts a [RAML](https://raml.org/)
document into a SPORE specification (both are represented by a table).

## Utilities

#### raml2spore url

Converts a RAML document into a Spore Specification. By this way, the SPORE specification could be edited/modified before use.

```
$ raml2spore helloworld.raml > helloworld.json
```

# Examples

Not yet.
