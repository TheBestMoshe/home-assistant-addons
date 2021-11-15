#!/bin/bash

set -e

CONFIG_PATH=/data/options.json

# Load config
export DATABASE_URL=$(jq --raw-output ".database_url" $CONFIG_PATH)
export BASE_URL=$(jq --raw-output ".base_url" $CONFIG_PATH)
export JWT_SECRET=$(jq --raw-output ".jwt_secret" $CONFIG_PATH)
export GOOGLE_API_CREDENTIALS=$(jq --raw-output ".google_api_credentials_base_64" $CONFIG_PATH | openssl base64 -d)

export NEXTAUTH_URL="${BASE_URL}/api/auth"
export NEXT_PUBLIC_APP_URL=$BASE_URL
export CALENDSO_ENCRYPTION_KEY=export JWT_SECRET=$(jq --raw-output ".calendso_encryption_key" $CONFIG_PATH)

# EXPOSE_PRISMA_STUDIO=$(jq --raw-output ".expose_prisma_studio" $CONFIG_PATH)

# The `NEXT_PUBLIC_APP_URL` variable needs to be set at build time. We use this technique to set it at runtime
# https://github.com/vercel/next.js/discussions/17641#discussioncomment-339555
function apply_app_url() {
    echo "Check that we have NEXT_PUBLIC_APP_URL vars"
    test -n "NEXT_PUBLIC_APP_URL"
    find .next \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i "s#APP_NEXT_PUBLIC_APP_URL_VAR#$NEXT_PUBLIC_APP_URL#g"
}
apply_app_url

yarn run db-migrate

# yarn start

# Based on https://stackoverflow.com/a/56663151/9642772
yarn start &
P1=$!
npx prisma studio &
P2=$!
wait $P1 $P2
