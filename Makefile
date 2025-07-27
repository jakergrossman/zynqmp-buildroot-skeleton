override REPO_ROOT := $(CURDIR)
override SUBDIRS   := $(patsubst %/,%,$(dir $(wildcard ./*/Makefile)))

.PHONY: all clean firmware software help
MAKEFLAGS += --no-print-directory

XILINX_ROOT    ?= /tools/xilinx
XILINX_VERSION ?= 2025.1
BUILD_DIR      ?= $(abspath BUILD)

export REPO_ROOT
export VIVADO_VERSION
export BUILD_DIR

all: firmware software

### build ZynqMP firmware (Programmable Logic)
firmware: software-sdk
	$(MAKE) -C $@

### build software makefile target '%'
software-%: ## build ZynqMP software (Buildroot Linux Kernel + Applications)
	$(MAKE) -C software $*

## build firmware makefile target '%'
firmware-%:
	$(MAKE) -C firmware $*

## delete top level output directory
all-clean:
	-rm -rf $(BUILD_DIR)

## show this help text
help:
	@echo ZynqMP Firmware + Software Makefile Help
	@echo
	@echo "TARGETS:"
	@grep -zPo '\n###[^\n]*[^:]+' $(MAKEFILE_LIST) | paste -d' ' - -
#		| awk 'BEGIN {FS = " ### "}; {printf "        %-20s %s\n", $$2, $$1}'
	@false
	@echo

	@echo "VARIABLES:"
	@echo "    Top Level:"
	@grep -E '^[a-zA-Z_-]+ .*?### .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = " .*?### "}; {printf "        %-20s %s\n", $$1, $$2}'
	@echo

	@echo "    Firmware Variables:"
	@$(MAKE) -C firmware variables
	@echo

	@echo "    Software Variables:"
	@$(MAKE) -C software variables
	@echo
