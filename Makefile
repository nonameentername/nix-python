.PHONY: nix-python
nix-python:
	nix build

.PHONY: docker
docker:
	nix build '.#docker'
