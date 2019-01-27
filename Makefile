build:
	crystal build ysnp.cr

install:
	$(shell ln -fs $(shell realpath ysnp) $(HOME)/bin)
