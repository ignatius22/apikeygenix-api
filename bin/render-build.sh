#!/usr/bin/env bash
set -o errexit  # Exit on error
set -o xtrace   # Log commands for debugging

echo "Checking Node.js..."
if ! command -v node &> /dev/null; then
  echo "Installing Node.js 18.x..."
  curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
  apt-get install -y nodejs
fi
echo "Node.js version: $(node -v)"
echo "npm version: $(npm -v)"

echo "Installing Ruby dependencies..."
bundle install

echo "Installing Node.js dependencies..."
npm install

echo "Running database migrations..."
bundle exec rails db:migrate