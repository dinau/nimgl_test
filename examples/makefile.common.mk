TARGET = $(notdir $(CURDIR))

OPT +=  -d:strip
OPT +=  -d:release
OPT +=  --nimcache:.nimcache

all:
	nim cpp  -r $(OPT) $(TARGET)

clean:
	@-rm -fr .nimcache
	@-rm $(TARGET)
