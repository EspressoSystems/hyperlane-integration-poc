envsubst < config.json.template > source/config.json
envsubst < .env.source.template > .env.source
echo "OK"
