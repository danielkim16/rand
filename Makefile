SWIFTC ?= swiftc

.PHONY: build run

build:
	mkdir -p bin
	$(SWIFTC) -parse-as-library src/rand.swift -o bin/rand

run: build
	./bin/rand
