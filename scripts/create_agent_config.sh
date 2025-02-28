envsubst < config.json.template > configs/config.json
envsubst < env.template > .env
echo "OK"
