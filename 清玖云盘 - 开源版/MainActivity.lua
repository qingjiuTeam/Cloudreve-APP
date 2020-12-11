require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"


import"apis"
local domain = "https://cloud.qingstore.cn"



activity.setTheme(android.R.style.Theme_Material_Light_NoActionBar)

activity.setContentView(loadlayout("layout"))


import 'android.os.Build'
import 'android.view.View'
if Build.VERSION.SDK_INT >= 23 then
  activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS).setStatusBarColor(0x08080808);
  activity.getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
end


import"func.views"
rdata = require"func.data"
dialog = require"func.dialog"
power = require"func.power"


import"qing_dialog"


id_folder.onClick = function()
  id_main_page.showPage(0)
end

id_transmission.onClick = function()
  id_main_page.showPage(1)
end

id_share.onClick = function()
  id_main_page.showPage(2)
end

id_user.onClick = function()
  id_main_page.showPage(3)
end



local id_arr_pages = {
  id_folder,
  id_transmission,
  id_share,
  id_user
}


Ripple(id_arr_pages,"圆",0xFFECECEC)




local item = import"item.file_folder"
data_share = {}
adp_share = LuaAdapter(activity, data_share, item)
id_list_share.Adapter = adp_share


data_folder = {}
adp_folder = LuaAdapter(activity, data_folder, item)
id_list_folder.Adapter = adp_folder


function forUnit(int_size)
  import "android.text.format.Formatter"
  return Formatter.formatFileSize(activity, tonumber(int_size))
end






function sortPath(arr_t,sortName)-- type, date, name)
  local inSortPath
  switch sortName
   case "NameUp"
    function inSortPath(a,b)
      return (a.type ~= b.types and a.type == "dir") or ((a.type == b) and a.name < b.name)
    end
   case "NameDown"
    function inSortPath(a,b)
      return (a.type ~= b.types and a.type == "dir") or ((a.type == b) and a.name > b.name)
    end

   case "TimeUp"
    function inSortPath(a,b)
      return (a.type ~= b.types and a.type == "dir") or ((a.type == b) and a.date < b.date)
    end

   case"TimeDown"
    function inSortPath(a,b)
      return (a.type ~= b.types and a.type == "dir") or ((a.type == b) and a.date > b.date)
    end
   default
    print("错误 sort排序失败")
  end
  --return SortFunctions[SortName](a,b)
  --table.sort(FileList,SortFunctions[SortMethod])
end

local lock_error = true
function Errorhandle(code, body, fun_o, fun_e)
  if lock_error then
    if code~=-1 and code>=200 and code<=400 then
      --  if type(body) == "table" then
      if body.code == 0 or (not body.code and not body.error) then --or
        -- (notmod and not body.code and not body.error)then
        if fun_o then
          fun_o(code,body)
        end
       else
        if not(fun_e and fun_e(1,code,body) ) then
          if body.code == 401 then
            lock_error = nil
            rdata.setData("user_cookie",nil)
            print("登录信息过期，请重新登录")
            activity.newActivity("signin")
            activity.finish()
           else
            if body.msg then
              print("错误("..body.code.."):"..body.msg)
             elseif body.error then
              print("错误("..body.error.code.."):"..body.error.message)
             else
              print("未知错误:("..code.."):"..dump(body))
            end
          end
        end
      end

      --[[ else
        if body == true then

        end
      end
    --]]
     else
      if not(fun_e and fun_e(0,code,body) ) then
        print("链接失败:"..code)
      end
    end
  end
end

function getNowpath(str)
  local path = table.concat(rdata.getData("cache_foldet_path"),"/")
  if path == "" then
    path = "/"
   else
    path = "/"..path..(str or "")
  end
  id_folder_path.Text = path
  return path
end

local IconTab = {
  ["Image"] = {
    "img","png","jpeg","bmp","gif","tiff","icon","raw","webp","wmf","pcx","tga","exif","psd","cdr","pcd","dxf","ufo","eps","ai",
    "jpg"},

  ["Document"] = {
    "txt","ini"},

  ["Layout"] = {
    "aly","xml"},

  ["Video"] = {"mp4"},
  ["Music"] = {"mp3"},

  ["Code"] = {
    "lua","java","cpp"},
}
function suffixFind(types, str)
  if types=="dir" then
    return "Folder.png"
  end
  local str = str:match(".*%.(.*)")
  if not str or str == "" then
    return "Default.png"
  end
  for k,v in pairs(IconTab) do
    if table.find(v,str) then
      return k..".png"
    end
  end
  return "Default.png"
end



local empty = {
  ["folder"] = id_folder_empty,
  ["share"] = id_share_empty,
  ["trans"] = id_transsmission_empty,

  ["download"] = id_download_empty,
  ["offline"] = id_offline_empty,
  ["upload"] = id_upload_empty
}

local function reload_getDir(path)
  empty.folder.Text = "正在加载…"
  getDir(path,function(code, body)
    Errorhandle(code, body,function()
      empty.folder.Text = "暂无文件"
      adp_folder.clear()
      local data={}
      local parent = body.data.parent
      for k,v in ipairs(body.data.objects) do
        local isDir = v.type=="dir" and true or false
        table.insert(data_folder, {
          icon={src="src/suffix/"..suffixFind(v.type, v.name)},
          filename={text=v.name},
          info={text=v.date.."\t"..(isDir and "" or forUnit(v.size))},
          data = table.clone(v)
        })
      end

      --   sortPath(data_folder,"TimeUp")

      table.sort(data_folder,function(a,b)
        local a = a.data
        local b = b.data
        return (
        (a.type=="dir") ~= (b.type=="dir")and (a.type=="dir"))
        or
        (
        ( (a.type=="dir")==(b.type=="dir") ) and a.name<b.name)
      end)

      adp_folder.notifyDataSetChanged()
    end,function()
      empty.folder.Text = "加载失败"
    end)
    getNowpath()
  end)
end

function shareDialog(id, isdir, isDirt, name)
  local function numberEdit(str_a, str_b, str_c, view_a, str_t, void_w)
    return {
      LinearLayout;
      layout_marginTop="18dp";
      layout_width="fill";
      {
        TextView;
        textSize="18";
        text=str_a;
        layout_marginRight="16dp";
        textColor="#424242";
      };
      {
        CardView;
        layout_gravity="center";
        background="#E0E0E0";
        layout_height="fill";
        layout_width=void_w or "16%w";
        elevation="0";
        radius="16";
        {
          LinearLayout;
          layout_height="fill";
          layout_width="fill";
          {
            EditText;
            gravity="center";
            layout_width="fill";
            layout_height="100%h";
            textSize="18";
            layout_gravity="center";
            Hint=str_b;
            textColor="#616161";
            singleLine=true;
            InputType=str_t or "number";
            id=view_a;
          };
        };
      };
      {
        TextView;
        layout_marginLeft="16dp";
        textSize="18";
        text=str_c;
        textColor="#212121";
      };
    };
  end
  vie = {
    LinearLayout;
    orientation="vertical";
    {
      LinearLayout;
      orientation="vertical";
      layout_width="80%w";
      layout_gravity="center";
      layout_marginTop="12dp";
      {
        LinearLayout;
        layout_width="fill";
        {
          TextView;
          textSize="18";
          text="可预览";
          layout_marginRight="16dp";
          textColor="#424242";
        };
        {
          Switch;
          textSize="18";
          checked=true;
          id="swit";
        };
      };
      numberEdit("下载密码", "无", nil, "password", "all", "fill"),
      numberEdit("限次下载", "不限", "次 后失效","downs"),
      numberEdit("限时下载", "不限", "秒 后失效", "times"),
      numberEdit("有偿下载", "无需", "积分", "score"),
    };
  };

  local arr = {}
  local dl = AlertDialog.Builder(this)
  .setTitle("分享"..isDirt.." "..name)
  .setView(loadlayout(vie,arr))
  .setPositiveButton("确定分享",{onClick = function()
      local downs = arr.downs.Text
      local times = arr.times.Text
      local score = arr.score.Text

      downs = (downs=="") and -1 or tonumber(downs)
      times = (times=="") and -1 or tonumber(times)
      score = (score=="") and 0 or tonumber(score)

      local arr_init = {
        ["id"] = id, -- 文件id
        ["is_dir"] = isdir, -- 是否文件夹
        ["password"] = arr.password.Text, -- 密码
        ["downloads"] = downs, -- 下载次数限制
        ["expire"] = times, -- 到期时间
        ["score"] = score, -- 下载积分
        ["preview"] = arr.swit.isChecked() -- 可否预览
      }
      local loading = dialog.Load("创建分享链接中…")
      shareFile(arr_init,function(code, body)
        loading.dismiss()
        Errorhandle(code, body, function()
          print("创建分享链接成功")
          shareCopyDialog({
            ["url"] = body.data,
            ["password"] = arr_init.password,
            ["isdir"] = isdir,
            ["fileName"] = name
          }
          )
          -- reload_getDir(getNowpath())
        end)
      end)
    end})
  .setNegativeButton("取消分享",nil)
  .show()
  .setCanceledOnTouchOutside(false);

  setSwitchColor(arr.swit, 0xff757575, 0xff9E9E9E)

  arr.swit.setOnCheckedChangeListener{
    onCheckedChanged=function(g,c)
      if c then -- on
        setSwitchColor(arr.swit, 0xff757575, 0xff9E9E9E)
       else -- off
        setSwitchColor(arr.swit, 0xFFECECEC, 0xff9E9E9E)
      end
    end}

  setDialogButtonColor(dl)
  fillet(dl,16)
end

function renameDialog(arr, str)
  InputLayout={
    LinearLayout;
    orientation="vertical";
    Focusable=true,
    FocusableInTouchMode=true,
    {
      TextView;
      id="Prompt",
      textSize="15sp",
      layout_marginTop="10dp";
      layout_marginLeft="3dp",
      layout_width="80%w";
      layout_gravity="center",
      text="输入新名称名称:";
    };
    {
      EditText;
      hint="请避免重名";
      text=str,
      layout_marginTop="5dp";
      layout_width="80%w";
      layout_gravity="center";
      singleLine=true;
      id="edit";
    };
  };

  local dl = AlertDialog.Builder(this)
  .setTitle("重命名")
  .setView(loadlayout(InputLayout))
  .setPositiveButton("重命名",{onClick=function(v)
      local loading = dialog.Load("正在重命名…")
      renameFile({
        ["name"] = edit.Text,
        ["dir"] = arr.dir ,
        ["file"] = arr.file ,
      },function(code, body)
        loading.dismiss()
        Errorhandle(code, body, function()
          print("重命名成功")
          reload_getDir(getNowpath())
        end)
      end)
    end})
  .setNegativeButton("取消",{onClick=function(v)
    end})
  .show()
  .setCanceledOnTouchOutside(false);
  edit.requestFocus();

  setEditLineColor(edit)
  setDialogButtonColor(dl)
  fillet(dl,16)
end




function getUrlFilesize(url)
  import "java.net.URL"
  local realUrl = URL(url)-- 打开和URL之间的连接
  local con = realUrl.openConnection();
  local length=con.getContentLength(); --获取网络文件大小
  con.disconnect()
  return length
end


local styles = require"func.style"


if rdata.getData("user_cookie") then
  --  empty.folder.Text = "正在加载…"
  --  empty.share.Text = "正在加载…"
  empty.upload.Text = "暂无上传记录"
  empty.offline.Text = "暂无离线记录"
end


--[[ 文件 ============== 界面 ]]--
Ripple(id_folder_sort,"园",0xFFECECEC)

reload_getDir()

id_search_folder.onClick = function()
  local lays =
  {
    LinearLayout;
    layout_width="fill";
    layout_height="fill";
    {
      CardView;
      elevation="10dp";
      layout_width="fill";
      layout_height="14%h";
      radius="0";
      {
        LinearLayout;
        layout_width="fill";
        layout_height="fill";
        orientation="vertical";
        {
          LinearLayout;
          gravity="center";
          layout_width="fill";
          layout_height="7%h";
          {
            CardView;
            radius="2.5%h";
            layout_gravity="bottom";
            background="#FFECECEC";
            layout_width="90%w";
            layout_height="4.5%h";
            elevation="0";
            --layout_marginTop="-1%h";
            {
              LinearLayout;
              layout_height="fill";
              layout_width="fill";
              {
                ImageView;
                layout_marginLeft="4%w";
                layout_width="5%w";
                layout_height="fill";
                src="src/search.png";
              };
              {
                EditText;
                hint="在 我的分享 中寻找";
                layout_height="100%h";
                layout_width="fill";
                singleLine=true;
                layout_marginLeft="2%w";
                textSize="14sp";
                layout_gravity="center";
              };
            };
          };
        };


        {
          LinearLayout;
          gravity="left";
          layout_width="fill";
          layout_height="8%h";
          {
            TextView;
            text="测试 暂无功能";
            layout_gravity="center";
            layout_marginLeft="8%w";
            textColor="#212121";
            textSize="20sp";
            --typeface={nil,1};
          };
          {
            LinearLayout;
            gravity="right";
            layout_width="fill";
            layout_height="fill";
            {
              ImageView;
              layout_marginRight="8%w";
              layout_width="6%w";
              src="src/ic_cloud_grey600_24dp.png";
              layout_gravity="center";
              layout_height="fill";
            };
          };
        };

      };
    };
  }


  import "android.graphics.drawable.ColorDrawable"
  import "android.view.Gravity"
  import "android.view.WindowManager"
  import "android.app.AlertDialog"
  local fileDialog=AlertDialog.Builder(activity)
  fileDialog.setView(loadlayout(lays))
  fileChoseDialog=fileDialog.show()
  windowm = fileChoseDialog.getWindow();
  windowm.setBackgroundDrawable(ColorDrawable(0x00ffffff));
  wlpm = windowm.getAttributes();
  wlpm.gravity = Gravity.TOP;
  wlpm.width = WindowManager.LayoutParams.MATCH_PARENT;
  wlpm.height = WindowManager.LayoutParams.WRAP_CONTENT;
  windowm.setAttributes(wlpm);
end

id_folder_pull.onRefresh=function()
  reload_getDir(getNowpath())
  id_folder_pull.refreshFinish(0)--完成
end

id_folder_sort.onClick = function()
  local item_long_tf={
    "创建时间 升序",
    "创建时间 降序",
    "文件名称 A-Z",
    "文件名称 Z-A",
  }
  local item_long_dia_tf=AlertDialog.Builder(this)
  .setTitle("文件排序")
  .setItems(item_long_tf,{onClick=function(view,pos)
      switch pos

       default
        print("该功能未开发")
      end

    end})--列表结束
  .show()
  fillet(item_long_dia_tf,12)
end


function floatDo()
  if id_float_newbuild.getVisibility()==0 then
    id_float_newbuild.startAnimation(ScaleAnimation(1.0, 0.0, 1.0, 0.0,1, 0.5, 1, 0.5).setDuration(200))
    id_float_newbuild.setVisibility(View.INVISIBLE)
    id_float_upload.startAnimation(ScaleAnimation(1.0, 0.0, 1.0, 0.0,1, 0.5, 1, 0.5).setDuration(100))
    id_float_upload.setVisibility(View.INVISIBLE)
   else
    id_float_newbuild.setVisibility(View.VISIBLE)
    id_float_upload.setVisibility(View.VISIBLE)
    id_float_newbuild.startAnimation(ScaleAnimation(0.0, 1.0, 0.0, 1.0,1, 0.5, 1, 0.5).setDuration(200))
    id_float_upload.startAnimation(ScaleAnimation(0.0, 1.0, 0.0, 1.0,1, 0.5, 1, 0.5).setDuration(100))

  end
end
import "android.view.animation.Animation$AnimationListener"
import "android.view.animation.ScaleAnimation"
Ripple({id_float},"圆",0xFFECECEC)
Ripple({id_float_newbuild,id_float_upload},"方",0xff9E9E9E)
id_float.onClick = floatDo




function OpenFile(path)
  import "android.webkit.MimeTypeMap"
  import "android.content.Intent"
  import "android.net.Uri"
  import "java.io.File"
  FileName=tostring(File(path).Name)
  ExtensionName=FileName:match("%.(.+)")
  Mime=MimeTypeMap.getSingleton().getMimeTypeFromExtension(ExtensionName)
  if Mime then
    intent = Intent();
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    intent.setAction(Intent.ACTION_VIEW);
    intent.setDataAndType(Uri.fromFile(File(path)), Mime);
    activity.startActivity(intent);
   else
    print("找不到可以用来打开此文件的程序")
  end
end

rdata.setData("cache_foldet_path",{})
id_list_folder.onItemClick = function(a,b,c,d)
  -- power.put("android.permission.WRITE_EXTERNAL_STORAGE")

  local c_data = data_folder[d].data
  if c_data.type == "dir" then
    adp_folder.clear()
    local c_name = c_data.name
    rdata.addData("cache_foldet_path",c_name)
    local c_path = getNowpath()
    reload_getDir(c_path)
   else
    local c_info = {
      "名称:"..c_data.name,"",
      "目录:"..c_data.path,"",
      "类型:"..c_data.type,"",
      "大小:"..forUnit(c_data.size).."("..tointeger(c_data.size)..")","",
      "日期:"..c_data.date
    }
    dialog.Alert("文件信息",table.concat(c_info,"\n"),
    "确定",nil,
    "加入下载",{onClick = function()
        getDownurl(c_data.id,function(code, body)
          Errorhandle(code,body,function()
            local filename_int = c_data.name
            local path = Environment.getExternalStorageDirectory().getAbsolutePath().."/"..filename_int
            local file = File(path)
            local ti
            local dialog6 = ProgressDialog(this)
            dialog6.setProgressStyle(ProgressDialog.STYLE_HORIZONTAL);
            --设置进度条的形式为水平进度条
            dialog6.setTitle("正在下载 "..filename_int)
            dialog6.setCancelable(true)--设置是否可以通过点击Back键取消
            dialog6.setCanceledOnTouchOutside(false)--设置在点击Dialog外是否取消Dialog进度条
            dialog6.setOnCancelListener{
              onCancel=function(l)
                --停止Ticker定时器
                ti.stop()
              end}
            --取消对话框监听事件
            dialog6.setMax(getUrlFilesize(body.data))
            dialog6.show()
            fillet(dialog6,16)


            Http.download(body.data, path, function(code,body)
              ti.stop()
              dialog6.dismiss()
              if code == 200 then
                local dl = AlertDialog.Builder(this)
                .setTitle("要打开文件吗?")
                .setMessage("文件已下载到:"..body)
                .setPositiveButton("打开",{onClick=function(v) OpenFile(body) end})
                -- .setNeutralButton("中立",nil)
                -- .setNegativeButton("否认",nil)
                .show()
                fillet(dl,12)
               else
                print("error:"..code.." "..body)
              end
            end)

            ti = Ticker()
            ti.Period=100
            ti.onTick=function()
              dialog6.setProgress(file.length())
            end
            --启动Ticker定时器
            ti.start()


          end)
        end)
      end}
    --[[
    (c_data.type=="file") and "预览",{onClick = function()
        print("该文件暂不支持预览")
      end}--]])

  end
end

-- 新建文件
id_float_newbuild.onClick =function()
  floatDo()
  InputLayout={
    LinearLayout;
    orientation="vertical";
    Focusable=true,
    FocusableInTouchMode=true,
    {
      TextView;
      id="Prompt",
      textSize="15sp",
      layout_marginTop="10dp";
      layout_marginLeft="3dp",
      layout_width="80%w";
      layout_gravity="center",
      text="输入文件(夹)名称:";
    };
    {
      EditText;
      hint="请避免重名";
      layout_marginTop="5dp";
      layout_width="80%w";
      layout_gravity="center";
      singleLine=true;
      id="edit";
    };
  };

  local dl = AlertDialog.Builder(this)
  .setTitle("新建")
  .setView(loadlayout(InputLayout))
  .setPositiveButton("文件",{onClick=function(v)
      local path = getNowpath("/")
      local loading = dialog.Load("正在新建…")
      newFile(path..edit.Text,function(code, body)
        loading.dismiss()
        Errorhandle(code, body, function()
          print("新建成功")
          reload_getDir(getNowpath())
        end)
      end)
    end})
  .setNegativeButton("文件夹",{onClick=function(v)
      local path = getNowpath("/")
      newFolder(path..edit.Text,function(code, body)
        Errorhandle(code, body, function()
          print("新建成功")
          reload_getDir(getNowpath())
        end)
      end)
    end})
  .show()
  edit.requestFocus();

  setEditLineColor(edit)
  setDialogButtonColor(dl)
  fillet(dl,16)
end




--[[ 用户 =============== 界面 ]]--
id_logout.onClick = function()
  logout(function(code,body)
    Errorhandle(code,body,function()
      print("退出成功")
      rdata.setData("user_cookie", nil)
      activity.newActivity("signin")
      activity.finish()
    end)
  end)
end




--[[
getUploadmod({
  inpath = "/sdcard/test.txt"
},function(code, body)
  Errorhandle(code, body, function()
    Http.get(body.data.policy,function(code,body)
      print(body)
    end)
  end)
end)
--]]



import "android.os.Environment"
sdcard = Environment.getExternalStorageDirectory().getAbsolutePath();

import "android.content.Intent"
id_float_upload.onClick = function()
  floatDo()
  local cho = import "choice"
  cho(sdcard,function(p, d)
    local upload_policy = dialog.Load("正在获取文件上传策略…")
    local mpath = getNowpath()
    getUploadmod({inpath=p,path=mpath},function(code, body)
      upload_policy.dismiss()
      Errorhandle(code, body, function()
        if body.data.policy ~= "" then
          local file = File(p)
          local len = file.length()
          --若大小大于4<<20则采用分片 TODO

          local dia = dialog.Load("数据提交中…")
          -- Http.put(body.data.policy, bodys, head,
          local cbk = function(code_p, bodyx, mbody)
            dia.dismiss()

            -- print("error-1")
            -- io.open("/sdcard/test-e1.log","w+"):write(bodyx):close()

            Errorhandle(code_p, bodyx, function()
              local dia = dialog.Load("文件保存中…")
              okUpload(body.data.token, mbody, function(code, bodyxx)
                dia.dismiss()
                -- io.open("/sdcard/test-e2.log","w+"):write(bodyxx):close()
                -- print("error-2")
                Errorhandle(code, bodyxx, function()
                  reload_getDir(mpath)
                  print("上传成功")
                end)
              end)
            end)
          end
          local datas = {
            ["url"] = body.data.policy,
            ["path"] = p,
            ["head"] = {
              ["content-range"] = "bytes 0-"..(len -1).."/"..len,
            }
          }
          blockUpload(datas,cbk)

          --]]
         else -- 小文件上传
          local dia = dialog.Load("上传中…")
          littleUpload({inpath=p, path=mpath},function(code,body)
            dia.dismiss()
            Errorhandle(code,body,function()
              reload_getDir(mpath)
              print("上传完成")
            end)
          end)
        end

      end)
    end)
    d()
  end)
end





id_list_folder.OnItemLongClickListener = function(a,b,c,d)

  local data = data_folder[d].data
  local isDir = data.type=="dir" and true or false
  local c_ttype = isDir and "文件夹" or "文件"
  local dorf = isDir and "dir" or "file"

  local item_long_tf={
    "分享此"..c_ttype,
    "重命名",
    "删除"..c_ttype,
  }
  local item_long_dia_tf=AlertDialog.Builder(this)
  .setTitle(c_ttype.."\n"..data.name)
  .setItems(item_long_tf,{onClick=function(view,pos)
      switch pos
       case 0 -- 分享
        shareDialog(data.id, isDir, c_ttype, data.name)
       case 1 -- 重命名
        renameDialog({[dorf] = data.id}, data.name)
       case 2 -- 删除
        local arr_item = {
          [dorf] = {data.id},
        }
        dialog.Alert("危险操作确认",
        "你真的要删除"..c_ttype..":\n"..data.name.."?",
        "确认",{onClick = function()
            local dl = dialog.Load("正在删除…")
            deleteFile(arr_item ,function(code,body)
              dl.dismiss()
              Errorhandle(code,body,function()
                reload_getDir(getNowpath())
                print("删除成功")
              end)
            end)

          end},"取消")
       default
        print("该功能未开发")
      end

    end})--列表结束
  .show()


  fillet(item_long_dia_tf,12)

  return true
end

id_list_share.onItemClick = function(a,b,c,d)
  local data = data_share[d].data
  local password = ""
  local url = domain.."/#/s/"
  if data.password ~= "" then
    password = data.password
  end
  -- print(dump(data))
  shareCopyDialog({
    ["url"] = data.key and url..data.key,
    ["password"] = password,
    ["isdir"] = data.is_dir,
    ["fileName"] = data.source.name
  }
  )
end




id_list_folder.setEmptyView(id_empty_folder)
id_list_share.setEmptyView(id_empty_share)



-- id_main_page.showPage(1)


id_user_storage.setProgressDrawable(styles.progress(nil,nil,8));
id_user_storage_text.Text = "加载中…"
briefStorage(function(code, body)
  Errorhandle(code, body, function()
    if body.code == 0 then
      local total = body.data.total
      local free = body.data.free
      local rest = total - free
      id_user_storage.max = total /100
      id_user_storage.progress = rest /100

      id_user_storage_text.Text = forUnit(rest).."/"..forUnit(total)
    end
  end,function()
    id_user_storage_text.Text = "加载失败"
  end)
end)




local function PageloadSwitch(p, fun_c)
  switch p
   case 2
    -- id_share_pull.autoRefresh()
    empty.share.Text = "正在加载…"
    getMyshare(1,nil,"DESC",function(code, body)
      if fun_c then
        fun_c(code,body)
      end
      Errorhandle(code, body, function()
        empty.share.Text = "暂无文件"
        total = body.data.total
        ---[[
        adp_share.clear()
        local data={}
        for k,v in ipairs(body.data.items) do
          table.insert(data_share, {
            icon={src="src/suffix/"..suffixFind( (v.is_dir=="true" and "dir"), v.source.name)},
            filename={text=v.source.name},
            info={text=v.create_date.."\t"..forUnit(v.source.size)},
            data = table.clone(v)
          })
        end
        --[[
    table.sort(data_share, function(a,b)
      return sortPath("TimeUp", a, b)
    end)
  --]]
        adp_share.notifyDataSetChanged()
        --]]
      end,function()
        empty.share.Text = "加载失败"
      end)
    end)

   case 3
    briefStorage(function(code, body)
      if fun_c then
        fun_c(code,body)
      end
      Errorhandle(code, body, function()
        if body.code == 0 then
          local total = body.data.total
          local free = body.data.free
          local rest = total - free
          id_user_storage.max = total /100
          id_user_storage.progress = rest /100
          id_user_storage_text.Text = forUnit(rest).."/"..forUnit(total)

        end
      end)
    end)
  end
end




id_share_pull.onRefresh=function()
  PageloadSwitch(2, function()
    id_share_pull.refreshFinish(0)--完成
  end)
  --  id_folder_pull.refreshFinish(0)--完成
end




import "android.graphics.Color"
id_main_page.onPageChangeListener={
  onPageSelected=function (p)
    PageloadSwitch(p)
    for k,v in ipairs(id_arr_pages) do
      local imgs = {
        {"folder_open","folder_close"},
        {"server_open","server_close"},
        {"share_open","share_close"},
        {"user_open","user_close"}
      }
      local scale = (k==(p+1)) and 1.2 or 1.0
      local colors = (k==(p+1)) and "#616161" or "#FF757575"
      local icons = (k==(p+1)) and 1 or 2

      local icon = v.getChildAt(0)
      local text = v.getChildAt(1)
      local arrid = {icon, text}
      setScaleXY(arrid, scale)
      local img = "src/"..imgs[k][icons]..".png"
      icon.setImageBitmap(loadbitmap(img))
      setViewColor(arrid, Color.parseColor(colors))

    end
  end}



require"transmission_page"


function onKeyDown(c,e)
  if c==4 then
    -- 处理在文件时返回键的作用
    local page = id_main_page.getCurrentItem()
    if page == 0 then
      local arr_path = rdata.getData("cache_foldet_path")
      if #arr_path ~= 0 then
        rdata.removeData("cache_foldet_path")
        reload_getDir(getNowpath())
        return true
      end
    end

  end
end
