#!/usr/bin/with-contenv bashio

set -e

# 定义配置文件路径
CONFIG_PATH=/data/frpc.toml
LOG_FILE="/share/frpc.log"
APP_PATH="/usr/src"
WAIT_PIDS=()

function stop_frpc() {
    bashio::log.info "Stop frpc oidc "
    kill -15 "${WAIT_PIDS[@]}"
}

# 显示欢迎信息
ALL_CONFIG=$(bashio::config --all)
bashio::log.info "Starting FRP Client...${ALL_CONFIG}"

cat /data/options.json

# 检查 frpc 是否存在
if [ ! -f "${APP_PATH}/frpc" ]; then
    bashio::log.error "FRP Client binary not found at ${APP_PATH}/frpc"
    exit 1
fi

# 确保二进制文件可执行
chmod +x "${APP_PATH}/frpc"

# 从 Home Assistant 配置中获取值
SERVER_ADDR=$(bashio::config 'serverAddr')
SERVER_PORT=$(bashio::config 'serverPort')
AUTH_METHOD=$(bashio::config 'method')
CLIENT_ID=$(bashio::config 'clientID')
CLIENT_SECRET=$(bashio::config 'clientSecret')
AUDIENCE=$(bashio::config 'audience')
SCOPE=$(bashio::config 'scope')
TOKEN_URL=$(bashio::config 'tokenEndpointURL')

# 获取代理配置
PROXY_NAME=$(bashio::config 'name')
PROXY_TYPE=$(bashio::config 'type')
LOCAL_PORT=$(bashio::config 'localPort')
CUSTOM_DOMAIN=$(bashio::config 'customDomains')

bashio::log.info "Creating FRP Client configuration..."
bashio::log.info "Configuration created with following settings:"
bashio::log.info "Server: ${SERVER_ADDR}:${SERVER_PORT}"
bashio::log.info "Method: ${AUTH_METHOD}"
bashio::log.info "ClientId: ${CLIENT_ID}"
bashio::log.info "ClientSecret: ${CLIENT_SECRET}"
bashio::log.info "Audience: ${AUDIENCE}"
bashio::log.info "Proxy Name: ${PROXY_NAME}"
bashio::log.info "Proxy Type: ${PROXY_TYPE}"
bashio::log.info "Local Port: ${LOCAL_PORT}"
bashio::log.info "Custom Domain: ${CUSTOM_DOMAIN}"

# 创建 TOML 配置文件
cat > "${CONFIG_PATH}" << EOL
serverAddr = "${SERVER_ADDR}"
serverPort = ${SERVER_PORT}

auth.method = "${AUTH_METHOD}"
auth.oidc.clientID = "${CLIENT_ID}"
auth.oidc.clientSecret = "${CLIENT_SECRET}"
auth.oidc.audience = "${AUDIENCE}"
auth.oidc.scope = "${SCOPE}"
auth.oidc.tokenEndpointURL = "${TOKEN_URL}"

[[proxies]]
name = "${PROXY_NAME}"
type = "${PROXY_TYPE}"
localPort = ${LOCAL_PORT}
customDomains = ["${CUSTOM_DOMAIN}"]
EOL

cat $CONFIG_PATH

# 检查配置文件是否存在
if [ ! -f "${CONFIG_PATH}" ]; then
    bashio::log.error "Configuration file not found at ${CONFIG_PATH}"
    exit 1
fi

# 启动 frpc
bashio::log.info "Starting FRP Client with configuration at ${CONFIG_PATH}"
cd /usr/src
./frpc -c $CONFIG_PATH > "${LOG_FILE}" 2>&1 & WAIT_PIDS+=($!)

tail -f ${LOG_FILE} &

trap "stop_frpc_oidc" SIGTERM SIGHUP

wait "${WAIT_PIDS[@]}"
