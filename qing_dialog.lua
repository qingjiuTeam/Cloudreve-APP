require"import"

import"func.views"
import"apis"


function shareCopyDialog(data)
  local url = data.url
  local password = data.password

  local isDir = Boolean.valueOf(data.isdir) -- data.type=="dir" and true or false
  local c_ttype = isDir and "文件夹" or "文件"
  -- print(data.isdir)
  -- local dorf = isDir and "dir" or "file"


  local fileName = data.fileName

  import "android.content.Context"
  local function textLinear(str,click)
    return {
      LinearLayout;
      layout_width="fill";
      -- layout_marginTop="8dp";
      gravity="center";
      {
        CardView;
        layout_height="6%h";
        elevation="0";
        radius="16";
        layout_width="fill";
        background="#E0E0E0";
        {
          TextView;
          text=str or "获取失败";
          gravity="center";
          layout_height="fill";
          layout_width="fill";
          textSize="16";
          singleLine=true;
          ellipsize='middle';
          onClick=click,
        };
      };
    };
  end
  local dl
  local c1
  local c2 = (password == "") and true
  function dismissNumber(str)
    if str == "url" then
      c1 = true
    end
    if str == "password" then
      c2 = true
    end
    if c1 and c2 then
      dl.dismiss()
    end
  end

  local lay = {
    LinearLayout;
    orientation="vertical";
    gravity="center";
    {
      LinearLayout;
      orientation="vertical";
      gravity="center";
      layout_width="80%w";
      {
        LinearLayout;
        layout_width="fill";
        {
          TextView;
          layout_marginTop="16dp";
          textSize="16";
          text="点击下方内容即可复制";
        };
      };

      {
        TextView;
        layout_marginTop="16dp";
        textSize="16";
        text="链接";
      };
      textLinear(url,function(v)
        local url = v.Text
        if url:find("http") then
          print("链接已复制到剪切板")
          activity.getSystemService(Context.CLIPBOARD_SERVICE).setText(url)
          -- 写入剪贴板
         else
          print("获取失败，请重试")
        end
        dismissNumber("url")
      end),

      password ~= "" and ({
        TextView;
        layout_marginTop="16dp";
        textSize="16";
        text="密码";
      });
      password ~= "" and (textLinear(password,function(v)
        local pas = v.Text
        if pas == "获取失败" and password ~= "获取失败" then
          print("获取失败 请重试")
         else
          print("密码已复制到剪切板")
          activity.getSystemService(Context.CLIPBOARD_SERVICE).setText(pas)
          dismissNumber("password")
        end
      end)),

    };
  };

  dl = AlertDialog.Builder(this)
  .setTitle("分享链接")
  .setView(loadlayout(lay))
  .setPositiveButton("快捷复制",{onClick = function()
      str = ""
      if url then
        str = string.format("我分享了%s %s:【%s】",
        c_ttype or "错误",
        fileName or "错误",
        url or "错误")
      end
      if password and password ~= "" then
        -- rdata = require"func/data"
        -- str = str..string.format("?password=%s 】",rdata.uencode(password))
        str = str..string.format(",密码是【%s】",password)
       else
        -- str = str.." 】"
      end
      str = str.."快来看看吧。"
      activity.getSystemService(Context.CLIPBOARD_SERVICE).setText(str)
      print("复制成功")
    end})

  .show()
  -- .setCanceledOnTouchOutside(false);

  setDialogButtonColor(dl)
  fillet(dl,16)
end


