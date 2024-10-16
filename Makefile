.PHONY: install configure

configure:
	@chmod +x scripts/configure.sh
	@scripts/configure.sh -t $(THRESHOLD) -k $(API_KEY) -s $(API_SECRET) -u $(API_ENDPOINT) -h $(API_HOMEPAGE)

install:
	@chmod +x scripts/install.sh
	@scripts/install.sh

THRESHOLD ?= 0.9
API_KEY ?= username
API_SECRET ?= password
API_ENDPOINT ?= http://localhost:8080/xapi
API_HOMEPAGE ?= http://yetanalytics.com
