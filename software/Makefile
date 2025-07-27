BR_DL_DIR       := $(REPO_ROOT)/dep/dl
BR_SUBMODULE    := $(REPO_ROOT)/dep/buildroot
BR_EXTERNAL     ?= 
BUILD_DIR       ?= $(CURDIR)
BR_OUTPUT       := $(BUILD_DIR)/linux
BR_ARGS         := BR2_EXTERNAL=$(BR2_EXTERNAL) O=$(BR_OUTPUT) BR2_DL_DIR=$(BR_DL_DIR)
BR_MAKE         := $(MAKE) -C $(BR_SUBMODULE) $(BR_ARGS)
DEFCONFIG       := zynqmp_zcu102_defconfig

all: sdk

$(BR_SUBMODULE):
	git submodule init $@

sdk: $(BR_OUTPUT)/.config buildroot-sdk
$(BR_OUTPUT)/.config: buildroot-$(DEFCONFIG)

variables:
	@grep -E '^[a-zA-Z_-]+ .*?### .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = " .*?### "}; {printf "        %-20s %s\n", $$1, $$2}'

$(BR_DIR):
	mkdir -p $@

clean: buildroot-clean

buildroot-%: ## run buildroot make target '%'
	$(BR_MAKE) $*
