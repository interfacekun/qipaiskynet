local skynet = require "skynet"
require "skynet.manager"
--local etcd = require "etcd"
--local hotfix = require "hotfix"
--local rpc_mysql = require "rpc_mysql"
--local rpc_redis = require "rpc_redis"
local cluster = require "skynet.cluster"
local gameconstants = require "app.config.gameconstants";
app =  require "app.app"

local center = require "center"



skynet.start(function ()
    skynet.uniqueservice("srv_logger")
    skynet.newservice("debug_console", 8903)
    if not skynet.getenv "daemon" then
        local console = skynet.uniqueservice("console")
    end


--    -- 启动语音服务
--    local handle = skynet.uniqueservice("gate/service/srv_voice")
--    skynet.name(".voice", handle)

    -- 获取配置环境
    local env = skynet.getenv("env")
    local config_server = require('config.' .. env .. ".config_server")
    local config_mysql = require('config.' .. env .. ".config_mysql")
--    local backend_port = config.etcdcf.backend.port
    -- print(config.etcd);
    -- skynet.setenv("gate_etcd", config.etcd)
    app.new();


    --根据不同游戏加载不同的proto
    local srv_protoloader = center.start_hotfix_service("skynet", "srv_protoloader")
    --skynet.uniqueservice("srv_protoloader",nil) 


     --启动mysql 服务 
    --local srv_mysql = skynet.newservice("srv_mysql")
    local srv_mysql = center.start_hotfix_service("skynet", "srv_mysql")
    cluster.register("srv_mysql", srv_mysql)
    skynet.call(".mysql", "lua", "init", "login", config_mysql["login"]) 


    
    --启动负载均衡的登录服务
    local port_login = config_server.game_100.server.port_login
    local body_size_limit_login = config_server.game_100.server.body_size_limit_login
    --local srv_net_http_login = skynet.newservice("srv_net_http", port_login,  body_size_limit_login,"agent")
    --cluster.register("srv_net_http_login", srv_net_http_login)
    local srv_net_http_login = center.start_reboot_service("skynet", "srv_net_http", port_login,  body_size_limit_login,"agent")
    
    
    
    --启动websocket服务
    local port_websocket = config_server.game_100.server.port_websocket    
    local body_size_limit_websocket = config_server.game_100.server.body_size_limit_websocket
    --local srv_net_http_websocket = skynet.newservice("srv_net_websocket", port_websocket,  body_size_limit_websocket)
    --cluster.register("srv_net_http_websocket", srv_net_http_websocket)
    local srv_net_http_websocket = center.start_reboot_service("skynet", "srv_net_websocket", port_websocket,  body_size_limit_websocket)
    
    
    
    --启动gate socket 服务 
    --local srv_net_gate = skynet.newservice("srv_net_gate")
    --cluster.register("srv_net_gate", srv_net_gate)
    local srv_net_gate = center.start_reboot_service("skynet", "srv_net_gate")
    --调用start方法 
    local gateserver = config_server.game_100.gateserver    
    skynet.call(srv_net_gate, "lua", "start",gateserver )
    

    skynet.exit()
end)