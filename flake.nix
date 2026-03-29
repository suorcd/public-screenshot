{
  description = "Screenshot scripts with upload to remote server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      lib = nixpkgs.lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    {
      devShells = lib.genAttrs systems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              bash
              shellcheck
              flameshot
              rsync
              wl-clipboard
              xsel
            ];

            shellHook = ''
              echo "public-screenshot dev shell"
              echo "Run 'shellcheck *.sh' to lint all scripts"
            '';
          };
        }
      );
    };
}
