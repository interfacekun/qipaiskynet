

--local etcdfile = "/niuniu/gates/gate1"

local root = {
--    etcdfile = etcdfile,
    niuniu = {
--        name = etcdfile,
        server = {
            ip_login = "192.168.103.91",
            port_login = 8203,
            body_size_limit_login = 8192, --8k限制 
            
        
            ip_websocket = "192.168.103.91",
            port_websocket = 8303,
            body_size_limit_websocket = 65536,
            
        },
    }
}


return root