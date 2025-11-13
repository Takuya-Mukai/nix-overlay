{
  description = "A factory flake for creating UV-based Python devShells with FHS environment.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };

        # この関数は、追加のNixパッケージのリストを受け取り、
        # UVを使用して仮想環境をセットアップする開発シェルを生成します。
        # extraPkgs: FHS環境内に含める追加のNixパッケージのリスト
        # runCommand: シェル起動後に実行するコマンド (例: "bash", "zsh", "ls")
        mkUVPythonDevShell =
          {
            extraPkgs ? [ ],
            runCommand ? "bash",
          }:
          (pkgs.buildFHSEnv {
            name = "uv-python-env";

            # FHS環境内に含めるターゲットパッケージ
            targetPkgs =
              pkgs:
              (with pkgs; [
                python3
                uv # UV tool for fast dependency management
                # 【復活】C拡張を持つパッケージのビルドに必要なツール
                cmake
                ninja
                gcc
              ])
              ++ extraPkgs;

            # シェルが起動したときに実行されるスクリプト
            runScript = "${pkgs.writeShellScriptBin "runScript" (''
              set -e
              # .venv ディレクトリを確認し、存在しなければ UV を使って作成
              test -d .venv || ${pkgs.uv}/bin/uv venv
              # プロジェクトの Python バージョン設定ファイルを初期化
              test -f .python-version || ${pkgs.uv}/bin/uv init . 
              # 仮想環境をアクティベート
              source .venv/bin/activate
              set +e
              # 指定されたコマンドを実行 (デフォルトは bash)
              exec ${runCommand}
            '')}/bin/runScript";
          }).env;

      in
      {
        # 他の Flake から利用できるように、ライブラリとして関数をエクスポートします。
        lib.mkUVPythonDevShell = mkUVPythonDevShell;
      }
    );
}
