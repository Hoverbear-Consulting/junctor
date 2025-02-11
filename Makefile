
## Configurables.
export RELEASE ?= false ## Release mode.
export OPEN ?= false ## Open generated documentation.
export CHECK ?= false ## Prefer checks to mutations.
export PREREQS ?= false ## Provision preresuites as needed.
export BIN ?= junctor ## Main binary name.
export ARCH ?= thumbv7em-none-eabihf ## Rust compile target.
export CHANNEL ?= nightly ## Rust channel to use.
export CHIP ?= nRF52840_xxAA ## Flash/embed target.


# "One weird trick!" https://www.gnu.org/software/make/manual/make.html#Syntax-of-Functions
EMPTY:=
SPACE:= ${EMPTY} ${EMPTY}

# Pretty stuff!
ifeq ($(OS),Windows_NT) # is Windows_NT on XP, 2000, 7, Vista, 10...
    FORMATTING_BEGIN_TASK = ${EMPTY}
    FORMATTING_BEGIN_KNOBS = ${EMPTY}
    FORMATTING_BEGIN_CONFIGURED = ${EMPTY}
    FORMATTING_BEGIN_DEFAULT = ${EMPTY}
    FORMATTING_BEGIN_HEADING = ${EMPTY}
    FORMATTING_BEGIN_HINT = ${EMPTY}
    FORMATTING_BEGIN_COMMAND = ${EMPTY}
    FORMATTING_END = ${EMPTY}
else
    FORMATTING_BEGIN_TASK = \033[0;33m
    FORMATTING_BEGIN_KNOBS = \033[0;93m
    FORMATTING_BEGIN_CONFIGURED = \033[1;36m
    FORMATTING_BEGIN_DEFAULT = \033[0;36m
    FORMATTING_BEGIN_HEADING = \033[1;32m
    FORMATTING_BEGIN_HINT = \033[0;90m
    FORMATTING_BEGIN_COMMAND = \033[1;37m
    FORMATTING_END = \033[0m
endif


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
override CARGO = cargo +$(strip ${CHANNEL})
override CANONICAL_TOOLCHAIN = $(strip ${CHANNEL})-$(strip ${ARCH})
export PATH +=$(if $(findstring true,$(PREREQS)),:~/.cargo/bin,)
export PATH +=$(if $(findstring Windows_NT,$(OS)),:~/scoop/shims,)

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
	@printf -- "${FORMATTING_BEGIN_HEADING}Knobs${FORMATTING_END}                       ${FORMATTING_BEGIN_HINT}Configured Default                   Description${FORMATTING_END}\n"
	${AWK} -f hack/variables.awk $(MAKEFILE_LIST)
	@printf -- "\n"
	@printf -- "${FORMATTING_BEGIN_HEADING}Tasks${FORMATTING_END}                                  ${FORMATTING_BEGIN_HINT}Description${FORMATTING_END}\n"
	${AWK} -f hack/targets.awk $(MAKEFILE_LIST)

##@ Code
.PHONY := build format

build: rust-target-${ARCH} rust-component-rust-std  ## Build the binary.
	${CARGO} build ${MAYBE_RELEASE_FLAG}

document: rust-target-${ARCH} rust-component-rust-std  ## Document the code.
	${CARGO} doc $(if $(findstring true,$(OPEN)),--open,)

size: tool-cargo-binutils ## Show size of code.
	${CARGO} size ${MAYBE_RELEASE_FLAG} --bin ${BIN}

bloat: tool-cargo-bloat ## Show bloat in code
	${CARGO} bloat ${MAYBE_RELEASE_FLAG} --bin ${BIN}

fetch: ## Fetch a local copy of the dependencies.
	${CARGO} fetch

clean: ## Clean up the working environment.
	${CARGO} clean

##@ Hardware
.PHONY := run flash embed recover

run: rust-target-${ARCH} rust-component-rust-std tool-probe-run ## Run the binary.
	${CARGO} run ${MAYBE_RELEASE_FLAG} --bin ${BIN}

flash: rust-target-${ARCH} rust-component-rust-std pip3-nrfutil tool-cargo-flash ## Flash the device.
	${CARGO} flash ${MAYBE_RELEASE_FLAG} --chip ${CHIP}

recover: tool-nrf-recover pip3-nrfutil ## Recover the nRF device.
	nrf-recover -y

##@ Validation
.PHONY := audit format lint conventional version release-needed

audit: tool-cargo-audit rust-target-${ARCH} ## Audit the dependencies.
	${CARGO} audit

format: rust-target-${ARCH} rust-component-rustfmt ## Run formatting pass.
	${CARGO} fmt -- ${MAYBE_CHECK_FLAG}

lint: rust-target-${ARCH} rust-component-clippy ## Run linting pass.
	${CARGO} clippy

conventional: tool-convco ## Ensures the commits are all conventional.
	convco check

version: tool-convco ## Sync version to Cargo.
	$(eval override CARGO_VERSION = $(shell ${CARGO} pkgid | gawk --file hack/version.awk))
	$(eval override CONVCO_VERSION = $(shell convco version))
	$(if $(findstring true,$(CHECK)),@test "${CARGO_VERSION}" = "${CONVCO_VERSION}",)
	$(if $(findstring true,$(CHECK)),,@sed -i 's/version = "${CARGO_VERSION}"/version = "${CONVCO_VERSION}"/g' Cargo.toml)
	$(if $(findstring true,$(CHECK)),,@git add Cargo.toml)

release-needed: tool-convco ## Determine if a release is needed.
	$(eval override CARGO_VERSION = $(shell ${CARGO} pkgid | gawk --file hack/version.awk))
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
.PHONY := readme changelog release update reset

readme: tool-cargo-readme ## Update the changelog.
	${CARGO} readme > README.md
	$(if $(findstring true,$(CHECK)),,@test -z "$(git ls-files README.md --modified)")
	$(if $(findstring true,$(CHECK)),,@git add README.md)
	$(if $(findstring true,$(CHECK)),@git restore README.md,)

changelog: tool-convco ## Update the changelog.
	$(if $(findstring true,$(CHECK)),@convco check,)
	convco changelog > CHANGELOG.md
	$(if $(findstring true,$(CHECK)),,@test -z "$(git ls-files CHANGELOG.md --modified)")
	$(if $(findstring true,$(CHECK)),,@git add CHANGELOG.md)
	$(if $(findstring true,$(CHECK)),@git restore CHANGELOG.md,)

release: release-needed ## Cut a release, if required.
	$(eval override CARGO_VERSION = $(shell ${CARGO} pkgid | gawk --file hack/version.awk))
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
	${CARGO} update

reset: # (Hidden from users) This resets the repo completely back to a squashed commit with a tagged version.
	@echo -n "This is going to do some bad stuff. Why would you do this? Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]
	# Reset
	git tag | xargs git tag -d
	echo "" > CHANGELOG.md
	git reset $(shell git commit-tree HEAD^{tree} -m 'feat(init): Initialize repository.')
	make release

##@ Provisioning
.PHONY := ci prerequisites

ci: prerequisites format lint audit conventional version readme changelog build document ## Run the CI pass locally.

ifeq ($(OS),Windows_NT) # is Windows_NT on XP, 2000, 7, Vista, 10...
prerequisites:
	${EMPTY} # User are on their own here, sadly. It's just too hard to bootstrap everything. PRs welcome.
else # Linux, etc...
prerequisites: package-gawk package-make package-curl package-git package-pkg-config rustup rust-component-llvm-tools-preview package-jq package-gawk inject-hooks ## Bootstrap the machine.
	$(if $(findstring true,$(PREREQS)),@bash ./distribution/bootstraps/ubuntu-20.04.sh,)
endif


##@ Hooks
.PHONY := inject-hooks hook-pre-commit

ifeq ($(OS),Windows_NT) # is Windows_NT on XP, 2000, 7, Vista, 10...
inject-hooks: ## Inject the git hooks used.
	@ln \
		-f \
		hack/git/hooks/pre-commit .git/hooks/pre-commit
else # Linux, etc...
inject-hooks:
	@ln \
		--symbolic \
		--force \
		../../hack/git/hooks/pre-commit .git/hooks/pre-commit
endif

hook-pre-commit: override CHECK = true
hook-pre-commit: ci

# Tools
.PHONY := package-% tool-% rust-component-% rust-toolchain-% rust-target-% rustup

ifeq ($(OS),Windows_NT) # is Windows_NT on XP, 2000, 7, Vista, 10...

package-%: override PACKAGE = $(@:package-%=%)
package-%:
	$(if $(findstring true,$(PREREQS)),scoop install ${PACKAGE},)

rustup:
    ${EMPTY}

else # Linux, etc...

package-%: override PACKAGE = $(@:package-%=%)
package-%:
	$(if $(findstring true,$(PREREQS)),sudo apt install ${PACKAGE} --yes -qqq,)

rustup:
	$(if $(findstring true,$(PREREQS)),curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --quiet,)

endif

pip3-%: override PACKAGE = $(@:pip3-%=%)
pip3-%: package-python3-pip
	$(if $(findstring true,$(PREREQS)),pip3 install ${PACKAGE} --user -qqq,)

tool-%: override TOOL = $(@:tool-%=%)
tool-%:
	$(if $(findstring true,$(PREREQS)),${CARGO} install ${TOOL} --quiet,)

rust-toolchain-%: override TOOLCHAIN = $(@:rust-toolchain-%=%)
rust-toolchain-%:
	$(if $(findstring true,$(PREREQS)),rustup toolchain install ${TOOLCHAIN},)

rust-component-%: override COMPONENT = $(@:rust-component-%=%)
rust-component-%: rust-toolchain-${CHANNEL}
	$(if $(findstring true,$(PREREQS)),rustup component add ${COMPONENT} --toolchain ${CHANNEL},)

rust-target-%: override ARCH = $(@:rust-target-%=%)
rust-target-%: rust-toolchain-${CHANNEL}
	$(if $(findstring true,$(PREREQS)),rustup target add ${ARCH} --toolchain ${CHANNEL},)
