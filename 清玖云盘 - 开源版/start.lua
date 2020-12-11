require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"

local dialog = require("func.dialog")

local lay = {
  LinearLayout;
  orientation="vertical";
  gravity="center";
  {
    TextView;
    text="欢迎 Cloud";
    textSize="26sp";
    typeface={nil,1};
  };
  {
    TextView;
    text="正在联系服务器…";
    textSize="16sp";
    typeface={nil,1};
  };
};

activity.setContentView(loadlayout(lay))


local version = this.PackageManager.getPackageInfo(this.PackageName,64).versionCode

import "android.content.Intent"
import "android.net.Uri"

local url = "https://www.qingstore.cn/gengxin/gx.php/"
Http.get(url, function(code, body)
  if code~=-1 and code>=200 and code<=400 then
    local new_version = body:match("%%version%%(.-)%%")
    local title = body:match("%%title%%(.-)%%")
    local content = body:match("%%content%%(.-)%%"):gsub("<p>","\n")
    local url = body:match("%%url%%(.-)%%")
    
    if tonumber(version) < tonumber(new_version) then
      dialog.Alert(title,content,
      "更新",{onClick=function()
          viewIntent = Intent("android.intent.action.VIEW",Uri.parse(url))
          activity.startActivity(viewIntent)
          activity.finish()
        end},
      "加群",{onClick=function()
          local urls="mqqapi://card/show_pslcard?src_type=internal&version=1&uin=794207219&card_type=group&source=qrcode"
          activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(urls)))
          activity.finish()
        end}).setCanceledOnTouchOutside(false)
     else
      activity.newActivity("MainActivity")
      activity.finish()
    end
  
   else
    dialog.Alert("与服务器失联辽","请检查网络，或进群求助",
    "加群",{onClick=function()
        local urls="mqqapi://card/show_pslcard?src_type=internal&version=1&uin=794207219&card_type=group&source=qrcode"
        activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(urls)))
        activity.finish()
      end}).setCanceledOnTouchOutside(false)
  end
end)


--动画
activity.overridePendingTransition(android.R.anim.fade_in,android.R.anim.fade_out)

