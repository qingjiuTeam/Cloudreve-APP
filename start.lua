require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"

local dialog = require("func.dialog")
local data = require"func.data"

local lay = {
  LinearLayout;
  orientation="vertical";
  gravity="center";
  background="#ffffff";
  {ImageView;
    src="src/welcome";
    layout_width="80%w";
    layout_height="60%h";
    };
  {
    TextView;
   -- text="正在与服务器联系_(:з」∠)_";
    textSize="26sp";
    typeface={nil,1};
  };
  {
    TextView;
    text="正在与服务器联系_(:з」∠)_";
    textColor="#424242";
    textSize="16sp";
    typeface={nil,1};
  };
};

activity.setContentView(loadlayout(lay))

--[[
activity.newActivity("MainActivity")
activity.finish()
--]]



local version = this.PackageManager.getPackageInfo(this.PackageName,64).versionCode

import "android.content.Intent"
import "android.net.Uri"
-- data.setData("ignoreVersion",nil)
local url = "http://gx.qingstore.cn/qjgx.php"
Http.get(url, function(code, body)
  if code==200 then
    --[=[
    version = 105
    local body = [[
      %version%107%
      %title%1.07更新%
      %content%测试%
      %url%https://cloud.qingstore.cn/#/s/Kkjs8%
      
      %version%106%-must%
      %title%1.06更新%
      %content%测试%
      %url%https://www.baidu.com/%
      
      %version%105%
      %title%1.05更新%
      %content%测试%
      %url% %
    ]]
    --]=]
    local new_version = body:match("%%version%%(.-)%%")
    local title = body:match("%%title%%(.-)%%")
    local content = body:match("%%content%%(.-)%%"):gsub("<p>","\n")
    local url = body:match("%%url%%(.-)%%")
    local mustup = tonumber(body:match("%%version%%(%d+)%%must%%")) or 0
    --must
    if tonumber(version) < tonumber(new_version) then
      local dl
      local ismust = mustup > tonumber(version)
      if ismust then --必须更新
        dl = dialog.Alert(title,content,
        "更新",{onClick=function()
            viewIntent = Intent("android.intent.action.VIEW",Uri.parse(url))
            activity.startActivity(viewIntent)
            activity.finish()
          end},"群组",{onClick=function()
            local urls="mqqapi://card/show_pslcard?src_type=internal&version=1&uin=794207219&card_type=group&source=qrcode"
            activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(urls)))
            activity.finish()
          end}
        ) -- .setCanceledOnTouchOutside(false)
       else -- 非必须更新
        if (data.getData("ignoreVersion") or 0) == new_version then
          activity.newActivity("MainActivity")
          activity.finish()
          return
        end
        dl = dialog.Alert(title,content,
        "更新",{onClick=function()
            viewIntent = Intent("android.intent.action.VIEW",Uri.parse(url))
            activity.startActivity(viewIntent)
            activity.finish()
            System.exit(0)
          end},"取消",{onClick=function()
          end},
        "忽略本次更新",{onClick=function()
            print("已忽略此次版本更新")
            data.setData("ignoreVersion",new_version)
          end}
        )
      end
      dl.onDismiss=function()
        if not ismust then
          activity.newActivity("MainActivity")
        end
        activity.finish()
      end

     else
      activity.newActivity("MainActivity")
      activity.finish()
    end

   else

    dialog.Alert("与服务器失联辽","请检查网络，或进群求助",
    "联系求助",{onClick=function()
        local urls="mqqapi://card/show_pslcard?src_type=internal&version=1&uin=794207219&card_type=group&source=qrcode"
        -- 794207219 是群号
        activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(urls)))
        activity.finish()
      end}).setCanceledOnTouchOutside(false)
  end
end)


--动画
activity.overridePendingTransition(android.R.anim.fade_in,android.R.anim.fade_out)

