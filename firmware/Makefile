PROJECT_NAME := zynq_mpsoc           	### vivado project name     (default: zynq_mpsoc)
PART         := xczu9eg-ffvb1156-2-e    ### FPGA part number        (default: xczu9eg-ffvb1156-2-e)
BOARD        := zcu102 	                ### optional board number   (default: zcu102)

help: ## show this help text
	@echo ZynqMP Firmware Makefile Help:
	@echo "Targets:"
	@grep -E '^[%a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "        %-20s %s\n", $$1, $$2}'
	@echo

	@echo "Variables:"
	@$(MAKE) variables

variables:
	@grep -E '^[a-zA-Z_-]+ .*?### .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = " .*?### "}; {printf "        %-20s %s\n", $$1, $$2}'
