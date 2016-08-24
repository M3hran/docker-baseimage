NAME = m3hran/baseimage
VERSION = 0.1.0
C_NAME = baseimage

.PHONY: all build test tag_latest release install clean

all: build

build: 
	docker build -t $(NAME):$(VERSION) .

clean: 
	docker rm -vf $(C_NAME)
	
install:
	docker run -d --name $(C_NAME) $(NAME):$(VERSION)

tag_latest:
	docker tag -f $(NAME):$(VERSION) $(NAME):latest

release: tag_latest
	@if ! docker images $(NAME) | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME) version $(VERSION) is not yet built. Please run 'make build'"; false; fi
#	@if ! head -n 1 Changelog.md | grep -q 'release date'; then echo 'Please note the release date in Changelog.md.' && false; fi
	docker push $(NAME)
	@echo "*** Don't forget to create a tag. git tag rel-$(VERSION) && git push origin rel-$(VERSION)"
