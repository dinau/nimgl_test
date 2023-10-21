TARGET = $(notdir $(CURDIR))

OPT += -d:strip

all:
	nim cpp  $(OPT) $(TARGET)

clean:
	@-rm -fr .nimcache
	@-rm $(TARGET)
