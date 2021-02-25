local _M = {}

local json = require"cjson"
local URLEncoder = luajava.bindClass"java.net.URLEncoder"
local Formatter = luajava.bindClass"android.text.format.Formatter"

function _M.uencode(str)
  return URLEncoder.encode(str)
end

function _M.getData(name)
  local data = activity.getSharedData(name)
  if data == "true" or data == "false" then
    return Boolean.valueOf(data)
  end
  if data == "nil" or data == nil then
    return nil
  end
  local data_fun,data_err = load("return "..data,"bt")
  if not data_err and tostring(data):find("^%{") then
    local c_data = data_fun()
    if c_data and type(c_data) == "table" then
      return c_data
    end
  end
  return data
end

function _M.setData(name,str)
  if type(str) == "table" then
    str = dump(str)
  end
  return activity.setSharedData(name,str)
end

-- Table / String
function _M.addData(name, ...)
  local data = _M.getData(name)
  local arr = {...}
  if type(data) == "table" then
    for k,v in ipairs(arr) do
      data[#data+1] = v
    end

   else
    data = data..table.concat(arr)
  end
  _M.setData(name, data)
end

-- Table
function _M.removeData(name, n)
  local data = _M.getData(name)
  table.remove(data,n)
  _M.setData(name, data)
end

function _M.jdecode(str_a)
  return json.decode(str_a)
end


function _M.jencode(arr_a)
  return json.encode(arr_a)
end

function _M.uencode(str_a)
  return URLEncoder.encode(str_a)
end

function _M.udecode(str_a)
  return URLEncoder.decode(str_a)
end

function _M.Sizetostr(int_size)
  return Formatter.formatFileSize(activity, tonumber(int_size))
end

function _M.body_get(t)
  local data = {}
  for k,v in pairs(t) do
    table.insert(data,
    URLEncoder.encode(tostring(k))..
    "="..
    URLEncoder.encode(tostring(v)))
  end
  return table.concat(data,"&")
end

function _M.body_post(arr_a)
  return _M.jencode(arr_a)
end



function _M.httpErr(int_code, fun_o, fun_e)
  switch tonumber(int_code)
   case 200
    fun_o(int_code)
   default
    if fun_e then
      fun_e(int_code)
    end
  end
end

function _M.serverErr(code, fun_o, fun_e)
  local body = {}
  if tonumber(code) == nil then
    body = _M.jdecode(code)
   else
    body.code = code
  end
  switch body.code
   case 0
    fun_o(body)
   default
    if fun_e then
      fun_e(body)
    end
  end
end

function _M.forEach(obj, cbk)
  local function Inpairs(tab)
    if (next(obj)) == 1 then
      for k,v in ipairs(obj) do
        cbk(k, v)
      end
     else
      for k,v in pairs(obj) do
        cbk(k, v)
      end
    end
  end
  if type(obj) == "table" then
    Inpairs(obj)
   elseif type(obj) == "function" then
    for a,b,c,d in obj do
      cbk(a,b,c,d)
    end
   else
    Inpairs(luajava.astable(obj))
  end
end

function _M.print(...)
  local arr = {...}
  if #arr == 0 then
    print("nil")
  end
  _M.forEach(arr,function(k, t)
    if type(t) == "table" then
      print(dump(t))
     else
      print(t)
    end
  end)
end


return _M