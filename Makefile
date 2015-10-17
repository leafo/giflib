.PHONY: build test dump


test: build
	luajit giflib.lua

build:
	moonc .

dump:
	cat test.gif | giftool -f '%n: %s (%p)\n'

	
