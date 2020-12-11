_M = {}
-- 申请权限  Per(per)
-- select : 
--   l_ per => @String/@Table
-- result :
--   l_ @LuaActivity
function _M.put(...)
  if type(per) == "string" then
    per = {...}
  end
  return activity.requestPermissions(per, 1)
end

-- 获取权限列表  PerList()
-- select : null
-- result : 
--   l_ @Table
function _M.list()
  local pinfor = luajava.bindClass("android.content.pm.PackageManager")
  local packageInfo = activity.getPackageManager().getPackageInfo(activity.getPackageName(),pinfor.GET_PERMISSIONS);
  return luajava.astable(packageInfo.requestedPermissions)
end

-- 检查权限  PerCheck(per, cbk)
-- select : 
--   l_ per => @String
--   l_ per => @Table
--      l_ cbk => @Function
-- result :
--   l_ per => @String : @Boolean
--   l_ per => @Table : @Boolean[]
function _M.check(per, cbk)
  local c = lambda pes : (activity.checkSelfPermission(pes) == 0) and true or false

  if type(per) == "table" then
    for k,v in pairs(per) do
      cbk(c(v), v)
    end
    
    return ptab
   else
   
    return c(per)
  end
end

return _M