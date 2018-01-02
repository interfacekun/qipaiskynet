local skynet = require "skynet"
local socket = require "skynet.socket"
local helper_net_http = require "app.servicehelper.helper_net_http"



local CMD = {}
local SOCKET_NUMBER = 0 --socket连接数目



-- 处理socket 收到的消息     
function CMD.on_socket( fd, addr)
    print("srv_net_http_agent.lua = > start (".. fd.."),SOCKET_NUMBER:"..SOCKET_NUMBER)

    SOCKET_NUMBER = SOCKET_NUMBER + 1
    socket.start(fd)
    
  
    
    
    helper_net_http.on_socket( fd, addr);
    
    
    
    
    socket.close(fd)
    SOCKET_NUMBER = SOCKET_NUMBER - 1
end







skynet.start(function() 
    skynet.dispatch("lua", function(session, _, command, ...)
        local f = CMD[command]
        if not f then
            if session ~= 0 then
                skynet.ret(skynet.pack(nil))
            end
            return
        end
        if session == 0 then
            return f(...)
        end
        skynet.ret(skynet.pack(f(...)))
    end)
end)
