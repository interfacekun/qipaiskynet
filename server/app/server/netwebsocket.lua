local skynet = require "skynet"
--local proto = require "gate.frontend.proto"
--local app = require "gate.frontend.app"
local websocket = require "websocket"
--require ".util.function"

--local CMD = {}
local SOCKET_TO_CLIENT = {}
local m_NetWork

--[[
 NetWebSocket.lua
 
  websocket的上层分装处理 
  主要有：
      start
      send
      close
      exit
      
      on_message
--]]

local root = {}


local m_srv_net_work;


--[[
  启动webscoket 
  http升级协议成websocket协议
 --]]
function root.start(NetWork,req, res)
    print("NetWebSocket.lua start => ".. req.fd);
    m_srv_net_work = NetWork;
    
    local fd = req.fd 
    local ws, err  = websocket.new(req.fd, req.addr, req.headers, root)
    if not ws then
        res.body = err
        return false
    end
    ws:start()
    return true
end

--[[
  发送数据
  
  --   local data = "{\"cmd\":\"login\",\"ret\":0,\"status\":\"success\",\"data\":{\"id\":\"GIMXDpPzfJWFqL7XAAAA\",\"name\":\"001\",\"avatar\":\"http://img6.bdstatic.com/img/image/smallpic/touxiang1227.jpeg\",\"gender\":1}}"
--   root.send(fd, data);


  local data = {a ="sss",cmd = "login"};
      local cf = cjson_encode(data)
      root.send(fd,cf);
 --]]
function root.send(fd, data)
    local client = SOCKET_TO_CLIENT[fd]
    if not client then
        return
    end
    
    print("发送的数据包：");
    print(data);
    local ws = client.session.ws
    local ok, reason = ws:send_binary(data)
end


--[[
  关闭 
 --]]
function root.close(fd, reason)
    local client = SOCKET_TO_CLIENT[fd]
    SOCKET_TO_CLIENT[fd] = nil
    if not client then
        return
    end
end


--[[
  退出
 --]]
function root.exit()
    for k, v in pairs(SOCKET_TO_CLIENT) do 
    end
end








------------ private  ---------------
function root.on_open(ws)
    print("NetWebSocket.lua on_open");
    skynet.error(string.format("Client connected: %s", ws.addr))
    local fd = ws.fd
    local ip = ws.addr:match("([^:]+):?(%d*)$")
    local session = {ws = ws, fd = fd, agent = skynet.self(), addr = ws.addr, ip = ip}
    SOCKET_TO_CLIENT[fd] = {session = session}
    
end

function root.on_message(ws, msg)
    print("NetWebSocket.lua 接收到消息");
    print(msg);
    local fd = ws.fd
    local client =  SOCKET_TO_CLIENT[fd]
    if not client then
        return
    end
    
    
      local data = {a ="sss",cmd = "login"};
      local cf = cjson_encode(data)
      root.send(fd,cf);
      
      
      local network =  require "app.server.network";
      network.command_websocket_handler(msg)
     --skynet.call(m_srv_net_work, "lua", "command_websocket_handler",msg)
end

function root.on_error(ws, msg)
    local fd = ws.fd
    local client =  SOCKET_TO_CLIENT[fd]
    if not client then
        return
    end
 end

function root.on_close(ws, fd, code, reason)
    fd = fd or ws.fd
    local client =  SOCKET_TO_CLIENT[fd]
    if not client then
        return
    end
end 



return root
