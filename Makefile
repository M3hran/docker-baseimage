include build.env

DOCKER_TAG 	   := $(IMG_VERSION)
VERMAJMIN      := $(subst ., ,$(DOCKER_TAG))
VERSION        := $(word 1,$(VERMAJMIN))
MAJOR          := $(word 2,$(VERMAJMIN))
MINOR          := $(word 3,$(VERMAJMIN))
NEW_MINOR      := $(shell expr "$(MINOR)" + 1)
NEW_DOCKER_TAG := $(VERSION).$(MAJOR).$(NEW_MINOR)

.PHONY: all build test tag_latest release install clean

all: clean build install

build: 
	sed -i 's/IMG_VERSION=.*/IMG_VERSION=$(NEW_DOCKER_TAG)/' build.env
	envsubst < Dockerfile | docker build --build-arg BUILD_DATE="$$(date --utc +%FT%TZ)" -t $(IMG_TITLE):$(NEW_DOCKER_TAG) . -f -
	
clean:
	@if docker ps -a | grep -q $(CONTAINER_NAME); then rm -rf $(CONTAINER_NAME) && docker rm -vf $(CONTAINER_NAME) && docker image rm $(IMG_TITLE):$(IMG_VERSION); fi

install:
    ifeq ($(MAKECMDGOALS) , all)
		IMG_VERSION=$(NEW_DOCKER_TAG) docker compose up -d
    else
		docker compose up -d
    endif

tag_latest:
	docker tag $(IMG_TITLE):$(IMG_VERSION) $(IMG_TITLE):latest

release: tag_latest
	@if ! docker images $(IMG_TITLE) | awk '{ print $$2 }' | grep -q -F $(IMG_VERSION); then echo "$(IMG_TITLE) version $(IMG_VERSION) is not yet built. Please run 'make build'"; false; fi
	docker push $(IMG_TITLE):$(IMG_VERSION)
	docker push $(IMG_TITLE)
	@echo "*** Don't forget to create a tag. git tag rel-$(IMG_VERSION) && git push origin rel-$(IMG_VERSION)"

