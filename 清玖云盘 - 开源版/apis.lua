require "import"
import"java.io.File"

rdata = require"func.data"


-- local domain = "https://demo.cloudreve.org"
local domain = "https://cloud.qingstore.cn"


function toGetdata(t)
  local data = {}
  for k,v in pairs(t) do
    table.insert(data,k.."="..tostring(v))
  end
  return table.concat(data,"&")
end

--[[ 获得路径下的内容
--  参数: 路径名称, 回调
--]]
function getDir(path, fun_c)
  local url = domain.."/api/v3/directory"..(path and rdata.uencode(path) or "/")
  local cookie = rdata.getData("user_cookie")
  Http.get(url, cookie, function(code, body)
    if code~=-1 and code>=200 and code<=400 then
      body = rdata.jdecode(body)
    end
    fun_c(code, body)
  end)
end

--[[ 获取简略内存
--   参数: 回调
--]]
function briefStorage(fun_c)
  local url = domain.."/api/v3/user/storage"
  local cookie = rdata.getData("user_cookie")
  Http.get(url, cookie, function(code, body)
    if code~=-1 and code>=200 and code<=400 then
      body = rdata.jdecode(body)
    end
    fun_c(code, body)
  end)
end

--[[ 获得上传策略
--   参数: 回调
inpath 自动获取
  path=%2F        (不填默认/)
  &size=37289999
  &name=bmob.lua
  &type=onedrive (默认onedrive"
--]]
function getUploadmod(arr_info,fun_c)
  arr_info.type = arr_info.type or "onedrive"
  arr_info.path = arr_info.path or "/"
  -- arr_info.path = arr_info.path == "" or "/"

  if arr_info.inpath then
    local file = File(arr_info.inpath)
    arr_info.inpath = nil
    arr_info.size = file.length()
    arr_info.name = file.getName()
  end

  local url = domain.."/api/v3/file/upload/credential?%s"
  local cookie = rdata.getData("user_cookie")
  Http.get( string.format(url,toGetdata(arr_info) ), cookie, function(code, body)
    if code~=-1 and code>=200 and code<=400 then
      body = rdata.jdecode(body)
    end
    fun_c(code, body)
  end)
end

--[[
getUploadmod({
  inpath = "/sdcard/test/bigfile.txt",
  path = "/"
},function(code,body)
  print(dump(body))
end)
--]]



--[[ 获得下载链接(已登录的)
--   参数: 文件id,回调
--]]
function getDownurl(str_fileid, fun_c)
  local url = domain.."/api/v3/file/download/"..str_fileid
  local head = {
    ["cookie"] = rdata.getData("user_cookie")}
  Http.put(url, "",head , function(code, body)
    if code~=-1 and code>=200 and code<=400 then
      body = rdata.jdecode(body)
    end
    fun_c(code, body)
  end)
end



--[[ 登录
--   参数: 账号, 密码, 回调
--]]
function login(username, password, fun_c)
  local url = domain.."/api/v3/user/session"
  local datas = {
    ["userName"] = username,
    ["Password"] = password,
    ["captchaCode"] = ""
  }
  Http.post(url, rdata.body_post(datas), function(code, body, cookie)
    if code~=-1 and code>=200 and code<=400 then
      body = rdata.jdecode(body)
    end
    fun_c(code, body)
  end)
end

--[[ 退出登录
--   参数: 回调
--]]
function logout(fun_c)
  local url = domain.."/api/v3/user/session"
  local cookie = rdata.getData("user_cookie")
  Http.delete(url, cookie, function(code, body, cookie)
    if code~=-1 and code>=200 and code<=400 then
      body = rdata.jdecode(body)
    end
    fun_c(code, body)
  end)
end


--[[ 获取我的分享
--   参数:页码, 查询方式(参见下), 排序(参见下), 回调
created_at 创建日期
DESC 最新到最旧
ASC  最旧到最新


downloads 下载次数
DESC 多到少
ASC 少到多

views 浏览次数
DESC 多到少
ASC 少到多
--]]
function getMyshare(void_page, str_other, str_sort, fun_c)
  local data = toGetdata({
    ["page"] = void_page or "1",
    ["order_by"] = str_orther or "created_at",
    ["order"] = str_sort or "DESC"
  })
  local url = domain.."/api/v3/share?"..data
  local cookie = rdata.getData("user_cookie")
  Http.get(url, cookie, function(code, body)
    if code~=-1 and code>=200 and code<=400 then
      body = rdata.jdecode(body)
    end
    fun_c(code, body)
  end)
end



--[[ 删除文件
--   参数: 文件列表[id]/文件夹列表[id]
--]]
function deleteFile(arr , fun_c)
  local data = "{"..
  [["items":]] .. string.format("[\"%s\"]",table.concat(arr.file or {}, "\",\""))..","..
  [["dirs":]] .. string.format("[\"%s\"]",table.concat(arr.dir or {}, "\",\"")).."}"
  local url = domain.."/api/v3/object"
  local cookie = rdata.getData("user_cookie")
  local cbk = function(code, body)
    if code~=-1 and code>=200 and code<=400 then
      body = rdata.jdecode(body)
    end
    fun_c(code, body)
  end
  local httpTask = Http.HttpTask(url, "DELETE", cookie, nil, nil, cbk);
  httpTask.execute{data}
end



-- [[ 新建文件
--    参数:目录
--]]
function newFile(path,fun_c)
  local url = domain.."/api/v3/file/create"
  local cookie = rdata.getData("user_cookie")
  local datas = {
    ["path"] = path}
  Http.post(url, rdata.body_post(datas), cookie, function(code, body, cookie)
    if code~=-1 and code>=200 and code<=400 then
      body = rdata.jdecode(body)
    end
    if fun_c then
      fun_c(code, body)
    end
  end)
end


--[[ 新建文件夹
--   参数:目录
--]]
function newFolder(path,fun_c)
  local url = domain.."/api/v3/directory"
  local datas = {
    ["path"] = path}
  local head = {
    ["cookie"] = rdata.getData("user_cookie")}
  Http.put(url, rdata.jencode(datas) ,head , function(code, body)
    if code~=-1 and code>=200 and code<=400 then
      body = rdata.jdecode(body)
    end
    if fun_c then
      fun_c(code, body)
    end
  end)
end

--[[ 小文件上传
   参数 arr_info:
         inpath 必填 文件路径
         path   上传路径 默认/
         name   文件名称 选填
--]]
function littleUpload(arr_info, fun_c)
  local file = File(arr_info.inpath)
  --arr_info.size = file.length()
  arr_info.name = file.getName()

  local head = {
    ["X-Path"] = arr_info.path or "/",
    ["X-FileName"] = arr_info.name
  }
  local body = io.open(arr_info.inpath):read("*a")
  local cookie = rdata.getData("user_cookie")
  local url = domain.."/api/v3/file/upload"
  local cbk = function(code, body)
    if code~=-1 and code>=200 and code<=400 then
      body = rdata.jdecode(body)
    end
    if fun_c then
      fun_c(code, body)
    end
  end

  local httpTask = Http.HttpTask(url, "POST", cookie, nil, head, cbk);
  httpTask.execute{file}
end




--[[
&name=    -- 文件名
&chunk=   -- 当前块 从0起
&chunks=  -- 总块
--]]
function blockUpload(arr_info, fun_c)
  local head = arr_info.head
  local file = File(tostring(arr_info.path))
  local url = arr_info.url
  local cbk = function(code, body)
    if code~=-1 and code>=200 and code<=400 then
      body2 = rdata.jdecode(body)
    end
    if fun_c then
      fun_c(code, body2, body)
    end
  end

  local httpTask = Http.HttpTask(url, "PUT", nil, nil, head, cbk);
  httpTask.execute{file}
end


--[[ 上传完毕 
     参数 data.token bodydata callback
--]]
function okUpload(url, data, fun_c)
  local cookie = rdata.getData("user_cookie")
  Http.post(url, data, cookie,
  function(code, body)
    if code~=-1 and code>=200 and code<=400 then
      body = rdata.jdecode(body)
    end
    if fun_c then
      fun_c(code, body)
    end
  end)
end

--[[ 新建文件
--    参数:目录
--]]
function renameFile(arr, fun_c)
  local url = domain.."/api/v3/object/rename"
  local cookie = rdata.getData("user_cookie")
  local datas = rdata.body_post({
    ["action"] = "rename",
    ["src"] = {
      ["dirs"] = {arr.dir or "==="},
      ["items"] = {arr.file or "==="},
    },
    ["new_name"] = arr.name
  })
  Http.post(url, datas:gsub([["==="]],"") , cookie, function(code, body, cookie)
    if code~=-1 and code>=200 and code<=400 then
      body = rdata.jdecode(body)
    end
    if fun_c then
      fun_c(code, body)
    end
  end)
end

--[[ 分享文件
--    参数:table 回调
table:
id ： 文件夹id string
dir ： 是否文件夹 boolean
password ： 密码 string 留空为无
endtime ： 到期时间 number s
score ： 积分 number
downs ： 限制下载  -1为不限
canview ： 可预览   boolean
--]]
function shareFile(arr, fun_c)
  local url = domain.."/api/v3/share"
  local cookie = rdata.getData("user_cookie")
  local datas = rdata.body_post(arr)
  --[[{
    ["id"] = arr.id, -- 文件id
    ["is_dir"] = arr.dir, -- 是否文件夹
    ["password"] = arr.password, -- 密码
    ["downloads"] = arr.downs, -- 下载次数限制
    ["expire"] = arr.time, -- 到期时间
    ["score"] = arr.score, -- 下载积分
    ["preview"] = arr.canview -- 可否预览
  })]]
  Http.post(url, datas, cookie, function(code, body, cookie)
    if code~=-1 and code>=200 and code<=400 then
      body = rdata.jdecode(body)
    end
    if fun_c then
      fun_c(code, body)
    end
  end)
end
