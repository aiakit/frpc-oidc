# frpc oidc
一个基于 frp ,使用oidc做身份认证的安全的内网穿透客户端配置项目，可帮助您将homeassistant的本地服务暴露到互联网。阅读有关该项目的更多信息： https： //github.com/fatedier/frp

## 项目简介
本项目用于配置和管理 frpc（frp 客户端），帮助用户实现内网穿透功能.

## 主要功能
- 提供简单的 frpc 客户端配置
- 支持内网服务的远程访问
- 便捷的连接管理

## 使用说明
1. 安装配置
- 你需要选择三方云端的token认证服务，或者自己开发一个token服务。推荐使用 https://github.com/liangrunze/OidcAuthServer

2. 基本使用
- 根据frp提供的配置文件说明，配置即可使用。参考地址：https://gofrp.org/zh-cn/docs/features/common/authentication/

3. 配置文件说明
> 
serverAddr = "远程服务器ip"
serverPort = 7000

auth.method = "oidc"
auth.oidc.clientID = "用户client_id"
auth.oidc.clientSecret = "用户client_secret"
auth.oidc.audience = ""
auth.oidc.scope = "rw"
auth.oidc.tokenEndpointURL = ""

[[proxies]]
name = "clientID"
type = "http"
localPort = 8123
customDomains = ["xxx.host.com"]

## 贡献指南
欢迎提交 Issue 和 Pull Request
