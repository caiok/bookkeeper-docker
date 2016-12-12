#!/bin/bash

set -x -e -u

java -jar /local/bookkeeper-dice-demo-1.0.jar --zookeeper-servers "${ZK_SERVERS}"

