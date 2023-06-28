#!/bin/bash
dp0="$(realpath "$(dirname "$0")")"
set -e

tool_name="playwright"
tool_version="1.35.0"
self_name="python-3.10.5"

release_version_dirpath="$dp0/release/$tool_name-$tool_version"
mkdir -p "$release_version_dirpath" && cd "$dp0/release"

echo "download python install script ..."
python_bin_download_url="https://github.com/hemnstill/StandaloneTools/releases/download/$self_name/build-msvc.tar.gz"
python_download_zip="$dp0/release/$self_name.tar.gz"
[[ ! -f "$python_download_zip" ]] && wget "$python_bin_download_url" -O "$python_download_zip"

echo "download bsdtar ..."
bsdtar_version=3.6.2
bsdtar_download_url="https://github.com/hemnstill/StandaloneTools/releases/download/bsdtar-$bsdtar_version/build-mingw.tar.gz"
bsdtar_tar_gz="bsdtar-$bsdtar_version-build-mingw.tar.gz"
[[ ! -f "$bsdtar_tar_gz" ]] && wget "$bsdtar_download_url" -O "$bsdtar_tar_gz"
tar -xf "$bsdtar_tar_gz"

bsdtar="$dp0/release/bsdtar.exe"

cpython_bin="$release_version_dirpath/Scripts/python.exe"
[[ ! -f "$cpython_bin" ]] && tar -xf "$python_download_zip" -C "$release_version_dirpath"

"$cpython_bin" -m pip install "$tool_name==$tool_version"

cp -f "$dp0/release/playwright.bat" "$release_version_dirpath/"
cp -f "$dp0/release/__main__playwright.py" "$release_version_dirpath/"


export PLAYWRIGHT_BROWSERS_PATH="$release_version_dirpath/ms-playwright"
echo "download browsers to '$PLAYWRIGHT_BROWSERS_PATH' ..."
cd "$release_version_dirpath"
./"$tool_name.bat" install chromium

echo "creating archive ..."

{ printf '### build-msvc.tar.gz
Playwright %s
Python %s

' "$(./"$tool_name.bat" --version)" "$("$cpython_bin" -c "import sys; print(sys.version)")"
} > build-msvc.md

cat build-msvc.md

"$bsdtar" \
  --exclude="__pycache__" \
  --exclude="Scripts/Scripts" \
  --exclude="*.whl" \
  -czvf ../build-msvc.tar.gz .
