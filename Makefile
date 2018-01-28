# Set any default call arguments
CALLARGS :=

ifneq ($(DRYRUN),)
	CALLARGS := --check
endif

all: help

.PHONY: init
init: ## Initialize remote user
	@echo "+ $@"
	ANSIBLE_FORCE_COLOR=true ./init_remote_user.yml --limit=minecraft --user=root --ask-pass --verbose $(CALLARGS)

.PHONY: setup-server
setup-server: ## Common server setup
	@echo "+ $@"
	ANSIBLE_FORCE_COLOR=true ./common_server_setup.yml --limit=minecraft --user=minecraft --private-key=$(HOME)/.ssh/minecraft_id_rsa --become --verbose $(CALLARGS)

.PHONY: install-minecraft
install-minecraft: ## Install Minecraft server
	@echo "+ $@"
	ANSIBLE_FORCE_COLOR=true ./minecraft_server_setup.yml --limit=minecraft --user=minecraft --private-key=$(HOME)/.ssh/minecraft_id_rsa --become --verbose $(CALLARGS)
	
.PHONY: install-mcmyadmin
install-mcmyadmin: ## Install Minecraft Control Panel (McMyAdmin)
	@echo "+ $@"
	ANSIBLE_FORCE_COLOR=true ./mcmyadmin_setup.yml --limit=minecraft --user=minecraft --private-key=$(HOME)/.ssh/minecraft_id_rsa --become --verbose $(CALLARGS)

.PHONY: test
test: ## Runs a complete test suite with molecule
	@echo "+ $@"
	molecule test

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
