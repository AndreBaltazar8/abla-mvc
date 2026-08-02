EXAMPLE_DIR := $(abspath .)
LIBRARY_DIR := $(abspath ../..)
ABLAC_DIR := $(abspath ../../..)/ablac
COMPILER := $(ABLAC_DIR)/build/ablac
BUILD_DIR := $(EXAMPLE_DIR)/build
TESTS := home_view auth_session auth_http auth_view static_asset

.PHONY: all client app example run test clean

all: app

example: app

client:
	mkdir -p $(BUILD_DIR) $(EXAMPLE_DIR)/assets
	cd $(ABLAC_DIR) && $(COMPILER) build $(EXAMPLE_DIR)/client.ab -o $(BUILD_DIR)/client-artifact --no-cache
	cp $(ABLAC_DIR)/build/abla-mvc-client/client.wasm $(EXAMPLE_DIR)/assets/abla-mvc-client.wasm

app: client
	mkdir -p $(BUILD_DIR)
	cd $(ABLAC_DIR) && $(COMPILER) build $(EXAMPLE_DIR)/app.ab -o $(BUILD_DIR)/app

run: app
	cd $(EXAMPLE_DIR) && $(BUILD_DIR)/app

test: client
	mkdir -p $(BUILD_DIR)
	@for test_name in $(TESTS); do \
		cd $(ABLAC_DIR) && \
		$(COMPILER) build $(EXAMPLE_DIR)/tests/$$test_name.ab -o $(BUILD_DIR)/$$test_name --no-cache && \
		cd $(EXAMPLE_DIR) && $(BUILD_DIR)/$$test_name || exit $$?; \
	done
	@node --disable-wasm-trap-handler tests/verify_client_wasm.js assets/abla-mvc-client.wasm

clean:
	@if [ -d "$(BUILD_DIR)" ]; then gio trash "$(BUILD_DIR)"; fi
	@if [ -f "$(EXAMPLE_DIR)/assets/abla-mvc-client.wasm" ]; then gio trash "$(EXAMPLE_DIR)/assets/abla-mvc-client.wasm"; fi
