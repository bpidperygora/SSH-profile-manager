# Simple Makefile for installing ssh-connect

PREFIX ?= /usr/local
BIN_DIR ?= $(PREFIX)/bin
CLI_NAME ?= ssh-connect

.PHONY: install uninstall reinstall deps

install: deps
	@./install.sh --bin-dir=$(BIN_DIR) --name=$(CLI_NAME)

uninstall:
	@./uninstall.sh --bin-dir=$(BIN_DIR) --name=$(CLI_NAME)

reinstall: uninstall install

deps:
	@echo "Ensuring optional deps (openssl, sshpass, fzf) are present..."
	@NO_DEPS=1 ./install.sh --bin-dir=$(BIN_DIR) --name=$(CLI_NAME) >/dev/null 2>&1 || true


