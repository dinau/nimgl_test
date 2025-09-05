MAKEFLAGS += --no-print-directory

all:
	$(MAKE) -C examples

.PHONEY: clean
clean:
	$(MAKE) -C examples clean
