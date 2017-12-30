

local etcdfile = "/niuniu/gates/gate1"

local root = {
    etcdfile = etcdfile,
    etcdcf = {
        name = etcdfile,
        server = {
            ip = "192.168.31.249",
            type = "http",
            ws = "ws://192.168.31.249:8203/ws",
            socket = 8303,
            port = 8203,
        },
    }
}


return root