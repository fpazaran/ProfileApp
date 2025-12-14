#!/bin/bash

OS="$(uname -s 2>/dev/null || echo Windows)"
case "$OS" in
    Linux*)     PLATFORM="linux";   PY_CMD="python3"; ACTIVATE_PATH="venv/bin/activate";;
    Darwin*)    PLATFORM="mac";     PY_CMD="python3"; ACTIVATE_PATH="venv/bin/activate";;
    CYGWIN*|MINGW*|MSYS*|Windows*)
                PLATFORM="windows"; PY_CMD="py";  ACTIVATE_PATH="venv/Scripts/activate";;
    *)          PLATFORM="unknown"; PY_CMD="py";  ACTIVATE_PATH="venv/bin/activate";;
esac

cd backend
echo "Setting up backend..."

# Create venv if it doesn't exist or is corrupted
if [ -f "$ACTIVATE_PATH" ]; then
    echo "Venv already exists"
else
    echo "Creating virtual environment..."
    rm -rf venv 2>/dev/null
    $PY_CMD -m venv venv
fi

# Activate venv
source "$ACTIVATE_PATH"

# Install dependencies
pip install -r requirements.txt
cd ..


echo "Setting up frontend..."
cd frontend
npm install
cd ..

echo ""
echo "======================================"
echo " ✅ Setup Complete!"
echo "--------------------------------------"
echo "To start the servers:"
echo ""
echo "  1️⃣  Start backend:"
echo "      cd backend"
if [ "$PLATFORM" = "windows" ]; then
echo "      venv/Scripts/activate"
else
echo "      source venv/bin/activate"
fi
echo "      $PY_CMD main.py"
echo ""
echo "  2️⃣  Start frontend:"
echo "      cd frontend"
echo "      npm start"
echo ""
echo "Then open http://localhost:3000 to view your app."
echo "======================================"