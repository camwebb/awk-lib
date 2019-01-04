PREFIX = /usr/local

install:
	mkdir -p $(PREFIX)/share/awk
	cp -fv share/*awk $(PREFIX)/share/awk/.
