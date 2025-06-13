{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell rec {
  buildInputs = with pkgs; [
    python3
    qt5.qtbase
    qt5.full
    libGL
    openblas
    lapack
    freetype
    libpng
    zlib
    pkg-config
    gcc
    (lib.getLib stdenv.cc.cc)
    libxkbcommon
    fontconfig
    xorg.libX11
    glib
    zstd
    dbus
    xorg.libxcb
    nss
    nspr
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXfixes
    xorg.libXrender
    xorg.libXrandr
    xorg.libXtst
    libdrm
    xorg.libXi
    alsa-lib
    xorg.libxshmfence
    mesa
    libgbm
    xorg.libxkbfile
    krb5
    xcb-util-cursor
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
    xorg.xcbutilimage
  ];

  shellHook = ''
    export VENV_DIR=$(pwd)/.venv
    if [ ! -d "$VENV_DIR" ]; then
      echo "Creating virtual environment in $VENV_DIR..."
      python3 -m venv $VENV_DIR
    fi
    source $VENV_DIR/bin/activate
    python -m pip install 'fmpy[complete]'

    # Set LD_LIBRARY_PATH to include all buildInputs library paths
    export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath buildInputs}

    export C_INCLUDE_PATH=$C_INCLUDE_PATH:$VENV_DIR/lib/python3.12/site-packages/fmpy/c-code
    export CPATH=$CPATH:$VENV_DIR/lib/python3.12/site-packages/fmpy/c-code

    # Set QT_PLUGIN_PATH for Qt plugins
    export QT_PLUGIN_PATH=${pkgs.qt5.full}/lib/qt-${pkgs.qt5.qtbase.version}/plugins

    # Configure Qt platform
    export QT_QPA_PLATFORM=xcb
    export QT_LOGGING_RULES="qt5ct.debug=true;qt5ct.plugin=true"

    # Verify fmpy installation
    if python -c "import fmpy" 2>/dev/null; then
      echo "fmpy is successfully installed and importable."
    else
      echo "Warning: fmpy is not importable."
    fi
    
    echo "FMPy GUI environment is ready!"
    echo "You can run the FMPy GUI by executing 'python -m fmpy.gui' in this shell."
    python -m fmpy.gui
  '';
}