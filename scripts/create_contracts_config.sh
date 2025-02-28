# Generate the configuration file for the contracts
envsubst < core-config.yaml.template > configs/core-config.yaml
echo "OK"
