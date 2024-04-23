TARGET = $(notdir $(CURDIR))

OPT += -d:release
OPT += -d:strip

.PHONY: run clean

all:
	nim cpp  $(OPT) $(TARGET)

run: all
	./$(TARGET)

clean:
	@-rm -fr .nimcache
	@-rm $(TARGET)
