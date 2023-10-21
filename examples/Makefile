# For build test


.PHONY: clean

DIRS += imDrawListParty
DIRS += implot_jp
DIRS +=	jpFont

all:
	$(foreach model,$(DIRS), $(call def_make,$(model) ) )

clean:
	$(foreach model,$(DIRS), $(call def_clean,$(model) ))

# definition loop funciton
define def_make
	-@$(MAKE) -C $(1) $(OPTIMIZE)

endef

define def_clean
	-@$(MAKE) -C $(1) clean

endef

MAKEFLAGS += --no-print-directory
