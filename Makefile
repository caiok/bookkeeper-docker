
IMAGE=caiok/bookkeeper:4.4.0
BK_LOCAL_DATA_DIR=/tmp/data
CONTAINER_NAME=bookkeeper
DOCKER_HOSTNAME=hostname

ZK_CONTAINER_NAME=test_zookeeper
ZK_LOCAL_DATA_DIR=/tmp/data/zookkeeper

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
	-docker rmi -f $(IMAGE)
	time docker build \
	    $(NOCACHE) \
	    -t $(IMAGE) .

# -------------------------------- #

run:
	mkdir -p /tmp/data/journal /tmp/data/ledger /tmp/data/index
	-docker rm -f $(CONTAINER_NAME)
	docker run -it\
		--network host \
	    --volume $(BK_LOCAL_DATA_DIR)/journal:/data/journal \
	    --volume $(BK_LOCAL_DATA_DIR)/ledger:/data/ledger \
	    --volume $(BK_LOCAL_DATA_DIR)/index:/data/index \
	    --hostname "$(DOCKER_HOSTNAME)" \
	    --name "$(CONTAINER_NAME)" \
	    --env ZK_SERVERS=localhost:2181 \
	    $(FORMAT_METADATA) \
	    $(IMAGE)

# -------------------------------- #

run-format:
	#$(eval FORMAT_METADATA ?= --env FORMAT_METADATA=yes)
	make run FORMAT_METADATA="--env FORMAT_METADATA=yes"

# -------------------------------- #

run-zk:
	mkdir -p $(ZK_LOCAL_DATA_DIR)/data $(ZK_LOCAL_DATA_DIR)/datalog
	-docker rm -f $(ZK_CONTAINER_NAME)
	docker run -d \
		--network host \
		--name $(ZK_CONTAINER_NAME) \
		--restart always \
		-v $(ZK_LOCAL_DATA_DIR)/data:/data \
		-v $(ZK_LOCAL_DATA_DIR)/datalog:/datalog \
		-p 2181:2181 \
		zookeeper

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
