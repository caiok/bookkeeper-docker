
IMAGE=caiok/bookkeeper:4.4.0
BK_LOCAL_DATA_DIR=/tmp/data
CONTAINER_NAME=bookkeeper
DOCKER_HOSTNAME=hostname

CONTAINER_IP=$(eval container_ip=$(shell docker inspect --format '{{ .NetworkSettings.IPAddress }}' $(CONTAINER_NAME)) )

#NOCACHE=--no-cache
NOCACHE=

# -------------------------------- #

.PHONY: all build run create start stop shell exec root-shell root-exec info ip clean-files clean

# -------------------------------- #

all:
	make info

# -------------------------------- #

build:

	time docker build \
	    $(NOCACHE) \
	    -t $(IMAGE) .

# -------------------------------- #

run:

	docker run -d \
	    --volume $(BK_LOCAL_DATA_DIR):/data \
	    --hostname "$(DOCKER_HOSTNAME)" \
	    --name "$(CONTAINER_NAME)" \
	    $(IMAGE)
	
run-debug:
	docker run -it \
	    --hostname "$(DOCKER_HOSTNAME)" \
	    --name "$(CONTAINER_NAME)" \
	    $(IMAGE)

# -------------------------------- #

create:
	-docker stop $(CONTAINER_NAME)
	-docker rm $(CONTAINER_NAME)
	make run

# -------------------------------- #

start:
	docker start "$(CONTAINER_NAME)"

# -------------------------------- #

stop:
	docker stop "$(CONTAINER_NAME)"

# -------------------------------- #

shell exec:
	docker exec -it \
	    "$(CONTAINER_NAME)" \
	    /bin/bash -il

# -------------------------------- #

root-shell root-exec:
	docker exec -it "$(CONTAINER_NAME)" /bin/bash -il

# -------------------------------- #

info ip:
	@echo 
	@echo "Image: $(IMAGE)"
	@echo "Container name: $(CONTAINER_NAME)"
	@echo
	-@echo "Actual Image: $(shell docker inspect --format '{{ .RepoTags }} (created {{.Created }})' $(IMAGE))"
	-@echo "Actual Container: $(shell docker inspect --format '{{ .Name }} (created {{.Created }})' $(CONTAINER_NAME))"
	-@echo "Actual Container IP: $(shell docker inspect --format '{{ .NetworkSettings.IPAddress }}' $(CONTAINER_NAME))"
	@echo

# -------------------------------- #

clean-files:
	

clean:
	-docker stop $(CONTAINER_NAME)
	-docker rm $(CONTAINER_NAME)
	-docker rmi $(IMAGE)
	make clean-files
