# onlyoffice

[![Build Status](https://drone.owncloud.com/api/badges/owncloud-ops/onlyoffice/status.svg)](https://drone.owncloud.com/owncloud-ops/onlyoffice/)
[![Docker Hub](https://img.shields.io/badge/docker-latest-blue.svg?logo=docker&logoColor=white)](https://hub.docker.com/r/owncloudops/onlyoffice)
[![Quay.io](https://img.shields.io/badge/quay-latest-blue.svg?logo=docker&logoColor=white)](https://quay.io/repository/owncloudops/onlyoffice)

Custom container image for [OnlyOffice Docs](https://www.onlyoffice.com).

## Ports

- 8080

## Volumes

- /var/lib/onlyoffice

## Environment Variables

```Shell
ONLYOFFICE_LOG_LEVEL="INFO"
ONLYOFFICE_METRICS_ENABLED="false"
ONLYOFFICE_METRICS_HOST="localhost"
ONLYOFFICE_METRICS_PORT="8125"
ONLYOFFICE_METRICS_PREFIX="ds"

ONLYOFFICE_DB_HOST="mariadb"
ONLYOFFICE_DB_PORT="3306"
ONLYOFFICE_DB_NAME="onlyoffice"
ONLYOFFICE_DB_USER="onlyoffice"
ONLYOFFICE_DB_PASSWORD="onlyoffice"

ONLYOFFICE_REDIS_HOST="redis"
ONLYOFFICE_REDIS_PORT="6379"

# Enables JSON Web Token validation by the Onlyoffice Document Server.
ONLYOFFICE_JWT_ENABLED="false"
# Defines the secret key to validate the JSON Web Token in the request.
ONLYOFFICE_JWT_SECRET="secret"
# Defines the http header that will be used to send the JSON Web Token.
ONLYOFFICE_JWT_HEADER="Authorization"
# Enables the token validation in the request body.
ONLYOFFICE_JWT_IN_BODY="false"

ONLYOFFICE_AMQP_PROTO="amqp"
ONLYOFFICE_AMQP_USER="guest"
ONLYOFFICE_AMQP_PASSWORD="guest"
ONLYOFFICE_AMQP_HOST="rabbitmq"
ONLYOFFICE_AMQP_PORT="5672"

# Specifies the enabling the wopi handlers.
ONLYOFFICE_WOPI_ENABLED="false"

# Should be set to a random string for production use.
ONLYOFFICE_SECURE_LINK_SECRET="verysecretstring"

ONLYOFFICE_IPFILTER_RULES='[{"address": "*", "allowed": true}]'
ONLYOFFICE_REQUEST_FILTER_ALLOW_PRIVATE_IP_ADDRESS="false"
ONLYOFFICE_REQUEST_FILTER_ALLOW_META_IP_ADDRESS="false"
```

## Build

```Shell
docker build -f Dockerfile --target onlyoffice -t onlyoffice:latest .
```

## License

This project is licensed under the Apache 2.0 License - see the [LICENSE](https://github.com/owncloud-ops/onlyoffice/blob/main/LICENSE) file for details.
