--[[
srv_net_websocket.lua 

 类似 WATCHDOG

 服务器websocket 网关  

]]

local skynet = require "skynet"
local websocket = require "websocket"
local socket = require "skynet.socket"
local helper_net_http = require "app.servicehelper.helper_net_http"
local gameconstants = require "app.config.gameconstants";


--local gate --网关  只有一个 
local m_agent = {} --用户句柄 数组






--关闭网关  
local function close_agent(fd)
  local a = m_agent[fd]
  m_agent[fd] = nil
  if a then
--    skynet.call(a, "lua", "kick", fd)
    -- disconnect never return
    skynet.send(a, "lua", "disconnect")
  end
end





--------------------------- private  start ------------------------------
local root = {};
function root.on_open(ws)
    print("netwebsocket.lua = > on_open (".. ws.fd ..")");
    skynet.error(string.format("Client connected: %s", ws.addr))
    local fd = ws.fd
    local ip = ws.addr:match("([^:]+):?(%d*)$")
--    local session = {ws = ws, fd = fd, agent = skynet.self(), addr = ws.addr, ip = ip}
--    SOCKET_TO_CLIENT[fd] = {session = session}
    
    m_agent[fd] = skynet.newservice("srv_net_websocket_agent")
    skynet.call(m_agent[fd], "lua", "start", {ws = ws,client = fd, watchdog = skynet.self(),addr = ws.addr, ip = ip })
end
function root.on_message(ws, msg)
    print("netwebsocket.lua = > on_message (".. ws.fd ..")");
    print(msg);
    local fd = ws.fd
    
    local a = m_agent[fd]
    if a then
        skynet.call(a, "lua", "on_message",msg)
    end
    
      -- local data = {a ="sss",cmd = "login"};
      -- local cf = cjson_encode(data)
      -- root.send(fd,cf);
      
      
      --local network =  require "app.servicehelper.network";
      --network.command_websocket_handler(msg)
--      skynet.call(m_srv_net_work, "lua", "command_websocket_handler",msg)
end

function root.on_error(ws, msg)
    print("netwebsocket.lua = > on_error (".. ws.fd..")");
    print(msg);
    local fd = ws.fd
    
    close_agent(fd)
 end

function root.on_close(ws, fd, code, reason)
    print("netwebsocket.lua = > on_close (".. fd ..")");
    fd = fd or ws.fd
    
    close_agent(fd)
end 

--------------------------- private  end ------------------------------













--------------------------- cmd  start ------------------------------
local CMD = {};
--[[
  启动webscoket 
  http升级协议成websocket协议
 --]]
function CMD.start(req, res)
     print("netwebsocket.lua = > start (".. req.fd..")");
    
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
function CMD.send(fd, data)
   local a = m_agent[fd]
    if a then
        skynet.call(a, "lua", "send",fd,data)
    end
end
--end
--[[
  关闭 
 --]]
function CMD.close(fd, reason)
     close_agent(fd)
end











 ------------------------------------- skynet start ----------------------------------------------------

local m_port,  m_body_size_limit = ...  --   端口   最大连接数
local listen_id = nil;--监听id
local SOCKET_NUMBER = 0 --socket连接数目

skynet.start(function()
  -- If you want to fork a work thread , you MUST do it in CMD.login
  skynet.dispatch("lua", function(session, source, command, ...)
    local f = assert(CMD[command])
    skynet.ret(skynet.pack(f(source, ...)))
  end)
  
  
    --启动websocket
   helper_net_http.init( m_body_size_limit,gameconstants.HANDLE_TYPE_WEBSOCKET,skynet.self());
   local id = socket.listen("0.0.0.0", m_port)
    -- local id = socket.listen("127.0.0.1",port)
    listen_id = id
    skynet.error("Listen web port ", m_port)
    socket.start(id , function(fd, addr)
          SOCKET_NUMBER = SOCKET_NUMBER + 1
          socket.start(fd)
          
          helper_net_http.on_socket( fd, addr);
          
          socket.close(fd)
          SOCKET_NUMBER = SOCKET_NUMBER - 1
    end)
end)
