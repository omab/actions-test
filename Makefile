_login:
	@ test -z "${DOCKERHUB_USER}" -o -z "${DOCKERHUB_PASSWORD}" && \
		echo "Missing dockerhub username and/or password" || \
		docker login -u "${DOCKERHUB_USER}" -p "${DOCKERHUB_PASSWORD}"

_build: _login
	@ ENVIRONMENT=${ENVIRONMENT} TAG=${TAG} docker-compose build

_push: _login
	@ ENVIRONMENT=${ENVIRONMENT} TAG=${TAG} docker-compose -f docker-compose.yml push

_deploy:
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
# Staging

staging-build: _build

staging-push: _push

staging-deploy: _deploy


################################################################################
# Production

production-build: _build

production-push: _push

production-deploy: _deploy
