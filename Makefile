.PHONY: build test dump

test: build
	luajit test.lua

build:
	moonc .

dump:
	cat test.gif | giftool -f '%n: %s (%p)\n'

