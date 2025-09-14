#!/usr/bin/env just --justfile

# Load environment variables from `.env` file.
set dotenv-load

# print available targets
default:
    @just --list --justfile {{justfile()}}

# evaluate and print all just variables
evaluate:
    @just --evaluate

# Make specified infra up
up INFRA:
    @cd {{INFRA}} && docker-compose -f dc.yaml up -d
    @echo "{{INFRA}} is up"

# Make specified infra down
down INFRA:
    @cd {{INFRA}} && docker-compose -f dc.yaml down
    @echo "{{INFRA}} is down"