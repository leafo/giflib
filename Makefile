.PHONY: build test dump

test: build
	luajit test.lua

build:
	moonc giflib.moon giflib

local: build
	luarocks make --local giflib-dev-1.rockspec

dump:
	cat test.gif | giftool -f '%n: %s (%p)\n'

lint: build
	moonc -l giflib
