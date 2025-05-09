all: absplat.js
%.js: %.nim
	nim js -d:release $<
