#!/bin/bash

#inspire at https://github.com/wercker/step-rails-database-yml

main() {
  local database_yml_path="$PWD/config/database.yml"

  # Check if there is a linked docker postgresql instance
  if [ -n "$POSTGRES_PORT_5432_TCP_ADDR" ]; then
    generate_postgresql_docker "$database_yml_path"
    return
  fi
}

generate_postgresql_docker() {
  local location="${1:?'location is required'}"

  if [ -z "$POSTGRES_ENV_POSTGRES_PASSWORD" ]; then
    warn "POSTGRES_PASSWORD env var for the postgres service is not set"
  fi

  info "Generating postgresql docker template"
  tee "$location" << EOF
production:
    adapter: <%= ENV['WERCKER_POSTGRESQL_ADAPTER'] || 'postgresql' %>
    encoding: "utf8"
    database: <%= ENV['POSTGRES_ENV_POSTGRES_DB'] || ENV['POSTGRES_ENV_POSTGRES_USER'] || 'postgres' %><%= ENV['TEST_ENV_NUMBER'] %>
    username: <%= ENV['POSTGRES_ENV_POSTGRES_USER'] || 'postgres' %>
    password: <%= ENV['POSTGRES_ENV_POSTGRES_PASSWORD'] %>
    host: <%= ENV['POSTGRES_PORT_5432_TCP_ADDR'] %>
    port: <%= ENV['POSTGRES_PORT_5432_TCP_PORT'] %>
    min_messages: $WERCKER_RAILS_DATABASE_YML_POSTGRESQL_MIN_MESSAGE

test:
    adapter: <%= ENV['WERCKER_POSTGRESQL_ADAPTER'] || 'postgresql' %>
    encoding: "utf8"
    database: <%= ENV['POSTGRES_ENV_POSTGRES_DB'] || ENV['POSTGRES_ENV_POSTGRES_USER'] || 'postgres' %><%= ENV['TEST_ENV_NUMBER'] %>
    username: <%= ENV['POSTGRES_ENV_POSTGRES_USER'] || 'postgres' %>
    password: <%= ENV['POSTGRES_ENV_POSTGRES_PASSWORD'] %>
    host: <%= ENV['POSTGRES_PORT_5432_TCP_ADDR'] %>
    port: <%= ENV['POSTGRES_PORT_5432_TCP_PORT'] %>
    min_messages: $WERCKER_RAILS_DATABASE_YML_POSTGRESQL_MIN_MESSAGE
EOF
}

main:

