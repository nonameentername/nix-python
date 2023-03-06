.PHONY: nix-python
nix-python:
	nix build

.PHONY: docker
docker:
	nix build '.#docker'

.PHONY: db
db:
	initdb -D db --no-locale --encoding=UTF8

.PHONY: clean
clean:
	rm -rf db

.PHONY: run
run:
	uvicorn nix_python.main:app --reload --host 0.0.0.0
