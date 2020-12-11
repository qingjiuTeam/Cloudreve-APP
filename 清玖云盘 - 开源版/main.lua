require"import" 
local data = require"func.data"

activity.setTitle("清玖云盘")

local cookie = data.getData("user_cookie")

if cookie then
  ---[[
  activity.newActivity("start")
  --]]
  --[[
  activity.newActivity("MainActivity")
  --]]
 else
  activity.newActivity("signin")
end
activity.finish()
