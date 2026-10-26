#!/usr/bin/env bash
set -e

mongod --replSet rs0 --keyFile /etc/mongo-keyfile --bind_ip_all &
MONGOD_PID=$!
trap 'kill "$MONGOD_PID" 2>/dev/null; wait "$MONGOD_PID" 2>/dev/null' TERM INT

echo "[init-replica] waiting for local mongod..."
until mongosh --quiet --eval 'db.runCommand({ping:1}).ok' >/dev/null 2>&1; do
  sleep 1
done
echo "[init-replica] mongod is accepting connections."

if [ "${INIT_REPLICA_SET:-false}" = "true" ]; then
  # Before the first init rs.status() fails with NotYetInitialized. After init (auth enabled)
  # it fails with Unauthorized on restart, which means the set already exists: do not re-initiate.
  ALREADY_INITIATED=$(mongosh --quiet --eval 'try { rs.status().ok } catch (e) { e.codeName === "NotYetInitialized" ? 0 : 1 }' 2>/dev/null | tail -n1)
  if [ "$ALREADY_INITIATED" != "1" ]; then
    echo "[init-replica] initiating replica set rs0..."
    mongosh --quiet --eval '
      rs.initiate({_id:"rs0", members:[
        {_id:0, host:"mongo1:27017"},
        {_id:1, host:"mongo2:27017"},
        {_id:2, host:"mongo3:27017"}
      ]});
    '

    echo "[init-replica] waiting for PRIMARY election..."
    until mongosh --quiet --eval 'rs.isMaster().ismaster' 2>/dev/null | grep -q true; do
      sleep 1
    done

    echo "[init-replica] creating root user via the localhost exception..."
    mongosh --quiet --eval "
      db.getSiblingDB('admin').createUser({
        user: '${MONGO_ROOT_USERNAME}',
        pwd: '${MONGO_ROOT_PASSWORD}',
        roles: [{role: 'root', db: 'admin'}]
      });
    "
    echo "[init-replica] replica set ready, root user created."
  else
    echo "[init-replica] replica set already initiated, skipping."
  fi
fi

wait "$MONGOD_PID"