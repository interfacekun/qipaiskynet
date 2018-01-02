local skynet = require "skynet"
require "skynet.manager"
--local etcd = require "etcd"
--local hotfix = require "hotfix"
--local rpc_mysql = require "rpc_mysql"
--local rpc_redis = require "rpc_redis"
local cluster = require "skynet.cluster"
local gameconstants = require "app.config.gameconstants";
app =  require "app.app"



skynet.start(function ()
--    skynet.uniqueservice("srv_logger_sup")
--    skynet.newservice("debug_console", 8903)
--    if not skynet.getenv "daemon" then
--        local console = skynet.uniqueservice("console")
--    end

--    -- 启动登陆管理服务
--    local handle = skynet.uniqueservice("gate/service/srv_logon")
--    skynet.name(".logon", handle)
--
--    -- 启动语音服务
--    local handle = skynet.uniqueservice("gate/service/srv_voice")
--    skynet.name(".voice", handle)

    -- 获取配置环境
    local env = skynet.getenv("env")
    local config = require('config.' .. env .. ".server")
--    local backend_port = config.etcdcf.backend.port
    local port = config.etcdcf.server.port
    skynet.setenv("gate_etcd", config.etcdfile)
    app.new();



    -- 启动房间管理服务
--    local handle = hotfix.start_hotfix_service("skynet", "gate/service/srv_room_sup")
--    skynet.name(".room", handle)  

    -- 启动frontend, backend web服务

    --启动net的中转命令服务
    local srv_net_work = skynet.newservice("srv_net_work")
    cluster.register("srv_net_work", srv_net_work)
    
    --启动websocket
    local srv_net_http = skynet.newservice("srv_net_http", port,  65536,"agent",gameconstants.HANDLE_TYPE_WEBSOCKET)
    cluster.register("srv_net_http", srv_net_http)
    
    
    
--    hotfix.start_hotfix_service("skynet", "srv_web", backend_port, "gate.backend.webapp", 65536)
--    hotfix.start_hotfix_service("skynet", "srv_web", frontend_port, "gate.frontend.webapp", 65536 * 2)
    -- 启动socket服务
--    local maxclient = 30000
--    local socket = config.etcdcf.frontend.socket
--    local handle = hotfix.start_hotfix_service("skynet","srv_socket")
--    skynet.call(handle, "lua", "start", 
--        {
--            port = socket,
--            maxclient = maxclient,
--            nodelay = true,
--        },
--        "gate.frontend.app"
--    )

    -- 注册服务
--    local handle = hotfix.start_hotfix_service("skynetunique", "srv_register_agent")
--    skynet.call(handle, "lua", "set", config.etcdfile, config.etcdcf)

    skynet.exit()
end)