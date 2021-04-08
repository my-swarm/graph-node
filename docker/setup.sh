#!/usr/bin/env bash


if [ "$1" == "kovan" ]; then
  echo "Setting up for kovan"
  NETWORK=kovan
	PORT_IPFS=5201
	PORT_PG=54322
	PORT_GRAPH_1=8200
	PORT_GRAPH_2=8201
	PORT_GRAPH_3=8220
	PORT_GRAPH_4=8230
	PORT_GRAPH_5=8240
#	ETHEREUM_HOST="kovan:http:\/\/{host.docker.internal}:8545"
	ETHEREUM_HOST="kovan:https:\/\/kovan.infura.io\/v3\/4aaace1ae3d8484f81138b24012ae2d2"

elif [ "$1" == "mainnet" ]; then
  echo "Setting up for mainnet"
  NETWORK=mainnet
	PORT_IPFS=5301
	PORT_PG=54323
	PORT_GRAPH_1=8300
	PORT_GRAPH_2=8301
	PORT_GRAPH_3=8320
	PORT_GRAPH_4=8330
	PORT_GRAPH_5=8340
	ETHEREUM_HOST="mainnet:https:\/\/mainnet.infura.io\/v3\/4aaace1ae3d8484f81138b24012ae2d2"
else
  echo "Setting up for local testnet"
  NETWORK=local
	PORT_IPFS=5101
	PORT_PG=54321
	PORT_GRAPH_1=8100
	PORT_GRAPH_2=8101
	PORT_GRAPH_3=8120
	PORT_GRAPH_4=8130
	PORT_GRAPH_5=8140
	ETHEREUM_HOST="mainnet:http:\/\/{host.docker.internal}:8545"
fi

sed -e "s/{ethereum.host}/$ETHEREUM_HOST/g; s/{port.ipfs}/$PORT_IPFS/g; s/{port.pg}/$PORT_PG/g; s/{port.graph.1}/$PORT_GRAPH_1/g; s/{port.graph.2}/$PORT_GRAPH_2/g; s/{port.graph.3}/$PORT_GRAPH_3/g; s/{port.graph.4}/$PORT_GRAPH_4/g; s/{port.graph.5}/$PORT_GRAPH_5/g;" docker-compose.yml.template > docker-compose.yml.tmp

set -e

if ! which docker 2>&1 > /dev/null; then
  echo "Please install 'docker' first"
  exit 1
fi

if ! which docker-compose 2>&1 > /dev/null; then
  echo "Please install 'docker-compose' first"
  exit 1
fi

if ! which jq 2>&1 > /dev/null; then
  echo "Please install 'jq' first"
  exit 1
fi


function stop_graph_node {
  # Ensure graph-node is stopped
  docker-compose stop graph-node
}

#if [ "$NETWORK" == "local" ]; then
  # Create the graph-node container
  docker-compose up --no-start graph-node

  # Start graph-node so we can inspect it
  docker-compose start graph-node

  # Identify the container ID
  CONTAINER_ID=$(docker container ls | grep graph-node | cut -d' ' -f1)

	HOST_IP=$(docker inspect "$CONTAINER_ID" | jq -r .[0].NetworkSettings.Networks[].Gateway)
  echo "Local ethereum host IP: $HOST_IP"

  # Inject the host IP into docker-compose.yml
  sed -e "s/{host.docker.internal}/$HOST_IP/g" docker-compose.yml.tmp > docker-compose.yml

  trap stop_graph_node EXIT
#else
 # mv docker-compose.yml.tmp docker-compose.yml
#fi
echo "Ethereum host: $ETHEREUM_HOST"

