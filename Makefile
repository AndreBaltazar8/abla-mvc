PROJECT_DIR := $(abspath .)
ABLAC_DIR := $(abspath ../ablac)
COMPILER := $(ABLAC_DIR)/build/ablac
BUILD_DIR := $(PROJECT_DIR)/build
TESTS := mvcview_basic mvcview_attributes mvcview_component_interpolation mvcview_action mvcview_action_arguments mvcview_client browser_runtime html_escape http_helpers action_registry

.PHONY: all compiler example app client run test test-library clean

all: example

compiler:
	$(MAKE) -C $(ABLAC_DIR) compiler

example app client run:
	$(MAKE) -C examples/showcase $@

test-library:
	mkdir -p $(BUILD_DIR)
	@for test_name in $(TESTS); do \
		cd $(ABLAC_DIR) && \
		$(COMPILER) build $(PROJECT_DIR)/tests/$$test_name.ab -o $(BUILD_DIR)/$$test_name --no-cache && \
		cd $(PROJECT_DIR) && $(BUILD_DIR)/$$test_name || exit $$?; \
	done
	@cd $(ABLAC_DIR) && \
		if $(COMPILER) build $(PROJECT_DIR)/tests/invalid_mvcview_action_signature.ab -o $(BUILD_DIR)/invalid_mvcview_action_signature --no-cache; then \
			echo "expected invalid MVC action signature to fail"; \
			exit 1; \
		fi
	@cd $(ABLAC_DIR) && \
		if $(COMPILER) build $(PROJECT_DIR)/tests/invalid_mvcview_text_node.ab -o $(BUILD_DIR)/invalid_mvcview_text_node --no-cache; then \
			echo "expected string node interpolation to fail"; \
			exit 1; \
		fi

test: test-library
	$(MAKE) -C examples/showcase test

clean:
	$(MAKE) -C examples/showcase clean
	@if [ -d "$(BUILD_DIR)" ]; then gio trash "$(BUILD_DIR)"; fi
