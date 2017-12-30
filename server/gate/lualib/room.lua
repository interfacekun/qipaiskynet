local skynet = require "skynet"
local code = require "baccarat-config.proto.code"
local gate_player = require "gate.lualib.player"
local logger = log4.get_logger("room")
local room = {}

function room:new(opt)
    local o = {
        roomuid = opt.roomuid,              -- 房主uid
        rid = opt.rid,                      -- 房间id
        createtime = opt.createtime,        -- 创建时间
        status = "wait",                    -- 房间状态
        -- TODO：init 房间信息
        player_list = {},
        uid_to_session = {},                -- 用户session
    }

    setmetatable(o, {__index = self})
    return o
end

function room:totable()
    local o =  {
        roomuid = self.roomuid,
        rid = self.rid,
        createtime = self.createtime,
        player_list = {}
    }
    for _, v in ipairs(self.player_list) do 
        table.insert(o.player_list, v:totable())
    end
    return o
end

function room:tostring()
    return tostring(self:totable())
end

function room:reload(opt)
    self.roomuid = opt.roomuid
    self.rid = opt.rid
    self.createtime = opt.createtime
    self.uid_to_session = {}
    self.player_list = {}
    for _, v in ipairs(opt.player_list) do 
        local p = gate_player:new(v.uid)
        p:reload(v)
        table.insert(self.player_list, p)
    end
end


function room:push_message(uid, name, msg)
    logger.debug("uid %s push_message %s", uid, name)
    local session = self.uid_to_session[uid]
    if not session then
        logger.debug("push_message %s %s not session uid_to_session %s", uid, name, tostring(self.uid_to_session))
        return
    end
    local agent = session.agent
    local fd = session.fd
    -- srv_room => srv_web_agent => wsapp CMD.emit => app proto s2c
    skynet.send(session.agent, "lua", "emit", fd, "s2c", name, msg)
end

function room:broadcast(name, msg)
    logger.debug("%s broadcast", name)
    for uid, _ in pairs(self.uid_to_session) do 
        self:push_message(uid, name, msg)
    end
end

function room:get_player(uid)
    return table.key_find(self.player_list, "uid", uid)
end

-- app proto c2s => srv_room c2s => room object method
function room:room_enter(session, msg)
    local uid = session.uid
    if not self.uid_to_session[uid] then
        self.uid_to_session[uid] = session
        local p = self:get_player(uid)
        if not p then
            local p = gate_player:new({uid = uid})
            table.insert(self.player_list, p)
            self:broadcast("on_room_enter", { player = p:totable()})
        else
            p.online = true
        end
    end
    local player_list = {}
    for _, v in ipairs(self.player_list) do 
        table.insert(player_list, v:totable())
    end
    return {code = code.OK, player_list = player_list}
end

function room:room_leave(session, msg)
    self:broadcast("on_room_leave", {uid = session.uid})
    self.uid_to_session[session.uid] = nil
    local p = self:get_player(session.uid)
    if p then
        table.delete(self.player_list, p)
        skynet.send(".room", "lua", "leave", session.uid)
    end
    return {code = code.OK}
end

function room:room_offline(session)
    local uid = session.uid
    self.uid_to_session[uid] = nil
    local p = self:get_player(uid)
    if p then
        p.online = false
        self:broadcast("on_room_offline", {uid = uid})
    end
    return {code = code.OK}
end

function room:room_voice(session, msg)
    self:broadcast("on_room_voice", msg)
    return {code = code.OK}
end

function room:close()
    skynet.send(".room", "lua", "close", self.rid)
end

return room