

-- local etcdfile = "/niuniu/gates/gate1"

local root = {
   -- etcdfile = etcdfile,
    niuniu = {
       -- name = etcdfile,
        server = {
            ip_login = "192.168.103.91",
            port_login = 8203,
            body_size_limit_login = 8192, --8k限制 
        
            ip_websocket = "192.168.103.91",
            port_websocket = 8303,
            body_size_limit_websocket = 65536,
            
        },
        gateserver = {
          address = "127.0.0.1", -- 监听地址 127.0.0.1
          port = 8888,    -- 监听端口 8888
          maxclient = 1024,   -- 最多允许 1024 个外部连接同时建立
          nodelay = true,     -- 给外部连接设置  TCP_NODELAY 属性
        }
    }
}


return root