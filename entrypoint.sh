#!/bin/bash


SHRTBRED_PORT=${SHRTBRED_PORT:-3000}
SHRTBRED_DATABASE_HOST=${SHRTBRED_DATABASE_HOST:-"localhost"}
SHRTBRED_DATABASE_NAME=${SHRTBRED_DATABASE_NAME:-"shrtbred"}
SHRTBRED_DATABASE_USER=${SHRTBRED_DATABASE_USER:-"shrtbred"} 
SHRTBRED_DATABASE_PORT=${SHRTBRED_DATABASE_PORT:-5432} 
SHRTBRED_DATABASE_PASSWORD=${SHRTBRED_DATABASE_PASSWORD:-"shrtbred"} 
SHRTBRED_SEED_DATA=${SHRTBRED_SEED_DATA:-false} 
RAILS_ENV=${RAILS_ENV:-"development"} 

echo "== PARAMETERS =="
echo "   ENV     : $RAILS_ENV"
echo "   PORT    : $SHRTBRED_PORT"
echo "   HOST    : $SHRTBRED_DATABASE_HOST"
echo "   PORT    : $SHRTBRED_DATABASE_PORT"
echo "   USER    : $SHRTBRED_DATABASE_USER"
echo "   DATABASE: $SHRTBRED_DATABASE_NAME "
echo "   SEED    : $SHRTBRED_SEED_DATA "
$(dockerize -wait tcp://$SHRTBRED_DATABASE_HOST:$SHRTBRED_DATABASE_PORT)

echo "== Waiting a 30 seconds for postgres to become available =="
# sleep 30

./bin/rails db:prepare
./bin/rails log:clear tmp:clear

if [[ $RAILS_ENV == "production" && $SECRET_KEY_BASE == "" ]] ;then
    echo "ENV VAR: SECRET_KEY_BASE is not set. Run 'rails secret' to generate a secret"
    exit 1
fi

echo ""
if [[ -n $SHRTBRED_SEED_DATA ]] ; then 
echo "== Populating the environment with seed data =="
rails db:seed 
echo "== Finished Populating the environment with seed data =="
else
echo "== Will not try to populate environment with seed information =="
fi
echo ""

rails s -p $SHRTBRED_PORT -b '0.0.0.0'