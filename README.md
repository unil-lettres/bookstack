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

``docker compose up`` (add -d if you want to run in the background and silence the logs)

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

`docker compose up -d`

Use a reverse proxy configuration to map the url to port `8282`.

# Application updates

We trigger a [GitHub Actions workflow](https://github.com/unil-lettres/bookstack/blob/main/.github/workflows/docker.yml) to build the custom image and push it to our [Docker Hub repository](https://hub.docker.com/repository/docker/unillett/bookstack/general).

When a new [Bookstack version](https://github.com/BookStackApp/BookStack/releases) is available, you should update the value in the [VERSION](https://github.com/unil-lettres/bookstack/blob/main/VERSION) file to reference the new tag. When the change is pushed to the repository, the workflow will automatically build the new image and push it to [Docker Hub](https://hub.docker.com/repository/docker/unillett/bookstack/general).

If you need to trigger a rebuild or mark a custom image version, you can add a revision suffix (such as `-rev1`) to the value in the `VERSION` file. This suffix will be ignored when fetching the BookStack source code, but it allows you to distinguish builds in your workflow and Docker image tags.

# Docker images

GitHub Actions workflows generate Docker image tags based on these events:
- Push to `development`: `stage-latest`, `stage-<sha>-<timestamp>` (immutable)
- Push to `main`: `latest`
- Push a git tag: `vX.Y.Z` (immutable, from VERSION)

Weekly cron jobs:
- Create an updated staging image: `stage-<sha>-<timestamp>` (immutable)
- Create an updated production candidate: `vX.Y.Z-<sha>-<timestamp>` (immutable, from VERSION)

All the immutable tags are committed to the [k8s](https://github.com/unil-lettres/k8s) repository.

# Helm

The Helm charts for this project are available at [https://github.com/unil-lettres/k8s](https://github.com/unil-lettres/k8s), in the ``wlett`` directory.
