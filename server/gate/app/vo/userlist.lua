

local User ={
  userid = nil;
  session =nil,--连接的session 

}






require "gate.frontend.util.function";
local UserList ={}
local users ={};

UserList.getUserbyUserid = function()
    local u = clone(User);
    return u;
end

UserList.setUserbyUserid = function(userid)
    if UserList.getUserbyUserid (userid) == nil then 
        local u = clone(User);
        users[userid] =  u;
    end
end


return UserList