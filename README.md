# Docker Development Setup

- Install Docker ([macOS](https://docs.docker.com/docker-for-mac/install/)/[Windows](https://docs.docker.com/docker-for-windows/install/)/[Linux](https://docs.docker.com/engine/install/))
- `.env` is populated with good defaults.
- Copy `.env` to `.env.development`
- Build project and start up

```bash
docker compose build
docker compose up
```

- Visit 127.0.0.1:8000 in your browser.
- The first time the application is brought up, some database updates need to be made due to shifting dependencies

- Identify your postgres container and run the following:

```
docker ps
# Note container id below
a320a4fabaac   postgres:15                    "docker-entrypoint.s…"
# Shell into container
docker exec -it [container id from above] /bin/bash

/bin/psql --username=postgres

ALTER DATABASE oral_history REFRESH COLLATION VERSION;
ALTER DATABASE oral_history_test REFRESH COLLATION VERSION;
ALTER DATABASE postgres REFRESH COLLATION VERSION;
ALTER DATABASE template0 REFRESH COLLATION VERSION;
ALTER DATABASE template1 REFRESH COLLATION VERSION;
```

- Load database and import data

```
docker compose exec web bundle exec rake db:migrate
docker compose exec web bundle exec rake db:seed
docker compose exec web bundle exec rake import[100]
```

- Sign into the Admin Dashboard
  Navigate to https://127.0.0.1:8000/users/sign_in
  Login with default the seeded user and password at db/seeds.rb
  Note you can add those ENV variable to your .env file to update
  the values in one place. But deafults are set so make sure you
  update for produciton environment.

- Common Developer Recipes:
  Drop into a bash console inside docker container:
  `docker compose exec container-name bash`
  Example: `docker compose exec web bash`

  Drop into a sh console inside docker container:
  `docker compose exec container-name sh`
  Example: `docker compose exec web sh`
  Drop into a rails console:
  `docker compose exec bundle exec rails c`

**Note:** The `100` in `import[100]` limits the number of assets initially loaded. You may adjust this as desired.

## Development Notes

When performing an import the system will attempt to download and process the audio files to create the peak files. This is very CPU & time intense.
**To avoid this** change `MAKE_WAVES` in your `.env` to false (or delete it).

# Build and Deploy Process

Optional: Contact DevSupport for Argo account for log access

### Application Only Changes

- Create a branch and make changes to the application code.

- Submit a pull and review request. On [**submission** of a pull request](https://github.com/UCLALibrary/oral-history/blob/main/.github/workflows/build-dockerhub.yml), a container image is built and pushed to Docker Hub. Update the pull request and incorporate any change requests required from the review. Any new commits or changes to the pull request will trigger a new container image to be created and pushed to Docker Hub.

- Navigate to Docker Hub and note the image tag, which is the first 8 characters of the hash.

- In the appropriate `charts/[environment]-oralhistory-values.yaml` file, update the `image: tag` value to the tag copied from Docker Hub in the previous step. This should be the final commit before merging the pull request.

- Update the pull request to reflect the final commit added for the new image created.
  Because a pull request will be updated, another container image build will be triggered -- using this process, the deployed image is always at least one "behind" the most recently submitted pull request.

On merging and pushing this change to `main`, the new `image: tag` value will trigger a new deployment. This process is automatic when updating `[stage,test]-oralhistory-values.yaml`.

For production, `prod-oralhistory-values.yaml` should be updated and DevSupport notified, and is not automatically deployed.

### Chart Changes

If there are changes to files under `templates/`, extra steps are required to propagate the chart changes.

- The `version` field must be incremented in `charts/Chart.yaml`
- Submit a pull request to the [gitops_kubernetes](https://github.com/UCLALibrary/gitops_kubernetes) repository.
- The pull request should increment the `sources : targetRevision` value under the appropriate environment section in the `apps\apps-team-prod-environment-values.yaml` file.
