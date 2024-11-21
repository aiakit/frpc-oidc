#!/usr/bin/with-contenv bashio
set -e

# 定义配置文件路径
CONFIG_PATH=/data/frpc.toml
APP_PATH="/usr/src"

# 显示欢迎信息
bashio::log.info "Starting FRP Client..."

# 检查 frpc 是否存在
if [ ! -f "${APP_PATH}/frpc" ]; then
    bashio::log.error "FRP Client binary not found at ${APP_PATH}/frpc"
    exit 1
fi

# 确保二进制文件可执行
chmod +x "${APP_PATH}/frpc"

# 从 Home Assistant 配置中获取值
SERVER_ADDR=$(bashio::config 'server_addr')
SERVER_PORT=$(bashio::config 'server_port')
CLIENT_ID=$(bashio::config 'auth.oidc.client_id')
CLIENT_SECRET=$(bashio::config 'auth.oidc.client_secret')
AUDIENCE=$(bashio::config 'auth.oidc.audience')
SCOPE=$(bashio::config 'auth.oidc.scope')
TOKEN_URL=$(bashio::config 'auth.oidc.token_endpoint_url')

# 获取代理配置
PROXY_TYPE=$(bashio::config 'proxies[0].type')
LOCAL_PORT=$(bashio::config 'proxies[0].local_port')
CUSTOM_DOMAIN=$(bashio::config 'proxies[0].custom_domains[0]')

bashio::log.info "Creating FRP Client configuration..."

# 创建 TOML 配置文件
cat > "${CONFIG_PATH}" << EOL
serverAddr = "${SERVER_ADDR}"
serverPort = ${SERVER_PORT}

auth.method = "oidc"
auth.oidc.clientID = "${CLIENT_ID}"
auth.oidc.clientSecret = "${CLIENT_SECRET}"
auth.oidc.audience = "${AUDIENCE}"
auth.oidc.scope = "${SCOPE}"
auth.oidc.tokenEndpointURL = "${TOKEN_URL}"

[[proxies]]
name = "${CLIENT_ID}"
type = "${PROXY_TYPE}"
localPort = ${LOCAL_PORT}
customDomains = ["${CUSTOM_DOMAIN}"]
EOL

# 显示配置信息（隐藏敏感信息）
bashio::log.info "Configuration created with following settings:"
bashio::log.info "Server: ${SERVER_ADDR}:${SERVER_PORT}"
bashio::log.info "Proxy Name: ${PROXY_NAME}"
bashio::log.info "Local Port: ${LOCAL_PORT}"
bashio::log.info "Custom Domain: ${CUSTOM_DOMAIN}"

# 检查配置文件是否存在
if [ ! -f "${CONFIG_PATH}" ]; then
    bashio::log.error "Configuration file not found at ${CONFIG_PATH}"
    exit 1
fi

# 启动 frpc
bashio::log.info "Starting FRP Client with configuration at ${CONFIG_PATH}"

# 监控循环
while true; do
    if "${APP_PATH}/frpc" -c "${CONFIG_PATH}"; then
        bashio::log.warning "FRP Client exited, restarting in 10 seconds..."
    else
        bashio::log.error "FRP Client failed, restarting in 10 seconds..."
    fi
    sleep 10
done
