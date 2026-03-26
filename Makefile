ROOT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
GEM5_DIR := $(ROOT_DIR)/simulator/gem5
GEM5_BIN := ./build/ARM/gem5.fast
SCRIPT_DIR := scripts
STATS_DIR := m5out

.PHONY: cim_ivf cim_verify nocim_ivf nocim_kdtree

define run_and_summarize
	cd $(GEM5_DIR) && \
	$(GEM5_BIN) $(SCRIPT_DIR)/$(1) && \
	mv -f $(STATS_DIR)/stats.txt $(STATS_DIR)/$(2).txt && \
	grep '^simSeconds' $(STATS_DIR)/$(2).txt | \
	awk '{sum+=$$2; n++; if (n == 1 || $$2 > max) max=$$2} END {if (n) {printf "avg=%.6f sec (n=%d)\n", sum/n, n; printf "max=%.6f sec\n", max} else {print "No simSeconds entries found."; exit 1}}'
endef

cim_ivf:
	$(call run_and_summarize,run_cim_ivf.py,cim_ivf)

cim_verify:
	$(call run_and_summarize,run_cim_verify.py,cim_verify)

nocim_ivf:
	$(call run_and_summarize,run_nocim_ivf.py,nocim_ivf)

nocim_kdtree:
	$(call run_and_summarize,run_nocim_kdtree.py,nocim_kdtree)
