#!/bin/bash
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the Apache 2.0 License.

set -e

VENV_DIR=${VENV_DIR:-.venv_ccf_sandbox}

PATH_HERE=$(dirname "$(realpath -s "$0")")
VERSION_FILE="${PATH_HERE}"/../share/VERSION
GOV_SCRIPT="${PATH_HERE}"/sandbox_gov.lua

is_package_specified=false
for item in "$@" ; do
    if [ "$item" == "-p" ] || [ "$item" == "--package" ]; then
        is_package_specified=true
    fi
done

extra_args=("$@")
if [ ${is_package_specified} == false ] && [ -f "${VERSION_FILE}" ]; then
    # Only on install tree, default to installed js logging app
    echo "No package/app specified. Defaulting to installed JS logging app"
    extra_args+=(--package "${PATH_HERE}/../lib/libjs_generic")
    extra_args+=(--js-app-bundle "${PATH_HERE}/../samples/logging/js")
fi

echo "Setting up Python environment..."

if [ ! -f "${VENV_DIR}/bin/activate" ]; then
    python3.8 -m venv "${VENV_DIR}"
fi
# shellcheck source=/dev/null
source "${VENV_DIR}"/bin/activate

if [ -f "${VERSION_FILE}" ]; then
    # install tree
    BINARY_DIR=${PATH_HERE}
    START_NETWORK_SCRIPT="${PATH_HERE}"/start_network.py
    VERSION=$(<"${VERSION_FILE}")
    pip install --disable-pip-version-check -q -U ccf=="$VERSION"
    pip install --disable-pip-version-check -q -U -r "${PATH_HERE}"/requirements.txt
else
    # source tree
    BINARY_DIR=.
    START_NETWORK_SCRIPT="${PATH_HERE}"/../start_network.py
    pip install --disable-pip-version-check -q -U -e "${PATH_HERE}"/../../python/
    pip install --disable-pip-version-check -q -U -r "${PATH_HERE}"/../requirements.txt
fi

echo "Python environment successfully setup"

export CURL_CLIENT=ON
exec python "${START_NETWORK_SCRIPT}" \
    --binary-dir "${BINARY_DIR}" \
    --enclave-type release \
    --initial-member-count 7 \
    --initial-user-count 1 \
    --gov-script "${GOV_SCRIPT}" \
    --ledger-chunk-bytes 5MB \
    --label sandbox \
    "${extra_args[@]}"
