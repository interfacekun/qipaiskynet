
local logger = log4.get_logger(SERVICE_NAME)

local skynet = require "skynet"
local snax = require "skynet.snax"

local mode = ...


local all_service = {}               --所有的服务  {type, handle, service_name, register, {...}}
local reboot_service = {}            -- 可重启更新service, {type, handle, service_name, register, {...}}
local hotfix_service = {}            -- 不重启，通过热更新服务, {type, handle, service_name, register, {...}}





local function start_service(type, service_name, ...)
    local handle
    if type == "skynet" then
        handle = skynet.newservice(service_name, ...)
    elseif type == "snax" then
        handle = snax.newservice(service_name, ...)
    elseif type == "snaxunique" then
        handle = snax.uniqueservice(service_name, ...)
    elseif type == "skynetunique" then
        handle = skynet.uniqueservice(service_name, ...)
    end
    
    --存储所有
    --all_service[#all_service+1] = 
    table.insert(all_service, {type, handle, service_name, {...}})
    
    return handle
end




local CMD = {}



function CMD.info()
end
function CMD.exit() 
end




function CMD.start_hotfix_service(_type, service_name, ...)
    local handle = start_service(_type, service_name, ...)
    if not handle then
        return
    end
    table.insert(hotfix_service, {_type, handle, service_name, {...}})

    if type(handle) ~= "number" then
        return handle.handle
    end
    return handle
end

function CMD.start_reboot_service(_type, service_name, ...)
    local handle = start_service(_type, service_name, ...)
    if not handle then
        return
    end
    table.insert(reboot_service, {_type, handle, service_name,  {...}})
    if type(handle) ~= "number" then
        return handle.handle
    end
    return handle
end



--获取指定服务列表
function CMD.getServer(servername)
    return all_service[servername]
end




if mode == "master" then
    skynet.start(function ()
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
else
    local args = {...}
    skynet.start(function()
        local handle = skynet.uniqueservice("srv_center", "master")
        skynet.call(handle, "lua", table.unpack(args))
        skynet.exit()
    end)
end