local player = {}

function player:new(opt)
    local o = {
        uid = opt.uid,
        nickname = opt.nickname or "",
        diamond = opt.diamond or 0,
        score = opt.score or 0,
        online = true,
    }
    setmetatable(o, {__index = self})
    return o
end

function player:totable()
    return {
        uid = self.uid,
        nickname = self.nickname,
        diamond = self.diamond,
        score = self.score,
        online = self.online,
    }
end

function player:tostring( ... )
    return tostring(self:totable())
end

function player:reload(opt)
    self.uid = opt.uid
    self.nickname = opt.nickname
    self.diamond = opt.diamond
    self.score = opt.score
    self.online = false
end

return player