TARGET = nimgl_test

ifeq ($(OS),Windows_NT)
	EXE = .exe
endif
NULL = .tmp

.PHONY: clean run dll ver gitup info

IMGUI_DIALOG = false

ifeq ($(IMGUI_DIALOG),false)
all: build

build:
	@nimble build --verbose

clean:
	@nimble clean --verbose

run:
	@nimble run --verbose

info: dll ver

dll:
	@echo
	@echo [dlls depend on]
	@#-ldd $(TARGET)$(EXE) |  rg -ive "windows/system" | rg -ive "windows/winsxs"
	@#-strings $(TARGET)$(EXE) |  rg -i \.dll
	@-   ldd -V > $(NULL)     \
		&& rg  -V > $(NULL)     \
		&& strings -v > $(NULL) \
	  && ldd $(TARGET)$(EXE)   | rg -ive "windows/system" | rg -ive "winsxs"; \
		   echo ---; \
		   strings $(TARGET)$(EXE)  | rg -ie "\.dll" | rg -ive " load" | sort | uniq -i
	@-rm .tmp
	@echo
	@echo [cimgui.dll version]
	@-strings cimgui.dll | rg -ie "^\d\.\d\d\.\d"
ver:
	@# version check
	@echo [$(TARGET).nimlbe]
	-@rg -ie "version\s+=.+" $(TARGET).nimble
	@echo [version.nims]
	-@rg -ie "\d\.\d\.\d" version.nims

GIT_REPO = ../../../00rel/$(TARGET)
gitup:
	-rm -fr $(GIT_REPO)/* $(GIT_REPO)/src/* $(GIT_REPO)/img/*
	-mkdir -p $(GIT_REPO)/src $(GIT_REPO)/img
	cp -f $(TARGET).nimble $(GIT_REPO)
	cp -f src/*.nim $(GIT_REPO)/src/
	cp -f img/* $(GIT_REPO)/img/
	cp -f imgui.ini $(GIT_REPO)
	cp -f version.nims $(GIT_REPO)
	cp -f config.nims $(GIT_REPO)
	cp -f .gitignore  $(GIT_REPO)
	cp -f LICENSE $(GIT_REPO)
	cp -f README.md $(GIT_REPO)
	cp -f Makefile $(GIT_REPO)
	cp -f setenv.bat $(GIT_REPO)
	ls -al $(GIT_REPO)
	ls -al $(GIT_REPO)/src/


else # for ImGuiFileDialog (https://github.com/aiekick/ImGuiFileDialog)
	#
  VPATH = src
  STATIC_LINK = true
  NIMCACHE = .nimcache
  OPT += -d:release
  OPT += -d:strip
  OPT += --opt:size
  #OPT += --app:gui
  #OPT += -d:cimguiStaticCgcc
  #
	OPT += --passC:-std=c++17
	OPT += --passC:"-IC:\Users\$(USERNAME)\.nimble\pkgs\nimgl-1.3.2\nimgl\private\cimgui\imgui"
  OPT += --nimcache:$(NIMCACHE)
  #OPT += --verbosity:3
	ifeq ($(STATIC_LINK),true)
			OPT += --passL:-static
	lse
			OPT += --passC:-shared
			OPT += -d:windows -d:glfwDLL
			#OPT += --passC:-DIMGUI_API="\"__declspec( dllexport )\""
			#OPT += --passC:-DIMGUI_API="\"__declspec( dllimport )\""
	endif
#
all: src/$(TARGET).nim
	nim cpp $(OPT) -o:$(TARGET)$(EXE) $<
	@strings $(TARGET)$(EXE) |  rg -i \.dll
	@./$(TARGET)$(EXE)
clean:
	@-rm $(TARGET)$(EXE)
	@-rm -fr $(NIMCACHE)
endif
