#!/usr/bin/env bash
set -e

VENV_DIR=".venv"

if [ ! -d "${VENV_DIR}" ]; then
    echo "Creating virtual environment in ${VENV_DIR}..."
    python3 -m venv "${VENV_DIR}"
else
    echo "Virtual environment already exists in ${VENV_DIR}"
fi

source "${VENV_DIR}/bin/activate"
python -m pip install --upgrade pip
pip install -r requirements_env.txt

echo "Setup complete."
echo "Run: source ${VENV_DIR}/bin/activate"