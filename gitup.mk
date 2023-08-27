# DON'T RUN THIS PROGRAM
# DEVELOPMENT PURPOSE ONLY

TARGET = nimgl_test

.PHONY: gitup

GIT_REPO = ../00rel/$(TARGET)
gitup:
	-mkdir -p $(GIT_REPO)/{src,img}
	-mkdir -p $(GIT_REPO)/examples/{imDrawListParty,jpFont}
	cp -f $(TARGET).nimble  $(GIT_REPO)/
	cp -f examples/*.mk     $(GIT_REPO)/examples/
	cp -f src/*.nim         $(GIT_REPO)/src/
	cp -f img/*             $(GIT_REPO)/img/
	cp -f .gitignore        $(GIT_REPO)/
	cp -f LICENSE           $(GIT_REPO)/
	cp -f README.md         $(GIT_REPO)/
	cp -f gitup.mk          $(GIT_REPO)/
	cp -f setenv.bat        $(GIT_REPO)/
	cp -f examples/imDrawListParty/{*.nim,*.ini,Makefile} \
		$(GIT_REPO)/examples/imDrawListParty/
	cp -f examples/jpFont/{*.nim,*.ini,Makefile} \
		$(GIT_REPO)/examples/jpFont/
