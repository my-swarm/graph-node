#!/bin/bash

if [ "$1" = "setup" ]
then
	docker-compose down -v;
	./setup.sh;
fi

if [ -d "data" ]
then
  echo "Found old data for the graph node - deleting it";
  # we need to sudo this to remove system locked files
  sudo rm -rf data/;
fi

docker-compose up;
