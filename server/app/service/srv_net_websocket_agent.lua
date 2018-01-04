local skynet = require "skynet"
local netpack = require "skynet.netpack"
local socket = require "skynet.socket"
local sproto = require "sproto"
local sprotoloader = require "sprotoloader"

--[[
  srv_net_websocket_agent.lua

  websocket 的网络处理  
]]

local WATCHDOG;
local m_client





--发送消息处理 
local function send_package(pack)
	local package = string.pack(">s2", pack)
	--socket.write(client_fd, package)
	
	 local ws = m_client.ws
   local ok, reason = ws:send_binary(package)
end
local function close(code, reason)
   local ws = m_client.ws
   ws:close(code, reason)
end






local CMD = {}
local host
local send_request
--[[
ws = ws,client = fd, watchdog = skynet.self(),addr = ws.addr, ip = ip
]]
function CMD.start(conf)
  
	local fd = conf.client
--	local gate = conf.gate
	WATCHDOG = conf.watchdog
	-- slot 1,2 set at main.lua
	host = sprotoloader.load(1):host "package"
	send_request = host:attach(sprotoloader.load(2))
	
	skynet.fork(function()
		while true do
			send_package(send_request "heartbeat")
			skynet.sleep(500)
		end
	end)

	--client_fd = fd
	m_client = conf;
end

function CMD.disconnect()
  close();
	-- todo: do something before exit
	skynet.exit()
end

function CMD.send(fd, data)
    print("发送的数据包：");
    print(data);
   send_package(data);
end
--收到消息处理  
function CMD.on_message(msg)
  
end


    







skynet.start(function()
	skynet.dispatch("lua", function(_,_, command, ...)
		local f = CMD[command]
		skynet.ret(skynet.pack(f(...)))
	end)
end)
