ROOT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
GEM5_DIR := $(ROOT_DIR)/simulator/gem5
GEM5_BIN := ./build/ARM/gem5.fast
SCRIPT_DIR := scripts
STATS_DIR := m5out
STEP_LIMIT_GOALS := $(filter-out all cim_ivf cim_verify nocim_ivf nocim_kdtree,$(MAKECMDGOALS))
STEP_LIMIT := $(word 1,$(STEP_LIMIT_GOALS))
STEP_LIMIT_COUNT := $(words $(STEP_LIMIT_GOALS))

.PHONY: all cim_ivf cim_verify nocim_ivf nocim_kdtree

define validate_step_limit
	if [ "$(STEP_LIMIT_COUNT)" -gt 1 ]; then \
		echo "Error: expected at most one step limit, got: $(STEP_LIMIT_GOALS)" >&2; \
		exit 1; \
	fi; \
	if [ -n "$(STEP_LIMIT)" ]; then \
		case "$(STEP_LIMIT)" in \
			*[!0-9]*) \
				echo "Error: step limit must be a non-negative integer, got '$(STEP_LIMIT)'." >&2; \
				exit 1 ;; \
		esac; \
	fi
endef

define simseconds_summary
	awk ' \
		/^simSeconds/ { \
			sum += $$2; \
			n++; \
			if (n == 1 || $$2 > max) max = $$2; \
		} \
		END { \
			if (n) { \
				printf "avg=%.6f sec (n=%d)\n", sum / n, n; \
				printf "max=%.6f sec\n", max; \
			} else { \
				print "No simSeconds entries found."; \
				exit 1; \
			} \
		}' $(1)
endef

define named_simseconds_summary
	awk ' \
		/^simSeconds/ { \
			sum += $$2; \
			n++; \
			if (n == 1 || $$2 > max) max = $$2; \
		} \
		END { \
			if (n) { \
				printf "%-13s avg=%.6f sec max=%.6f sec (n=%d)\n", "$(1)", sum / n, max, n; \
			} else { \
				printf "%-13s No simSeconds entries found.\n", "$(1)"; \
				exit 1; \
			} \
		}' $(2)
endef

define run_and_summarize
	cd $(GEM5_DIR) && \
	$(GEM5_BIN) $(SCRIPT_DIR)/$(1) && \
	mv -f $(STATS_DIR)/stats.txt $(STATS_DIR)/$(2).txt && \
	$(call simseconds_summary,$(STATS_DIR)/$(2).txt)
endef

define run_and_summarize_with_limit
	$(call validate_step_limit) && \
	cd $(GEM5_DIR) && \
	max_steps_args=""; \
	if [ -n "$(STEP_LIMIT)" ]; then \
		max_steps_args="--max-steps $(STEP_LIMIT)"; \
	fi; \
	$(GEM5_BIN) $(SCRIPT_DIR)/$(1) $$max_steps_args && \
	mv -f $(STATS_DIR)/stats.txt $(STATS_DIR)/$(2).txt && \
	$(call simseconds_summary,$(STATS_DIR)/$(2).txt)
endef

all:
	$(call run_and_summarize_with_limit,run_cim_ivf.py,cim_ivf)
	$(call run_and_summarize_with_limit,run_nocim_ivf.py,nocim_ivf)
	$(call run_and_summarize_with_limit,run_nocim_kdtree.py,nocim_kdtree)
	@printf '\nSummary:\n'
	@$(call named_simseconds_summary,cim_ivf,$(GEM5_DIR)/$(STATS_DIR)/cim_ivf.txt)
	@$(call named_simseconds_summary,nocim_ivf,$(GEM5_DIR)/$(STATS_DIR)/nocim_ivf.txt)
	@$(call named_simseconds_summary,nocim_kdtree,$(GEM5_DIR)/$(STATS_DIR)/nocim_kdtree.txt)

cim_ivf:
	$(call run_and_summarize_with_limit,run_cim_ivf.py,cim_ivf)

cim_verify:
	$(call run_and_summarize,run_cim_verify.py,cim_verify)

nocim_ivf:
	$(call run_and_summarize_with_limit,run_nocim_ivf.py,nocim_ivf)

nocim_kdtree:
	$(call run_and_summarize_with_limit,run_nocim_kdtree.py,nocim_kdtree)

%:
	@:
