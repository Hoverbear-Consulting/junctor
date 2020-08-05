
## Configurables.
export BIN ?= junctor ## Main binary name.
export ARCH ?= thumbv7em-none-eabi ## Rust compile target.
export CHIP ?= nRF52840_xxAA ## Flash/embed target.
export RELEASE ?= false ## Release mode.
export CHECK ?= false ## Prefer checks to mutations.
export PREREQS ?= true ## Provision preresuites as needed.
export OS ?= ubuntu-20.04 ## The hosting OS. (Only Ubuntu 20.04 is supported.)

# Pretty stuff!
FORMATTING_BEGIN_TASK = \033[0;33m
FORMATTING_BEGIN_KNOBS = \033[0;93m
FORMATTING_BEGIN_CONFIGURED = \033[1;36m
FORMATTING_BEGIN_DEFAULT = \033[0;36m
FORMATTING_BEGIN_HEADING = \033[1;32m
FORMATTING_BEGIN_HINT = \033[0;90m
FORMATTING_BEGIN_COMMAND = \033[1;37m
FORMATTING_END = \033[0m
define AWK
	@gawk \
		-v FORMATTING_BEGIN_TASK="${FORMATTING_BEGIN_TASK}" \
		-v FORMATTING_BEGIN_KNOBS="${FORMATTING_BEGIN_KNOBS}" \
		-v FORMATTING_BEGIN_CONFIGURED="${FORMATTING_BEGIN_CONFIGURED}" \
		-v FORMATTING_BEGIN_DEFAULT="${FORMATTING_BEGIN_DEFAULT}" \
		-v FORMATTING_BEGIN_HEADING="${FORMATTING_BEGIN_HEADING}" \
		-v FORMATTING_BEGIN_HINT="${FORMATTING_BEGIN_HINT}" \
		-v FORMATTING_BEGIN_COMMAND="${FORMATTING_BEGIN_COMMAND}" \
		-v FORMATTING_END="${FORMATTING_END}"
endef

## Non-configurables.
# Touch these and you will start mysteriously breaking things and I will not help you.
override ARTIFACT_BIN = target/${ARCH}/${BUILD_MODE}/${BIN}
override BUILD_MODE = $(if $(findstring true,$(RELEASE)),release,debug)
override MAYBE_RELEASE_FLAG = $(if $(findstring true,$(RELEASE)),--release,)
override MAYBE_CHECK_FLAG = $(if $(findstring true,$(CHECK)),--check,)
override ROOT_DIR = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

help: ## Print this message.
	@printf -- "\n"
	@printf -- "                                      ${FORMATTING_BEGIN_TASK}Junctor${FORMATTING_END}\n"
	@printf -- "                         ${FORMATTING_BEGIN_HEADING}A Hoverbear Consulting nRF52840 Experiment${FORMATTING_END}\n"
	@printf -- "\n"
	@printf -- "Prior to usage, please run \`${FORMATTING_BEGIN_COMMAND}make${FORMATTING_END} ${FORMATTING_BEGIN_TASK}prerequisites${FORMATTING_END}\`. Thanks!\n"
	@printf -- "\n"
	@printf -- "${FORMATTING_BEGIN_HEADING}Usage${FORMATTING_END}\n"
	@printf -- "  ${FORMATTING_BEGIN_COMMAND}make${FORMATTING_END} ${FORMATTING_BEGIN_TASK}<task>${FORMATTING_END} ${FORMATTING_BEGIN_KNOBS}[RELEASE=true CHECK=true ...]${FORMATTING_END} \n"
	@printf -- "\n"
	@printf -- "${FORMATTING_BEGIN_HEADING}Knobs${FORMATTING_END}                           ${FORMATTING_BEGIN_HINT}Configured  Default              Description${FORMATTING_END}\n"
	${AWK} -f hack/variables.awk $(MAKEFILE_LIST)
	@printf -- "\n"
	@printf -- "${FORMATTING_BEGIN_HEADING}Tasks${FORMATTING_END}                                       ${FORMATTING_BEGIN_HINT}Description${FORMATTING_END}\n"
	${AWK} -f hack/targets.awk $(MAKEFILE_LIST)

##@ Code
.PHONY := build format

build: rust-target-${ARCH} ## Build the binary.
	cargo build ${MAYBE_RELEASE_FLAG}

size: tool-cargo-binutils ## Show size of code.
	cargo size ${MAYBE_RELEASE_FLAG} --bin ${BIN}

bloat: tool-cargo-bloat ## Show bloat in code
	cargo bloat ${MAYBE_RELEASE_FLAG} --bin ${BIN}

fetch: ## Fetch a local copy of the dependencies.
	cargo fetch

clean: ## Clean up the working environment.
	cargo clean

##@ Hardware
.PHONY := run flash embed recover

run: rust-target-${ARCH} ## Run the binary.
	cargo run ${MAYBE_RELEASE_FLAG} --bin ${BIN}

flash: rust-target-${ARCH} tool-cargo-flash ## Flash the device.
	cargo flash ${MAYBE_RELEASE_FLAG} --chip ${CHIP}

embed: rust-target-${ARCH} tool-cargo-embed ## Embed into the device.
	cargo embed ${MAYBE_RELEASE_FLAG}

recover: tool-nrf-recover ## Recover the nRF device.
	nrf-recover -y

##@ Validation
.PHONY := audit format lint conventional version release-needed

audit: tool-cargo-audit rust-target-${ARCH} ## Audit the  depenencies.
	cargo audit

format: rust-target-${ARCH} rust-component-rustfmt ## Run formatting pass.
	cargo fmt -- ${MAYBE_CHECK_FLAG}

lint: rust-target-${ARCH} rust-component-clippy ## Run linting pass.
	cargo clippy

conventional: tool-convco ## Ensures the commits are all conventional.
	convco check

version: tool-convco apt-jq apt-gawk ## Sync version to Cargo.
	$(eval override CARGO_VERSION = $(shell cargo pkgid | gawk --file hack/version.awk))
	$(eval override CONVCO_VERSION = $(shell convco version))
	$(if $(findstring true,$(CHECK)),@test "${CARGO_VERSION}" = "${CONVCO_VERSION}",)
	$(if $(findstring true,$(CHECK)),,@sed -i 's/version = "${CARGO_VERSION}"/version = "${CONVCO_VERSION}"/g' Cargo.toml)
	$(if $(findstring true,$(CHECK)),,@git add Cargo.toml)

release-needed: tool-convco ## Determine if a release is needed.
	$(eval override CARGO_VERSION = $(shell cargo pkgid | gawk --file hack/version.awk))
	$(eval override CONVCO_VERSION = $(shell convco version))
	$(eval override NEW_CONVCO_VERSION = $(shell convco version --bump))
	# Make sure this is required.
	test "${CONVCO_VERSION}" != "${NEW_CONVCO_VERSION}" || test -z "${TAG_OF_THIS_VERSION_EXISTS}"

##@ Committing
.PHONY := commit-build commit-chore commit-ci commit-docs commit-feat commit-fix commit-perf commit-refactor commit-style commit-test push

commit-build: changelog version ## Make a build change.
	convco commit --build -- --patch

commit-chore: changelog version ## Make a chore change.
	convco commit --chore -- --patch

commit-ci: changelog version ## Make a ci change.
	convco commit --ci -- --patch

commit-docs: changelog version ## Make a docs change.
	convco commit --docs -- --patch

commit-feat: changelog version ## Make a feat change.
	convco commit --feat -- --patch

commit-fix: changelog version ## Make a fix change.
	convco commit --fix -- --patch

commit-perf: changelog version ## Make a perf change.
	convco commit --perf -- --patch

commit-refactor: changelog version ## Make a refactor change.
	convco commit --refactor -- --patch

commit-style: changelog version ## Make a style change.
	convco commit --style -- --patch

commit-test: changelog version ## Make a test change.
	convco commit --test -- --patch

push: FORCE ?= true
push: ## Push the latest code & tags.
	git push --follow-tag $(if $(findstring true,$(FORCE)),--force,)

##@ Releasing
.PHONY := changelog release update reset

changelog: tool-convco ## Update the changelog.
	$(if $(findstring true,$(CHECK)),@convco check,)
	convco changelog > CHANGELOG.md
	$(if $(findstring true,$(CHECK)),,@test -z "$(git ls-files CHANGELOG.md --modified)")
	$(if $(findstring true,$(CHECK)),,@git add CHANGELOG.md)
	$(if $(findstring true,$(CHECK)),@git restore CHANGELOG.md,)

release: release-needed ## Cut a release, if required.
	$(eval override CARGO_VERSION = $(shell cargo pkgid | gawk --file hack/version.awk))
	$(eval override CONVCO_VERSION = $(shell convco version))
	$(eval override NEW_CONVCO_VERSION = $(shell convco version --bump))
	sed -i 's/version = "${CARGO_VERSION}"/version = "${NEW_CONVCO_VERSION}"/g' Cargo.toml
	git add CHANGELOG.md Cargo.toml
	git commit --no-verify --message "chore(release): Prepare v${NEW_CONVCO_VERSION}"
	git tag v${NEW_CONVCO_VERSION}
	make changelog version

	@echo "chore(release): Release v${NEW_CONVCO_VERSION}" > MESSAGE
	@echo "" >> MESSAGE
	@cat CHANGELOG.md >> MESSAGE
	git commit --amend --no-verify --file MESSAGE
	git tag -d v${NEW_CONVCO_VERSION}
	git tag --annotate --file MESSAGE v${NEW_CONVCO_VERSION}
	rm MESSAGE

update: ## Update all dependencies.
	cargo update

reset: # (Hidden from users) This resets the repo completely back to a squashed commit with a tagged version.
	@echo -n "This is going to do some bad stuff. Why would you do this? Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	# Reset
	git tag | xargs git tag -d
	echo "" > CHANGELOG.md
	git reset $(shell git commit-tree HEAD^{tree} -m 'feat(init): Initialize repository.')
	make release

##@ Provisioning
.PHONY := ci prerequisites

ci: prerequisites format lint build changelog ## Run the CI pass locally.

prerequisites: inject-hooks ## Bootstrap the machine.
	$(if $(findstring true,$(PREREQS)),@bash ./distribution/bootstraps/ubuntu-20.04.sh,)
	# We just always need this.
	rustup +stable component add llvm-tools-preview

##@ Hooks
.PHONY := inject-hooks hook-pre-commit

inject-hooks: ## Inject the git hooks used.
	@ln \
		--symbolic \
		--force \
		../../hack/git/hooks/pre-commit .git/hooks/pre-commit

hook-pre-commit: override CHECK = true
hook-pre-commit: ci

.PHONY := apt-% tool-% rust-component-% rust-target-%

apt-%: override PACKAGE = $(@:apt-%=%)
apt-%:
	$(if $(findstring true,$(PREREQS)),sudo apt install ${PACKAGE} --yes -qqq,)

tool-%: override TOOL = $(@:tool-%=%)
tool-%:
	$(if $(findstring true,$(PREREQS)),cargo install ${TOOL} --quiet,)

rust-component-%: override COMPONENT = $(@:rust-component-%=%)
rust-component-%:
	$(if $(findstring true,$(PREREQS)),rustup component add ${COMPONENT},)

rust-target-%: override ARCH = $(@:rust-target-%=%)
rust-target-%:
	$(if $(findstring true,$(PREREQS)),rustup target add ${ARCH},)
