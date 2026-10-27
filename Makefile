
ifeq ($(wildcard bed),bed)
LUA     := $(CURDIR)/bed/bin/lua
LUACHECK:= $(CURDIR)/bed/bin/luacheck
LUAROCKS:= $(CURDIR)/bed/bin/luarocks
LUACOV  := $(CURDIR)/bed/bin/luacov
LUACOV_C:= $(CURDIR)/bed/bin/luacov-console
else
LUA     := lua
LUACHECK:= luacheck
LUAROCKS:= luarocks
LUACOV  := luacov
LUACOV_C:= luacov-console
endif
VERSION := $(shell LUA_PATH=";;src/?.lua" $(LUA) -e "m = require [[Spore]]; print(m._VERSION)")
TARBALL := lua-spore-$(VERSION).tar.gz
REV     := 1

LUAVER  := 5.3
PREFIX  := /usr/local
DPREFIX := $(DESTDIR)$(PREFIX)
BINDIR  := $(DPREFIX)/bin
LIBDIR  := $(DPREFIX)/share/lua/$(LUAVER)
INSTALL := install

BED_OPTS:= --lua 5.3

all:
	@echo "Nothing to build here, you can just make install"

install:
	$(INSTALL) -m 755 -D src/discovery2spore                        $(BINDIR)/discovery2spore
	$(INSTALL) -m 755 -D src/raml2spore                             $(BINDIR)/raml2spore
	$(INSTALL) -m 755 -D src/swagger2spore                          $(BINDIR)/swagger2spore
	$(INSTALL) -m 755 -D src/wadl2spore                             $(BINDIR)/wadl2spore
	$(INSTALL) -m 644 -D src/Spore.lua                              $(LIBDIR)/Spore.lua
	$(INSTALL) -m 644 -D src/Spore/GoogleDiscovery.lua              $(LIBDIR)/Spore/GoogleDiscovery.lua
	$(INSTALL) -m 644 -D src/Spore/OpenAPI.lua                      $(LIBDIR)/Spore/OpenAPI.lua
	$(INSTALL) -m 644 -D src/Spore/Protocols.lua                    $(LIBDIR)/Spore/Protocols.lua
	$(INSTALL) -m 644 -D src/Spore/RAML.lua                         $(LIBDIR)/Spore/RAML.lua
	$(INSTALL) -m 644 -D src/Spore/Request.lua                      $(LIBDIR)/Spore/Request.lua
	$(INSTALL) -m 644 -D src/Spore/Swagger.lua                      $(LIBDIR)/Spore/Swagger.lua
	$(INSTALL) -m 644 -D src/Spore/WADL.lua                         $(LIBDIR)/Spore/WADL.lua
	$(INSTALL) -m 644 -D src/Spore/XML.lua                          $(LIBDIR)/Spore/XML.lua
	$(INSTALL) -m 644 -D src/Spore/Middleware/Cache.lua             $(LIBDIR)/Spore/Middleware/Cache.lua
	$(INSTALL) -m 644 -D src/Spore/Middleware/DoNotTrack.lua        $(LIBDIR)/Spore/Middleware/DoNotTrack.lua
	$(INSTALL) -m 644 -D src/Spore/Middleware/Logging.lua           $(LIBDIR)/Spore/Middleware/Logging.lua
	$(INSTALL) -m 644 -D src/Spore/Middleware/Mock.lua              $(LIBDIR)/Spore/Middleware/Mock.lua
	$(INSTALL) -m 644 -D src/Spore/Middleware/Redirection.lua       $(LIBDIR)/Spore/Middleware/Redirection.lua
	$(INSTALL) -m 644 -D src/Spore/Middleware/Runtime.lua           $(LIBDIR)/Spore/Middleware/Runtime.lua
	$(INSTALL) -m 644 -D src/Spore/Middleware/UserAgent.lua         $(LIBDIR)/Spore/Middleware/UserAgent.lua
	$(INSTALL) -m 644 -D src/Spore/Middleware/Auth/AWS.lua          $(LIBDIR)/Spore/Middleware/Auth/AWS.lua
	$(INSTALL) -m 644 -D src/Spore/Middleware/Auth/Basic.lua        $(LIBDIR)/Spore/Middleware/Auth/Basic.lua
	$(INSTALL) -m 644 -D src/Spore/Middleware/Auth/Bearer.lua       $(LIBDIR)/Spore/Middleware/Auth/Bearer.lua
	$(INSTALL) -m 644 -D src/Spore/Middleware/Auth/DataPublica.lua  $(LIBDIR)/Spore/Middleware/Auth/DataPublica.lua
	$(INSTALL) -m 644 -D src/Spore/Middleware/Auth/Digest.lua       $(LIBDIR)/Spore/Middleware/Auth/Digest.lua
	$(INSTALL) -m 644 -D src/Spore/Middleware/Auth/OAuth.lua        $(LIBDIR)/Spore/Middleware/Auth/OAuth.lua
	$(INSTALL) -m 644 -D src/Spore/Middleware/Cookie/Session.lua    $(LIBDIR)/Spore/Middleware/Cookie/Session.lua
	$(INSTALL) -m 644 -D src/Spore/Middleware/Format/JSON.lua       $(LIBDIR)/Spore/Middleware/Format/JSON.lua
	$(INSTALL) -m 644 -D src/Spore/Middleware/Format/XML.lua        $(LIBDIR)/Spore/Middleware/Format/XML.lua
	$(INSTALL) -m 644 -D src/Spore/Middleware/Format/YAML.lua       $(LIBDIR)/Spore/Middleware/Format/YAML.lua
	$(INSTALL) -m 644 -D src/Spore/Middleware/Parameter/Default.lua $(LIBDIR)/Spore/Middleware/Parameter/Default.lua
	$(INSTALL) -m 644 -D src/Spore/Middleware/Parameter/Force.lua   $(LIBDIR)/Spore/Middleware/Parameter/Force.lua
	$(INSTALL) -m 644 -D src/Spore/Middleware/Proxy/Basic.lua       $(LIBDIR)/Spore/Middleware/Proxy/Basic.lua

uninstall:
	rm -f $(LIBDIR)/Spore.lua
	rm -rf $(LIBDIR)/Spore

manifest_pl := \
use strict; \
use warnings; \
my @files = qw{MANIFEST}; \
while (<>) { \
    chomp; \
    next if m{^\.}; \
    next if m{^rockspec/}; \
    push @files, $$_; \
} \
print join qq{\n}, sort @files;

rockspec_pl := \
use strict; \
use warnings; \
use Digest::MD5; \
open my $$FH, q{<}, q{$(TARBALL)} \
    or die qq{Cannot open $(TARBALL) ($$!)}; \
binmode $$FH; \
my %config = ( \
    version => q{$(VERSION)}, \
    rev     => q{$(REV)}, \
    md5     => Digest::MD5->new->addfile($$FH)->hexdigest(), \
); \
close $$FH; \
while (<>) { \
    s{@(\w+)@}{$$config{$$1}}g; \
    print; \
}

version:
	@echo $(VERSION)

CHANGES: dist.info
	perl -i.bak -pe "s{^$(VERSION).*}{q{$(VERSION)  }.localtime()}e" CHANGES

dist.info:
	perl -i.bak -pe "s{^version.*}{version = \"$(VERSION)\"}" dist.info

tag:
	git tag -a -m 'tag release $(VERSION)' $(VERSION)

MANIFEST:
	git ls-files | perl -e '$(manifest_pl)' > MANIFEST

$(TARBALL): MANIFEST
	[ -d lua-Spore-$(VERSION) ] || ln -s . lua-Spore-$(VERSION)
	perl -ne 'print qq{lua-Spore-$(VERSION)/$$_};' MANIFEST | \
	    tar -zc -T - -f $(TARBALL)
	rm lua-Spore-$(VERSION)

dist: $(TARBALL)

rockspec: $(TARBALL)
	perl -e '$(rockspec_pl)' rockspec.in > rockspec/lua-spore-$(VERSION)-$(REV).rockspec

rock:
	$(LUAROCKS) pack rockspec/lua-spore-$(VERSION)-$(REV).rockspec

bed:
	hererocks bed $(BED_OPTS) --no-readline --luarocks latest --verbose
	bed/bin/luarocks install lua-testassertion
	bed/bin/luarocks install dkjson
	bed/bin/luarocks install luasocket
	bed/bin/luarocks install luasec
	bed/bin/luarocks install luaexpat
	bed/bin/luarocks install lualogging
	bed/bin/luarocks install luaossl
	bed/bin/luarocks install lyaml
	bed/bin/luarocks install luacheck
	bed/bin/luarocks install luacov
	bed/bin/luarocks install luacov-console
	bed/bin/luarocks install luacov-reporter-lcov
	hererocks bed --show
	bed/bin/luarocks list

check: test

test:
	LUA_PATH="$(CURDIR)/src/?.lua;;" \
		prove --exec=$(LUA) test/*.lua

test_eg:
	LUA_PATH="$(CURDIR)/src/?.lua;;" \
		prove --exec=$(LUA) eg/*.lua

luacheck:
	$(LUACHECK) --std=max --codes src --ignore 211/_ENV
	$(LUACHECK) --std=min --codes src/discovery2spore
	$(LUACHECK) --std=min --codes src/openapi2spore
	$(LUACHECK) --std=min --codes src/raml2spore
	$(LUACHECK) --std=min --codes src/swagger2spore
	$(LUACHECK) --std=min --codes src/wadl2spore
	$(LUACHECK) --std=min --codes eg
	$(LUACHECK) --std=min --config .test.luacheckrc test

coverage:
	rm -f luacov.*
	-LUA_PATH="$(CURDIR)/src/?.lua;;" \
		prove --exec="$(LUA) -lluacov" test/*.lua
	$(LUACOV_C) $(CURDIR)/src
	$(LUACOV_C) -s $(CURDIR)/src
	$(LUACOV_C) test
	$(LUACOV_C) -s test
	$(LUACOV)


lcov:
	$(LUACOV) -r lcov
	genhtml luacov.report.out -o public/

README.html: README.md
	Markdown.pl README.md > README.html

pages:
	mkdocs build -d public

clean:
	rm -f MANIFEST *.bak luacov.* *.rockspec README.html

realclean: clean
	rm -rf bed

.PHONY: test rockspec CHANGES dist.info

