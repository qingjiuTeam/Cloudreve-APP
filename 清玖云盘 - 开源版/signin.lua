require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"

import "android.graphics.RectF"
import "android.graphics.Canvas"
import "android.graphics.Bitmap"
import "android.graphics.PixelFormat"

local dialog = require"func.dialog"
local data = require"func.data"

local domain = "https://cloud.qingstore.cn"
local ids = {}
local nullCode = LuaDrawable(--设置自绘制
function(画布,画笔)--绘制函数
  画笔.setColor(0xFFECECEC)--设置画笔
  画布.drawRect(RectF(1,1,240,240),画笔)--画布绘制圆角矩形
end);

local function DrawableBitmap(drawable)
  bitmap = Bitmap.createBitmap(

  240 ,--  drawable.getIntrinsicWidth(),

  72 , --drawable.getIntrinsicHeight(),

  drawable.getOpacity() ~= PixelFormat.OPAQUE and Bitmap.Config.ARGB_8888

  or Bitmap.Config.RGB_565);

  canvas = Canvas(bitmap);

  -- canvas.setBitmap(bitmap);

  drawable.setBounds(0, 0, drawable.getIntrinsicWidth(), drawable.getIntrinsicHeight());

  drawable.draw(canvas);

  return bitmap;
end

local function Base64Bitmap(base64)
  local Base64=luajava.bindClass "android.util.Base64"
  local BitmapFactory=luajava.bindClass "android.graphics.BitmapFactory"
  base64=String(base64)
  bitmap = nil;
  xpcall(function()
    bitmapArray = Base64.decode(base64, Base64.DEFAULT);
    bitmap = BitmapFactory.decodeByteArray(bitmapArray, 0, #bitmapArray);
  end,function(e)
    print(e)
  end)
  return bitmap;
end


local function inRegister(inLogin)
  -- data.setData("captcha", nil)
  activity.setContentView(loadlayout("lay.reg",ids))
  local function setCode(fun_st, fun_ok)
    -- data.setData("captcha", nil)
    if fun_st then fun_st() end
    local url = domain.."/api/v3/site/captcha"
    Http.get(url, function(code, body, cookie)
      if code == 200 then
        if fun_ok then fun_ok(cookie) end
        data.setData("captcha", cookie)
        local arr = data.jdecode(body)
        local codeBase64 = tostring(arr.data):match("base64,(.*)")
        ids.codeImg.setImageBitmap(Base64Bitmap(codeBase64))
       else
        print("网络错误 验证码加载失败:"..code)
      end
    end)
  end
  local function reloadCode()
    setCode(function()
      ids.code.Text = ""
      ids.codeImg.setImageBitmap(DrawableBitmap(nullCode))
      ids.reg.onClick = function()
        print("请等待验证码加载完毕")
      end
    end,function(cookie)
      ids.reg.onClick = function()
        local url = domain.."/api/v3/user"
        local cdata = {
          ["Password"] = ids.password.Text,
          ["userName"] = ids.email.Text,
          ["captchaCode"] = ids.code.Text,
          ["cookie"] = cookie
        }

        if cdata.userName == "" then
          ids.email.requestFocusFromTouch()
          print("邮箱不能为空")
          return
        end
        if cdata.Password == "" then
          ids.password.requestFocusFromTouch()
          print("密码不能为空")
          return
        end
        if cdata.Password ~= ids.password2.Text then
          ids.password2.requestFocusFromTouch()
          print("两次密码不一致")
          return
        end

        local mdata = data.jencode(cdata)
        local dl = dialog.Load("正在为您注册账号…")
        Http.post(url, mdata, cookie, function(code, body)
          dl.dismiss()
          if code~=-1 and code>=200 and code<=400 then
            reloadCode()
           else
            print("网络错误:"..code)
            return
          end
          body = data.jdecode(body)
          if body.code ~= 203 then
            reloadCode()
            print("错误("..body.code.."):"..body.msg)
            return
          end

          dialog.Alert("账号注册成功!",
          "前往邮箱:"..cdata.userName.."\n激活后即可登录使用",
          "前往登录",{onClick=function()
              inLogin({
                ["username"] = cdata.userName,
                ["password"] = cdata.Password,
                })
            end})


        end)
      end

    end)
  end

  reloadCode()
  ids.codeImg.onClick = function()
    ids.codeImg.setImageBitmap(DrawableBitmap(nullCode))
    reloadCode()
  end

  ids.login.onClick = function()
    inLogin()
  end
end

local function inLogin(arr_c)
  activity.setContentView(loadlayout("lay.login",ids))

  ids.password.Text = data.getData("user_password") or ""
  ids.username.Text = data.getData("user_username") or ""
  
  if arr_c then
    ids.username.Text = arr_c.username
    ids.password.Text = arr_c.password
  end
  
  -- local domain = "https://demo.cloudreve.org"
  ids.reg.onClick = function()
    inRegister(inLogin)
  end

  ids.login.onClick = function()
    local username = ids.username.Text
    local password = ids.password.Text
    local url = domain.."/api/v3/user/session"
    local datas = {
      ["userName"] = username,
      ["Password"] = password,
      ["captchaCode"] = ""
    }

    data.setData("user_username", username)
    data.setData("user_password", password)

    dl = dialog.Load("登录中")
    Http.post(url, data.body_post(datas), function(code, body, cookie)
      dl.dismiss()
      data.httpErr(code,function()
        data.serverErr(body,function(body)
          data.setData("user_data", body)
          data.setData("user_cookie", cookie)
          print("登录成功，欢迎回来")
          activity.newActivity("MainActivity")
          activity.finish()
        end,function(body)
          print("登录失败:"..body.msg)
        end)
      end,function(code)
        print("网络错误:"..code)
      end)
    end)
  end
end


inLogin()


