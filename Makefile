DEVICES := crown cronos checkers rook biscuit

.PHONY: sync docker stage test check release $(DEVICES)

sync:
	./scripts/sync.sh

docker:
	docker build -t lineage-18.1-ubuntu20:latest -f docker/lineage-18.1.Dockerfile docker/

stage:
	DEVICE=$(DEVICE) ./scripts/stage-tree.sh

$(DEVICES):
	DEVICE=$@ ./scripts/build.sh

check:
	DEVICE=$(DEVICE) ./scripts/check-image.sh

release:
	DEVICE=$(DEVICE) ./scripts/publish-release.sh

test:
	bash tests/test-stage-tree.sh
	bash tests/test-biscuit-system-update.sh
	bash tests/test-echo-system-update.sh
	bash tests/test-device-layers.sh
