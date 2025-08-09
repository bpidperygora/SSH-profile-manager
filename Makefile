# Simple Makefile for installing ssh-connect

PREFIX ?= /usr/local
BIN_DIR ?= $(PREFIX)/bin
NAME ?= ssh-connect

.PHONY: install uninstall reinstall deps

install: deps
	@./install.sh --bin-dir=$(BIN_DIR) --name=$(NAME)

uninstall:
	@./uninstall.sh --bin-dir=$(BIN_DIR) --name=$(NAME)

reinstall: uninstall install

deps:
	@echo "Ensuring optional deps (openssl, sshpass, fzf) are present..."
	@NO_DEPS=1 ./install.sh --bin-dir=$(BIN_DIR) --name=$(NAME) >/dev/null 2>&1 || true


