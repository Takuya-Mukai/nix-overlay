{
  lib,
  python3,
  fetchPypi,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "japanize-matplotlib";
  version = "1.1.3";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-6J59nhCYIJYmUOWaEwQDtZszkV/eOHGiZaWJHZv14Hk=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  pythonImportsCheck = [
    "japanize_matplotlib"
  ];

  meta = {
    description = "Matplotlibのフォント設定を自動で日本語化する";
    homepage = "https://pypi.org/project/japanize-matplotlib/";
    license = lib.licenses.unfree; # FIXME: nix-init did not find a license
    maintainers = with lib.maintainers; [ ];
    mainProgram = "japanize-matplotlib";
  };
}
