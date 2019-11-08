_login:
	@ test -z "${DOCKERHUB_USER}" -o -z "${DOCKERHUB_PASSWORD}" && \
		echo "Missing dockerhub username and/or password" || \
		docker login -u "${DOCKERHUB_USER}" -p "${DOCKERHUB_PASSWORD}"

_build: _login
	@ docker-compose build

_push: _login
	@ docker-compose -f docker-compose.yml push


################################################################################
# Staging

staging-build:
	@ ENVIRONMENT=${ENVIRONMENT} TAG=${TAG} $(MAKE) _build

staging-push:
	@ ENVIRONMENT=${ENVIRONMENT} TAG=${TAG} $(MAKE) _push

staging-deploy:
	@ scp docker-compose.yml "${DEPLOY_HOST}:"
	@ ENVIRONMENT=${ENVIRONMENT} TAG=${TAG} ssh ${DEPLOY_HOST} "( \
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
	@ ENVIRONMENT=${ENVIRONMENT} TAG=${TAG} $(MAKE) _build

production-push:
	@ ENVIRONMENT=${ENVIRONMENT} TAG=${TAG} $(MAKE) _push

production-deploy:
	@ scp docker-compose.yml "${DEPLOY_HOST}:"
	@ ENVIRONMENT=${ENVIRONMENT} TAG=${TAG} ssh ${DEPLOY_HOST} "( \
		docker login -u '${DOCKERHUB_USER}' -p '${DOCKERHUB_PASSWORD}'; \
		ENVIRONMENT=${ENVIRONMENT} TAG=${TAG} docker stack deploy \
			-c docker-compose.yml \
			--prune \
			--with-registry-auth \
			actions_test; \
	)"
