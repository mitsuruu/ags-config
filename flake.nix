{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    ags.url = "github:Aylur/ags";
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" "aarch64-linux" ];
      forEachSystem = nixpkgs.lib.genAttrs systems;
      pkgsFor = forEachSystem (system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      });

      devShellFor = system: nixpkgs.lib.genAttrs [ "default" ] (_: nixpkgs.legacyPackages.${system}.mkShell {
        buildInputs = [
          pkgsFor.${system}.fish
          pkgsFor.${system}.typescript
          pkgsFor.${system}.bun
          pkgsFor.${system}.libnotify
          inputs.ags.packages.${system}.agsWithTypes
        ];
        nativeBuildInputs = with pkgsFor.${system}; [
          nixpkgs-fmt
          nil
        ];
        shellHook = ''
          export GDK_BACKEND=wayland
        '';
      });  
  in {
    devShells = forEachSystem (system: devShellFor system);

    overlay = forEachSystem(system: 
      let
        pkgs = pkgsFor.${system};
      in final: prev: {
        chiags = (pkgs.callPackage ./. { inherit inputs; }).desktop.script;
      });

    packages = forEachSystem(system: 
      let
        pkgs = pkgsFor.${system};
      in {
        default = (pkgs.callPackage ./. { inherit inputs; }).desktop.script;
      });
  };
}
