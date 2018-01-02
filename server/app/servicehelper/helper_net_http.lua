local skynet = require "skynet"
--local socket = require "skynet.socket"
--local httpd = require "http.httpd"
--local sockethelper = require "http.sockethelper"
--local urllib = require "http.url"
local gameconstants = require "app.config.gameconstants";
local network =  require "app.servicehelper.network";
    

local  m_body_size_limit , m_handle_type,m_srv_net_work ; 



local root = {}


--吧基础的数据丢进来 
function root.init( body_size_limit,handle_type)
   m_body_size_limit = body_size_limit
   m_handle_type = handle_type;
end



------------------------------- private  -----------
--local skynet = require "skynet"
local urllib = require "http.url"
local httpd = require "http.httpd"
local sockethelper = require "http.sockethelper"
function root.on_socket( fd, addr)
   
    -- limit request body size to 8192 (you can pass nil to unlimit)
    -- 一般的业务不需要处理大量上行数据，为了防止攻击，做了一个 8K 限制。这个限制可以去掉。
    local code, url, method, header, body = httpd.read_request(sockethelper.readfunc(fd), tonumber(m_body_size_limit))
    if code then
        if code ~= 200 then
            local ok, err = httpd.write_response(sockethelper.writefunc(fd), code)
            --httpd.write_response(sockethelper.writefunc(fd), code, result)
        else
            local path, query = urllib.parse(url)
            local q = {}
            if query then
                q = urllib.parse_query(query)
            end             
            
            local newcode, newbody, newheaders,newjson = root.on_message(addr, url, method, header, path, q, body, fd)
            local ok, err = httpd.write_response(sockethelper.writefunc(fd), newcode,newjson)
--            local ok, err = httpd.write_response(sockethelper.writefunc(fd), code,res,
--              {["Access-Control-Allow-Credentials"]=true,
--              ["Access-Control-Allow-Headers"]={"Authorization","Content-Type","Accept","Origin","User-Agent","DNT","Cache-Control","X-Mx-ReqToken"},
--              ["Access-Control-Allow-Methods"]={"GET","POST","OPTIONS","PUT","DELETE"},["Access-Control-Allow-Origin"]="*"})
                
        end
    else
        if url == sockethelper.socket_error then
            skynet.error("socket closed")
        else
            skynet.error(url)
        end
    end
    
    
    
end


----构造一个自定义的页面 
--local function internal_server_error(code,req, res, errmsg)
--    res.code = code or 500
--    res.body = "<html><head><title>Internal Server Error</title></head><body><p>500 Internal Server Error</p></body></html>"
--    res.headers["Content-Type"]="text/html"
--    return res.code, res.body, res.headers
--end




--处理http请求
function root.on_message(addr, url, method, headers, path, query, body, fd)
    local ip, _ = addr:match("([^:]+):?(%d*)$")
    local req = {ip = ip, url = url, method = method, headers = headers, 
            path = path, query = query, body = body, fd = fd, addr = addr}
    local res = {code = 200, body = body, headers = headers,json =nil}


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
    print(" helper_net_http.lua => method:"..method,",path:"..path,",addr:"..addr,",fd:"..fd,",ip:"..ip,",url:"..url);
    
    
   
    
    --转发消息 
    if tonumber(m_handle_type) == gameconstants.HANDLE_TYPE_HTTTP then 
       res.json = network.command_http_handler(path,req,req,res)
        --skynet.call(m_srv_net_work, "lua", "command_http_handler",path,req, res, skynet.self())
        
    elseif tonumber(m_handle_type) == gameconstants.HANDLE_TYPE_WEBSOCKET then
    
        if path == gameconstants.NetHttp_ACTION_WS then --http 连接 
              local netwebsocket = require "app.servicehelper.netwebsocket"
              netwebsocket.start(m_srv_net_work,req, res);
         else
              network.command_http_handler(path,req,req,res)
              --skynet.call(m_srv_net_work, "lua", "command_http_handler",path,req, res, skynet.self())
        end
            
    end
    
    return res.code, res.body, res.headers,res.json
end




return root
