.SILENT:
.PHONY: list all %

MODPACKS = $(shell find modpacks/* -maxdepth 0 -type d | sed 's!modpacks/\(.*\)!\1!' | sort | uniq)

# Constructs the path of the modpack config file
#  $(1) - modpack name
define getConfigPath =
	"modpacks/$(1)/versions.json"
endef

# Gets a list of all modpack versions available
#  $(1) - modpack name
define getModpackVersions =
	$(shell jq 'keys[]' $(call getConfigPath,$(1)) | tr -d '"' | sort)
endef

# Gets the latest version of the modpack
#  $(1) - modpack name
define getLatestModpackVersion =
	$(shell jq 'keys[]' $(call getConfigPath,$(1)) | tr -d '"' | sort | tail -n 1)
endef

# Prints modpack and its available versions
#  $(1) - modpack name
define printModpackInfo
	$(info $(1))
	$(foreach version,$(call getModpackVersions,$(1)),$(info  - $(version)))
	$(info )
endef

# Builds a specific version of a modpack
#  $(1) - modpack name
#  $(2) - version
define buildModpackVersion
	$(eval downloadUrl := $(shell jq ".[\"$(2)\"]" $(call getConfigPath,$(1)) | tr -d '"'))
	docker build . \
		--tag ${USER}/$(1):$(2) \
		--build-arg SERVER_DOWNLOAD_URL=$(downloadUrl) \
		--build-arg MODPACK=$(1)
endef

# Builds a specified version of a modpack, while falling back to latest if no versions are specified
#  $(1) - modpack name
#  $(2) - version (optional, defaults to latest)
define buildModpack
	$(eval modpack := $(1))
	$(eval version := $(or $(2),$(strip $(call getLatestModpackVersion,$(modpack)))))
	$(call buildModpackVersion,$(modpack),$(version))
endef

list:
	$(foreach modpack, $(MODPACKS), $(call printModpackInfo,$(modpack)))

all: $(MODPACKS)

%:
	$(eval modpack := $(word 1,$(subst :, ,$@)))
	$(eval version := $(word 2,$(subst :, ,$@)))
	$(call buildModpack,$(modpack),$(version))
