# Variables
BUN ?= bun
BUNX ?= bunx
BIOME ?= biome
FILES ?= src/

RUN = $(BUN) run

# Next.js main commands
dev:
	$(RUN) dev

build:
	$(RUN) build

start:
	$(RUN) start

# Linting and formatting
lint:
	${BUNX} $(BIOME) lint --write $(FILES)

format:
	${BUNX} $(BIOME) format --write $(FILES)

check:
	${BUNX} $(BIOME) check --write $(FILES)

# Git hooks and precommit
precommit:
	$(RUN) precommit

prepare:
	$(RUN) prepare

# Tests
test:
	$(RUN) test

test-watch:
	$(RUN) test:watch

# Optional cleaning
clean:
	rm -rf .next node_modules
