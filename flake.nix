{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    hello = "chat!";
    packages.${system}.default = pkgs.poetry2nix.mkPoetryApplication {
      projectDir = self;
    };

    devShells.${system}.default = pkgs.mkShellNoCC {
      shellHook = "echo Welcome to your Nix-powered development environment!";

      IS_NIX_AWESOME = "YES!";

      packages = with pkgs; [
        (poetry2nix.mkPoetryEnv { projectDir = self; })
        neofetch
      ];
    };

    apps.${system}.default = {
      program = "${self.packages.${system}.default}/bin/start";
      type = "app";
    };
  };
}
