include .env
export

.PHONY: nix-python
nix-python:
	nix build

.PHONY: docker
docker:
	nix build '.#docker'
	docker load < result

.PHONY: initdb
initdb:
	initdb -D db --no-locale --encoding=UTF8
	echo "host  all  all 0.0.0.0/0 trust" >> db/pg_hba.conf

.PHONY: createdb
createdb:
	createdb db -h $(CURDIR)
	createuser user -h $(CURDIR)

.PHONY: alembic
alembic:
	alembic upgrade head

.PHONY: clean
clean:
	rm -rf db

.PHONY: run
run:
	uvicorn nix_python.main:app --reload --host 0.0.0.0

.PHONY: docker-run
docker-run:
	docker run -p 8000:8000 --env-file .env-docker --add-host=host.docker.internal:host-gateway nix-python

.PHONY: nix-run
nix-run:
	nix run
