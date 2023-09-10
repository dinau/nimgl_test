TARGET = nimgl_test

.PHONY: clean ver

all: build

build:
	@nimble build --verbose

clean:
	@nimble clean --verbose

run:
	@nimble run --verbose

ver:
	@# version check
	@echo [$(TARGET).nimlbe]
	-@rg -ie "version\s+=.+" $(TARGET).nimble
	@echo [version.nims]
	-@rg -ie "\d\.\d\.\d" version.nims

gitup:
	$(MAKE) -f gitup.mk

