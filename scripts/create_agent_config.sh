envsubst < config.json.template > configs/config.json
envsubst < env.source.template > .env
echo "OK"
