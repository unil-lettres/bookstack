# Introduction

Docker configuration for the [Bookstack](https://github.com/BookStackApp/BookStack) application.

# Development with Docker

## Docker installation

A working [Docker](https://docs.docker.com/engine/install/) installation is mandatory.

### Docker environment file

Please make sure to copy & rename the **example.env** file to **.env**.

``cp example.env .env``

You can replace the values if needed, but the default ones should work for local development.

Please also make sure to copy & rename the docker-compose.override.yml.dev file to docker-compose.override.yml.

``cp docker-compose.override.yml.dev docker-compose.override.yml``

You can replace the values if needed, but the default ones should work for local development.

### Edit hosts file

Edit hosts file to point **bookstack.lan** to your docker host.

### Populate database

If you want to automatically import a bookstack database, you can add the dump file in the `import` folder, and rename it **import.sql**. The content will be imported the first time the `mysql-data` volume is created.

### Build & run

Build & run all the containers for this project.

``docker-compose up`` (add -d if you want to run in the background and silence the logs)

## Frontends

To access the main application please use the following link.

[http://bookstack.lan:8282](http://bookstack.lan:8282)

+ admin@admin.com / password

### MailHog

To access mails please use the following link.

[http://bookstack.lan:8026](http://bookstack.lan:8026)

Or to get the messages in JSON format.

[http://bookstack.lan:8026/api/v2/messages](http://bookstack.lan:8026/api/v2/messages)

# Deployment with Docker

Copy and rename the environment file.

``cp example.env .env``

You should replace the values since the default ones are not ready for production.

Please also make sure to copy & rename the **docker-compose.override.yml.prod** file to **docker-compose.override.yml**.

`cp docker-compose.override.yml.prod docker-compose.override.yml`

You can replace the values if needed, but the default ones should work for production.

Build & run all the containers for this project:

`docker-compose up -d`

Use a reverse proxy configuration to map the url to port `8282`.

# Helm

The Helm charts for this project are available at [https://github.com/unil-lettres/k8s](https://github.com/unil-lettres/k8s), in the ``bookstack`` directory.
