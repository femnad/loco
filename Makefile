build:
	crystal build ysnp.cr

install:
	$(shell ln -s $(shell realpath ysnp) $(HOME)/bin)
