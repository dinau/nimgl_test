TARGET = $(notdir $(CURDIR))
ifeq ($(OS),Windows_NT)
	EXE = .exe
endif

OPT += -d:release
OPT += -d:strip

.PHONY: run clean

all:
	nim cpp  $(OPT) $(TARGET)
	$(ADDED_COMMAND)

run: all
	./$(TARGET)

clean:
	@-rm -fr .nimcache
	@-rm $(TARGET)$(EXE)
