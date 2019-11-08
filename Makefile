_login:
	@ test -z "${DOCKERHUB_USER}" -o -z "${DOCKERHUB_PASSWORD}" && \
		echo "Missing dockerhub username and/or password" || \
		docker login -u "${DOCKERHUB_USER}" -p "${DOCKERHUB_PASSWORD}"

_build: _login
	@ TAG=${TAG:-latest} docker-compose build

_push: _login
	@ TAG=${TAG:-latest} docker-compose -f docker-compose.yml push

_tag:
	@ git describe --tags --abbrev=0

################################################################################
# Staging

staging-build:
	@ ENVIRONMENT=staging $(MAKE) _build

staging-push:
	@ ENVIRONMENT=staging $(MAKE) _push

staging-deploy:
	@ scp docker-compose.yml "${DEPLOY_HOST}:"
	@ ssh ${DEPLOY_HOST} "( \
		docker login -u '${DOCKERHUB_USER}' -p '${DOCKERHUB_PASSWORD}'; \
		ENVIRONMENT=${ENVIRONMENT} TAG=${TAG} docker stack deploy \
			-c docker-compose.yml \
			--prune \
			--with-registry-auth \
			actions_test; \
	)"

################################################################################
# Production

production-build:
	@ ENVIRONMENT=production TAG=`$(MAKE) _tag` $(MAKE) _build

production-push:
	@ ENVIRONMENT=production TAG=`$(MAKE) _tag` $(MAKE) _push

production-deploy:
	@ scp docker-compose.yml "${DEPLOY_HOST}:"
	@ ENVIRONMENT=production TAG=`${MAKE} _tag` ssh ${DEPLOY_HOST} "( \
		docker login -u '${DOCKERHUB_USER}' -p '${DOCKERHUB_PASSWORD}'; \
		ENVIRONMENT=${ENVIRONMENT} TAG=${TAG} docker stack deploy \
			-c docker-compose.yml \
			--prune \
			--with-registry-auth \
			actions_test; \
	)"
