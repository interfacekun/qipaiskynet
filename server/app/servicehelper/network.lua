--[[
  network.lua

  连接服务器的中转触发类  

]]
local skynet = require "skynet"
local gameconstants = require "app.config.gameconstants";

local root = {}



 ----- 命令处理类 
local CMD = {}

-- 监听http 
function CMD.command_http_handler(path,req,res)
  local ret = nil
  local body =req.body;
  local cmd = body.cmd

  print("command_http_handler : ",action);
  if cmd == gameconstants.NetHttp_ACTION_WS then --http 连接 
        
  end
  return ret 
end













-- 监听 websocket 
function CMD.command_websocket_handler(cmd, action,...)
  print("command_websocket_handler : ",action);
  if action == "user_loginThird" then 
      
  end
end
-- 发送  websocket 
function CMD.command_websocket_send(fd, data)
     local netwebsocket = require "app.servicehelper.netwebsocket"
     netwebsocket.send(fd,data);
end




return root;