local skynet = require "skynet"
-- require "luaext"
require "print_r"
require "utils.utils"
require "class"
require "utils.function"
html_utils = require "utils.html_utils"

local logpath = skynet.getenv("logpath")
local logmode = skynet.getenv("logmode")

log4 = require "log4"
local env = skynet.getenv("env")
local configure = require('config.' .. env .. ".log4")

log4.configure(configure)
IS_DEBUG = logmode == "DEBUG"
IS_API_DEV = skynet.getenv("api_env")           -- 是否为测试API
IS_API_DEV = IS_API_DEV == "true"





--获取所有命令 
all_game_command = require "proto.all_game_command"
all_game_command.init();
