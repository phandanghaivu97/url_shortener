#!/bin/sh
set -e

./bin/rails dev:cache
./bin/rails db:create db:migrate

exec "$@"
