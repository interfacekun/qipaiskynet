local skynet = require "skynet"
local socket = require "skynet.socket"
--local httpd = require "http.httpd"
--local sockethelper = require "http.sockethelper"
--local urllib = require "http.url"



--[[
NetHttp.lua
 
  NetHttp 的上层分装处理 
  主要有：
      start
      send
      close
      exit
      
      on_message
--]]
local m_port,  m_body_size_limit,m_srv_net_work  = ...  -- NetWork服务类  端口   最大连接数


local root = {}

local listen_id = nil;--监听id
local SOCKET_NUMBER = 0 --socket连接数目



--构造函数 
function root.start(port, body_size_limit)
    m_port = port
   m_body_size_limit = body_size_limit
  
  skynet.start(function()
      local id = socket.listen("0.0.0.0", port)
      listen_id = id
      skynet.error("Listen web port ", port)
      socket.start(id , function(fd, addr)
            root.on_socket( fd, addr)
      end)
  end)
end



function root.exit()
    socket.close(listen_id)
end
















------------------------------- private  -----------
--local skynet = require "skynet"
local urllib = require "http.url"
local httpd = require "http.httpd"
local websocket = require "websocket"
local socket = require "skynet.socket"
local sockethelper = require "http.sockethelper"
function root.on_socket( fd, addr)
    SOCKET_NUMBER = SOCKET_NUMBER + 1
    socket.start(fd)
    
    -- limit request body size to 8192 (you can pass nil to unlimit)
    local code, url, method, header, body = httpd.read_request(sockethelper.readfunc(fd), tonumber(m_body_size_limit))
    if code then
        if code ~= 200 then
            local ok, err = httpd.write_response(sockethelper.writefunc(fd), code)
        else
            local path, query = urllib.parse(url)
            local q = {}
            if query then
                q = urllib.parse_query(query)
            end             
            
            local m = root.on_message(addr, url, method, header, path, q, body, fd)
            local ok, err = httpd.write_response(sockethelper.writefunc(fd), m)
        end
    else
        if url == sockethelper.socket_error then
            -- skynet.error("socket closed")
        else
            -- skynet.error(url)
        end
    end
    
    
    socket.close(fd)
    SOCKET_NUMBER = SOCKET_NUMBER - 1
end


--构造一个自定义的页面 
local function internal_server_error(code,req, res, errmsg)
    res.code = code or 500
    res.body = "<html><head><title>Internal Server Error</title></head><body><p>500 Internal Server Error</p></body></html>"
    res.headers["Content-Type"]="text/html"
    return res.code, res.body, res.headers
end




--处理http请求
function root.on_message(addr, url, method, headers, path, query, body, fd)
    local ip, _ = addr:match("([^:]+):?(%d*)$")
    local req = {ip = ip, url = url, method = method, headers = headers, 
            path = path, query = query, body = body, fd = fd, addr = addr}
    local res = {code = 200, body = body, headers = headers}


    local trace_err = ""
    local trace = function (e)
        trace_err  = e .. debug.traceback()
    end

  
    local method = req.method;
    local body =req.body;
    local addr = req.addr;
    local fd = req.fd;
    local ip =req.ip
    local url =req.url
    local path = req.path;
    print(" NetHttp.lua => method:"..method,",path:"..path,",addr:"..addr,",fd:"..fd,",ip:"..ip,",url:"..url);
    
    
    -- 解析命令  并转发给 NetWork 中转处理 
    local gameconstants = require "app.config.gameconstants";
    if path == gameconstants.NetHttp_ACTION_WS then --http 连接 
          local netwebsocket = require "app.server.netwebsocket"
          netwebsocket.start(m_srv_net_work,req, res);
     else
          skynet.call(m_srv_net_work, "lua", "command_http_handler",path,req, res, skynet.self())
    end
      
    
    return res.code, res.body, res.headers
end



root.start(m_port,  m_body_size_limit)

return root
