--[[
  NetWork.lua

  连接服务器的中转触发类  

]]
local skynet = require "skynet"
local gameconstants = require "app.config.gameconstants";

local root = {}



 ----- 命令处理类 
local CMD = {}

-- 监听http 
function CMD.command_http_handler(cmd, action,req,res)
  print("command_http_handler : ",action);
  if action == gameconstants.NetHttp_ACTION_WS then --http 连接 
        
  end
end


-- 监听 websocket 
function CMD.command_websocket_handler(cmd, action,...)
  print("command_websocket_handler : ",action);
  if action == "user_loginThird" then 
      
  end
end






--------------- private -------------------
root.new = function()
  skynet.start(function()
    -- If you want to fork a work thread , you MUST do it in CMD.login
    skynet.dispatch("lua", function(session, source, command, ...)
      local f = assert(CMD[command])
      skynet.ret(skynet.pack(f(source, ...)))
    end)
  
    --[[
    skynet.dispatch("client", function(_,_, msg)
      -- the simple echo service
      skynet.sleep(10)  -- sleep a while
      skynet.ret(msg)
    end)
    ]]
  end)

end





root.new();
return root;