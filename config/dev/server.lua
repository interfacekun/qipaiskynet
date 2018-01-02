

local etcdfile = "/niuniu/gates/gate1"

local root = {
    etcdfile = etcdfile,
    etcdcf = {
        name = etcdfile,
        server = {
            ip = "192.168.103.91",
            type = "http",
            ws = "ws://192.168.103.91:8203/ws",
            socket = 8203,
            port = 8203,
        },
    }
}


return root