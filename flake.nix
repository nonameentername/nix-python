{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };
  outputs = { self, nixpkgs, flake-utils, ... }:
  flake-utils.lib.eachDefaultSystem (system:
  let
    pkgs = import nixpkgs {
      inherit system;
    };

    pythonBuild = pkgs.poetry2nix.mkPoetryApplication {
      projectDir = self;
    };

    dockerImage = pkgs.dockerTools.buildImage {
      name = "nix-python";
      tag = "latest";
      created = "now";
      config = { Cmd = [ "${pythonBuild}/bin/start" ]; };
    };

    devShell = pkgs.mkShellNoCC {
      name = "nix-python";
      shellHook = "echo Welcome to your Nix-powered development environment!";
      packages = with pkgs; [
        (poetry2nix.mkPoetryEnv { projectDir = self; })
        overmind
        postgresql
        sqlite
      ];
    };

  in {
    packages = {
      default = pythonBuild;
      docker = dockerImage;
    };

    devShells = {
      default = devShell;
    };

    apps = {
      default = {
        program = "${pythonBuild}/bin/start";
        type = "app";
      };
    };
  }
  );
}
