#!/bin/sh

# set -e

# if [ -z "${NGINX_ENTRYPOINT_QUIET_LOGS:-}" ]; then
#     exec 3>&1
# else
#     exec 3>/dev/null
# fi

# if [ "$1" = "nginx" -o "$1" = "nginx-debug" ]; then

LISTEN_PORT=${LISTEN_PORT:-3000}
SHRTBRED_HOST=${SHRTBRED_HOST:-"localhost"}
SHRTBRED_PORT=${SHRTBRED_PORT:-3100}
GENERATE_SSL_CERT=${GENERATE_SSL_CERT:-false}
SSL_CN=${SSL_CN:-"localhost"}

echo "== PARAMETERS =="
echo "   LISTEN_PORT    : $LISTEN_PORT"
echo "   SHRTBRED_HOST    : $SHRTBRED_HOST"
echo "   SHRTBRED_PORT    : $SHRTBRED_PORT"
echo "   GENERATE_SSL_CERT    : $GENERATE_SSL_CERT "
if [ "$GENERATE_SSL_CERT" = true ] ; then 
    echo "== GENERATING SSL CERTIFICATE =="
    $(openssl req -x509 -nodes -days 365 -subj "/C=US/ST=OH/O=SHORTBREAD, INC./CN=$SSL_CN" -addext "subjectAltName=DNS:$SSL_CN" -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt;)
fi


echo "== GENERATING DEFAULT.CONF =="
$(dockerize --template /etc/nginx/templates/default.conf.template:/etc/nginx/conf.d/default.conf)

echo "== WAITING FOR SHRTBRED =="
$(dockerize -wait tcp://$SHRTBRED_HOST:$SHRTBRED_PORT)
# fi

$(nginx -g 'daemon off;')