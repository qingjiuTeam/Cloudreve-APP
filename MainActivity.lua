require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"


import"apis"
-- local domain = "https://demo.cloudreve.org"
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
myview = require"views"


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




local item_share = import"item.file_share"
data_share = {}
adp_share = LuaAdapter(activity, data_share, item_share)
id_list_share.Adapter = adp_share

local item_folder = import"item.file_folder"
data_folder = {}
adp_folder = LuaAdapter(activity, data_folder, item_folder)
id_list_folder.Adapter = adp_folder





function sortPath(arr_t,sortName)-- type, date, name)
  local inSortPath
  switch sortName
   case "TimeUp"
    function inSortPath(a,b)
      local a = a.data
      local b = b.data
      return (
      (a.type=="dir") ~= (b.type=="dir")and (a.type=="dir"))
      or
      (
      ( (a.type=="dir")==(b.type=="dir") ) and a.date>b.date)
    end
   case "TimeDown"
    function inSortPath(a,b)
      local a = a.data
      local b = b.data
      return (
      (a.type=="dir") ~= (b.type=="dir")and (a.type=="dir"))
      or
      (
      ( (a.type=="dir")==(b.type=="dir") ) and a.date>b.date)
    end

   case "NameUp"
    function inSortPath(a,b)
      local a = a.data
      local b = b.data
      return (
      (a.type=="dir") ~= (b.type=="dir")and (a.type=="dir"))
      or
      (
      ( (a.type=="dir")==(b.type=="dir") ) and a.name<b.name)
    end

   case"NameDown"
    function inSortPath(a,b)
      local a = a.data
      local b = b.data
      return (
      (a.type=="dir") ~= (b.type=="dir")and (a.type=="dir"))
      or
      (
      ( (a.type=="dir")==(b.type=="dir") ) and a.name>b.name) end
   default
    print("错误 sort排序失败")
  end
  -- return SortFunctions[SortName](a,b)
  table.sort(arr_t,inSortPath)
end

local lock_error = nil
function Errorhandle(code, body, fun_o, fun_e)
  if lock_error then
    return
  end
  --  if code~=-1 and code>=200 and code<=400 then
  switch code
   case 200
   default
    if not(fun_e and fun_e(0,code,body) ) then
      print("链接失败:"..code)
    end
    return
  end
  --  if type(body) == "table" then
  if body.code == 0 or (not body.code and not body.error) then --or
    -- (notmod and not body.code and not body.error)then
    if fun_o then
      fun_o(code,body)
    end
   else
    if not(fun_e and fun_e(1,code,body) ) then
      if body.code == 401 then
        lock_error = true
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
end

function getNowpath(str)
  local path = table.concat(rdata.getData("cache_foldet_path"),"/")
  if path == "" then
    path = "/"
    id_folder_path.Text = path
   else
    path = "/"..path
    id_folder_path.Text = path.."/"
    path = path..(str or "")
  end
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
  ["Music"] = {
    "mp3","flac"},

  ["Code"] = {
    "lua","java","cpp","py","sh"},

  ["Compress"] = {
    "rar","zip","7z"},

  ["Apk"] = {"apk"},
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
          info={text=tostring(v.date):gsub("%-","/").."\t"..(isDir and "" or rdata.Sizetostr(v.size))},
          data = table.clone(v);
          ids=v.id
        })
      end

      local sortmod = rdata.getData("setting_sort_folder") or "NameUp"
      sortPath(data_folder,sortmod)

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
      numberEdit("次数限制", "不限", "次 下载后失效","downs"),
      numberEdit("时间限制", "不限", "小时后失效", "times"),
      numberEdit("积分下载", "零", "积分", "score"),
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

      nDown = not(downs=="")
      nTime = not(times=="")
      downs = nDown and tonumber(downs) or
      (nTime and 214748 or -1)

      times = nTime and tonumber(times) *60*60 or
      (nDown and 7*24 *60*60 or -1)

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

  import "android.view.inputmethod.InputMethodManager"
  edit.post(Runnable({
    run=function()
      edit.requestFocus();
      activity.getSystemService(activity.INPUT_METHOD_SERVICE)
      .showSoftInput(edit, 0)

      local sel = str:match("(.*)%.")
      if sel then
        sel = utf8.len(sel)
       else
        sel = utf8.len(str)
      end
      edit.setSelection(0,sel)
    end}))

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
                id="edit",
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
  import "android.view.inputmethod.InputMethodManager"
  edit.post(Runnable({
    run=function()
      edit.requestFocus();
      activity.getSystemService(activity.INPUT_METHOD_SERVICE)
      .showSoftInput(edit, 0)
    end}))

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
  local item_goto = {
    "TimeUp",
    "TimeDown",
    "NameUp",
    "NameDown",
  }
  local item_long_dia_tf=AlertDialog.Builder(this)
  .setTitle("文件排序")
  .setItems(item_long_tf,{onClick=function(view,pos)
      rdata.setData("setting_sort_folder",item_goto[pos+1])
      reload_getDir(getNowpath())
    end})--列表结束
  .show()
  fillet(item_long_dia_tf,12)
end


function dp2px(dpValue)
  local scale = activity.getResources().getDisplayMetrics().scaledDensity
  return dpValue * scale + 0.5
end

import "android.view.animation.Animation$AnimationListener"
import "android.view.animation.ScaleAnimation"
Ripple({id_float},"圆",0xFFECECEC)
-- Ripple({id_float_newbuild,id_float_upload},"方",0xff9E9E9E)
-- 悬浮球
id_float.onClick = function()
  local cards = myview.CardandText
  local fileChoseDialog
  local layid = {}
  local lays= {LinearLayout;
    layout_width="fill";
    layout_height="fill";
    id="home";
    {LinearLayout;
      layout_width="fill";
      layout_height="100%h";
      id="back";
      gravity="bottom";
      {LinearLayout;
        orientation="vertical";
        layout_width="fill";

        {LinearLayout;
          layout_width="fill";
          layout_height="128dp";
          orientation="horizontal";
          cards{
            text="新建文件(夹)";
            icon="src/folder_line";
            color="#4DD0E1";
            click=function()
              dialog_newFolder()
              fileChoseDialog.dismiss()
            end;
          };
          cards{
            text="上传文件";
            icon="src/file_line";
            color="#66BB6A";
            click=function()
              dialog_uploadFile()
              fileChoseDialog.dismiss()
            end;
          };
        };
        {LinearLayout;
          gravity="center";
          layout_width="fill";
          layout_height="46dp";
          layout_marginBottom=dp2px(8 + 5);
          {ImageView;
            src="src/addpro";
            colorFilter="#000000";
            id="close";
          };
        };
      };
    };
  };


  import "android.graphics.drawable.ColorDrawable"
  import "android.view.Gravity"
  import "android.view.WindowManager"
  local fileDialog=AlertDialog.Builder(activity)
  fileDialog.setView(loadlayout(lays,layid))
  fileChoseDialog=fileDialog.show()
  windowm = fileChoseDialog.getWindow();
  windowm.setBackgroundDrawable(ColorDrawable(0x00ffffff));

  wlpm = windowm.getAttributes();
  -- wlpm.gravity = Gravity.TOP;
  wlpm.width = WindowManager.LayoutParams.MATCH_PARENT;
  wlpm.height = WindowManager.LayoutParams.WRAP_CONTENT
  wlpm.dimAmount = 0.0--背景灰度值
  windowm.setAttributes(wlpm);

  layid.back.onClick=function()
    fileChoseDialog.dismiss()
  end

  id_home_top.post(Runnable{
    run=function()
      view= id_home_top
      view.destroyDrawingCache();
      view.setDrawingCacheEnabled(true);
      view.buildDrawingCache();
      bmp = view.getDrawingCache();

      import "android.view.animation.AccelerateInterpolator"
      animator = ViewAnimationUtils.createCircularReveal(
      layid.home,
      activity.getWidth()/2,activity.getHeight() - 36,
      0,Math.hypot(layid.home.getWidth(),
      layid.home.getHeight()));

      animator.setInterpolator(AccelerateInterpolator());
      animator.setDuration(220);
      animator.start()

      task(5,function()
        import "android.graphics.drawable.BitmapDrawable"
        local img = 缩略图片(bmp,50)
        local img = 高斯模糊(img,1,2);

        layid.home.setBackground(BitmapDrawable(img))
      end)

    end
  })
  --]]

end

---[[
function 高斯模糊(位图,模糊度,加深)
  import "android.graphics.Matrix"
  import "android.graphics.Bitmap"
  import "android.renderscript.Allocation"
  import "android.renderscript.Element"
  import "android.renderscript.ScriptIntrinsicBlur"
  import "android.renderscript.RenderScript"
  local renderScript = RenderScript.create(activity);
  local blurScript = ScriptIntrinsicBlur.create(renderScript,Element.U8_4(renderScript));
  local inAllocation = Allocation.createFromBitmap(renderScript,位图);
  local outputBitmap = 位图;
  local outAllocation = Allocation.createTyped(renderScript,inAllocation.getType());
  blurScript.setRadius(模糊度);
  blurScript.setInput(inAllocation);
  blurScript.forEach(outAllocation);
  outAllocation.copyTo(outputBitmap);
  inAllocation.destroy();
  outAllocation.destroy();
  renderScript.destroy();
  blurScript.destroy();
  local w = outputBitmap.getWidth();
  local h = outputBitmap.getHeight();
  local matrix = Matrix();
  matrix.postScale(加深,加深);
  return Bitmap.createBitmap(outputBitmap,0,0,w,h,matrix,true);
end
-- 高斯模糊(activity,缩略图片(bmp,50),1,2);
function 缩略图片(图片,比例)
  local model={}
  local h=图片.getHeight()
  local w=图片.getWidth()
  import "android.graphics.Bitmap"
  local curPic = Bitmap.createBitmap(图片.getWidth()/比例+1,图片.getHeight()/比例+1,Bitmap.Config.ARGB_4444);
  for n=0,h/比例 do
    model[n]={}
    for t=0,w/比例 do
      local c=图片.getPixel(t*比例,n*比例)

      if c ==-0 then

       else
        curPic.setPixel(t,n,c);
      end
    end
  end
  return curPic
end
--]]

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
      "大小:"..rdata.Sizetostr(c_data.size).."("..tointeger(c_data.size)..")","",
      "日期:"..c_data.date
    }
    dialog.Alert("文件信息",table.concat(c_info,"\n"),
    "确定",nil,
    "加入下载",{onClick = function()
        getDownurl(c_data.id,function(code, body)
          Errorhandle(code,body,function()
            local filename_int = c_data.name
            local path = Environment.getExternalStorageDirectory().getAbsolutePath()..
            "/Qingcloud/download/"..filename_int
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
            dialog6.setProgress(0)
            dialog6.show()
            fillet(dialog6,16)

            --先导入包
            -- import "android.content.*"
            -- activity.getSystemService(Context.CLIPBOARD_SERVICE).setText(body.data)
            Http.download(body.data, path, function(code,body)
              ti.stop()
              dialog6.dismiss()
              if code == 200 then
                print("下载完成，文件已下载到："..body)
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


---[[ 新建文件
function dialog_newFolder()
  --  floatDo()
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
      -- windowSoftInputMode="stateVisible";
      id="edit";
    };
  };

  local dl = AlertDialog.Builder(this)
  .setTitle("新建")
  .setView(loadlayout(InputLayout))
  .setPositiveButton("文件夹",{onClick=function(v)
      local path = getNowpath("/")
      newFolder(path..edit.Text,function(code, body)
        Errorhandle(code, body, function()
          print("新建成功")
          reload_getDir(getNowpath())
        end)
      end)
    end})
  .setNegativeButton("文件",{onClick=function(v)
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
  .show()

  import "android.view.inputmethod.InputMethodManager"
  edit.post(Runnable({
    run=function()
      edit.requestFocus();
      activity.getSystemService(activity.INPUT_METHOD_SERVICE)
      .showSoftInput(edit, 0)
    end}))

  setEditLineColor(edit)
  setDialogButtonColor(dl)
  fillet(dl,16)
end
--][


--[[ 用户 =============== 界面 ]]--
---[[
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
--]]


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

function canvasProgress(id,max,to)
  id.post(Runnable{
    run = function(u)
      local height = id.getHeight()
      local width = id.getWidth()
      local rads = 360/max *to -- 占比

      local centH = height / 2
      local centW = width / 2

      local Minlen = height > width and width or height
      -- local Maxlen = height > width and height or width
      local maxR = Minlen / 2

      local countX = lambda num:centW + num
      local countY = lambda num:centH + num
      id.setBackground(
      LuaDrawable(function(canvas, mPaint, ctr)
        import "android.graphics.Paint"
        import "android.graphics.RectF"

        --[[mPaint.setColor(0xff000000)
        mPaint.setStyle(Paint.Style.STROKE)
        canvas.drawLine(0, 0, width, height, mPaint)
        canvas.drawLine(width, 0, 0, height, mPaint)
        --]]
        local radTotal = rads --360 - radFree
        local radFree = 360 - rads
        local radFree = radFree -2

        mPaint.setStyle(Paint.Style.FILL)


        -- 大圆
        mPaint.setColor(0xff90CAF9)
        canvas.drawArc(RectF(countX(-maxR), countY(-maxR),
        countX(maxR), countY(maxR)),
        -90,radTotal,true,mPaint)

        -- 小圆
        local lR = maxR * 0.95
        mPaint.setColor(0xffE0E0E0) canvas.drawArc(
        RectF(countX(-lR), countY(-lR),
        countX(lR), countY(lR)),
        -90,-radFree,true,mPaint)

        -- 中间的圆
        local cR = maxR * 0.7
        mPaint.setColor(0xffffffff) canvas.drawArc(
        RectF(countX(-cR), countY(-cR),
        countX(cR), countY(cR)),0,360,true,mPaint)

        -- 文字
        local percent = tointeger(radTotal / 360 *100)
        mPaint.setColor(0xff000000)
        mPaint.setTextSize(maxR*0.4)
        mPaint.setTextAlign(Paint.Align.CENTER);
        canvas.drawText(percent.."%", centW, centH + maxR*0.15, mPaint);

        -- Toast.makeText(activity, "succes",Toast.LENGTH_SHORT).show()


      end)
      )
    end

  })
end


import "android.os.Environment"
sdcard = Environment.getExternalStorageDirectory().getAbsolutePath();

import "android.content.Intent"
function dialog_uploadFile()
  local cho = import "choice"
  cho(sdcard,function(p, d)
    local upload_policy = dialog.Load("正在获取文件上传策略…")
    local mpath = getNowpath()
    getUploadmod({inpath=p,path=mpath},function(code, body)
      upload_policy.dismiss()
      Errorhandle(code, body, function()
        if body.data.policy ~= "" then
          -- 服务器给了策略 则大文件上传
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


 


p_cache = activity.getExternalCacheDir().getAbsolutePath()

p_upload = p_cache.."/upload"


import "java.io.File"
local upload_obj_file = File(p_upload)
if not upload_obj_file.isDirectory() then
  --  upload_obj_file.mkdir()
end



function Filebottommenu(info)
  local lay = {}
  local cards = myview.CardandText
  local lays={LinearLayout;
    layout_width="fill";
    layout_height="fill";
    {CardView;
      --   layout_height="200dp";
      layout_width="fill";
      id="card";
      {LinearLayout;
        layout_width="fill";
        layout_height="fill";
        orientation="vertical";
        {TextView;
          text=info.data.name or "Error";
          layout_marginTop="16dp";
          layout_gravity="top|center";
          layout_width="90%w";
          textSize="20sp";
          textColor="#212121";
          singleLine=true;
          ellipsize='middle';
          typeface={nil,1};
        };
        myview.splitLine{
          width="100%w"};


        {LinearLayout;
          layout_width="90%w";
          layout_marginTop="16dp";
          layout_marginBottom="16dp";
          layout_gravity="top|center";
          {LinearLayout;
            orientation="vertical";
            layout_width="fill";
            --  background="#000000";
            {LinearLayout;
              orientation="horizontal";
              layout_width="fill";


              cards{color="#E0E0E0";elv=0;
                text="详情信息";
                icon="src/info";
                id="info";

              };
              cards{color="#E0E0E0";elv=0;
                text="重命名";
                icon="src/write";
                id="rename";
              };
              cards{color="#E0E0E0";elv=0;
                text="分享链接";
                icon="src/share";
                id="share";
              };
            };

            {LinearLayout;
              layout_width="fill";
              orientation="horizontal";
              layout_marginTop="16dp";
              cards{color="#E0E0E0";elv=0;
                text="删除";
                icon="src/delete";
                id="delete";
              };
              cards{color="#E0E0E0";elv=0;
                text="下载文件";
                icon="src/adddownload";
                id="download";
              };

            };

          };
        };
        --[[      
      myview.splitLine{
        width="100%w"};
      {TextView;
        text="确定";
        layout_marginTop="16dp";
        layout_gravity="top|center";
        textSize="20sp";
        textColor="#2196F3";
        typeface={nil,1};
      };

      {TextView;
        text="取消";
        layout_marginTop="16dp";
        layout_marginBottom="16dp";
        layout_gravity="top|center";
        textSize="20sp";
        textColor="#9E9E9E";
        typeface={nil,1};
      };
    --]]

      };
    }
  };

  import "android.graphics.drawable.ColorDrawable"
  import "android.view.Gravity"
  import "android.view.WindowManager"
  local fileDialog=AlertDialog.Builder(activity)
  fileDialog.setView(loadlayout(lays,lay))
  fileChoseDialog=fileDialog.show()
  windowm = fileChoseDialog.getWindow();
  windowm.setBackgroundDrawable(ColorDrawable(0x00ffffff));

  wlpm = windowm.getAttributes();
  wlpm.gravity = Gravity.BOTTOM;
  wlpm.width = WindowManager.LayoutParams.MATCH_PARENT;
  wlpm.height = WindowManager.LayoutParams.WRAP_CONTENT
  -- wlpm.dimAmount = 0.0--背景灰度值
  windowm.setAttributes(wlpm);

  Ripple(lay.info,"圆",0xff0D47A1)
  RippleArr(lay.card,{y={ 48,48,0,0 }})

  local data = info.data
  local isDir = data.type=="dir" and true or false
  local c_ttype = isDir and "文件夹" or "文件"
  local dorf = isDir and "dir" or "file"



  lay.info.onClick = function() -- 信息
    print"暂不支持(¯﹃¯)"
  end
  lay.rename.onClick = function()
    renameDialog({[dorf] = data.id}, data.name)
    fileChoseDialog.dismiss()
  end
  lay.share.onClick = function()
    local isDir = info.data.type=="dir" and true or false
    local c_ttype = isDir and "文件夹" or "文件"
    shareDialog(info.ids, isDir, c_ttype, info.data.name)
    fileChoseDialog.dismiss()
  end

  lay.delete.onClick = function()
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
    fileChoseDialog.dismiss()
  end
  lay.download.onClick = function()
    downloadFile(data)
    fileChoseDialog.dismiss()
  end
end



function downloadFile(info)
  getDownurl(info.id,function(code, body)
    Errorhandle(code,body,function()
      local filename_int = info.name
      local path = Environment.getExternalStorageDirectory().getAbsolutePath()..
      "/Qingcloud/download/"..filename_int
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
      dialog6.setProgress(0)
      dialog6.show()
      fillet(dialog6,16)

      --先导入包
      -- import "android.content.*"
      -- activity.getSystemService(Context.CLIPBOARD_SERVICE).setText(body.data)
      Http.download(body.data, path, function(code,body)
        ti.stop()
        dialog6.dismiss()
        if code == 200 then
          print("下载完成，文件已下载到："..body)
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
end







func_foder_menu_Onclick = function(v)
  local ids = tostring(v.getChildAt(0).Text)
  for k,v in ipairs(data_folder) do
    if v.data.id == ids then
      Filebottommenu(v)
    end
  end
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


id_user_shop.onClick=function()
  print("请到网页版操作")
end


id_list_folder.setEmptyView(id_empty_folder)
id_list_share.setEmptyView(id_empty_share)



-- id_main_page.showPage(1)

--[[ Todo 用户余剩存储
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
]]

require"transmission_page"



local function PageloadSwitch(p, fun_c)
  switch p
   case 1
    reloadDownloadlist()
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
            icon={src="src/suffix/"..suffixFind(v.is_dir and "dir" , v.source.name)},
            filename={text=v.source.name},
            info={text=tostring(v.create_date):gsub("%-","/").."\t"..rdata.Sizetostr(v.source.size)},
            views={text=tostring(tointeger(v.views))},
            downs={text=tostring(tointeger(v.downloads))},
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
        --  if body.code == 0 then
        local total = body.data.total -- 总内存
        local free = body.data.free -- 余剩内存
        local rest = total - free -- 已用内存
        -- local ratio = rest/total -- 内存比

        canvasProgress(id_storage_canvas, total,rest)
        -- end
        id_storage_free.Text = rdata.Sizetostr(free)
        id_storage_total.Text = rdata.Sizetostr(total)
      end,function()
        canvasProgress(id_storage_canvas, 100,0)
        id_storage_free.Text = "加载失败"
        id_storage_total.Text = "加载失败"
      end)
    end)

    getMyinfo(function(code, body)
      Errorhandle(code, body, function()
        local headicon = {
          ["l"] = domain.."/api/v3/user/avatar/"..body.data.id.."/l",
          ["s"] = domain.."/api/v3/user/avatar/"..body.data.id.."/s",
        }
        thread(function(fun_c,urls)
          require("import")
          urls = luajava.astable(urls)
          LuaBitmap.setCacheTime(-1)

          xpcall(function() -- l尺
            local bit = loadbitmap(urls.l)
            fun_c(bit)
          end,function()
            xpcall(function() -- s尺
              local bit = loadbitmap(urls.s)
              fun_c(bit)
            end,function() -- 无
              local bit = loadbitmap(activity.getLuaDir().."/src/defhead.jpg")
              fun_c(bit)
            end)
          end)


        end,function(bit)
          --  pcall(function() -- TODO: 这玩意有个报错bug 不知道怎么回事
          id_user_headimg.post(Runnable{
            run = function()
              id_user_headimg.setImageBitmap(bit)
            end})
          -- end)
        end,headicon)

        local data = body.data
        id_user_username.Text = data.nickname
        id_user_email.Text = data.user_name

        id_user_label.Text = data.group.name
        id_user_label_card.setCardBackgroundColor(0xff000000)
        id_user_label.setTextColor(0xffffffff)
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




RippleArr(id_bottom_card,{y={ 48,48,0,0 }})





import "android.graphics.Color"
id_main_page.onPageChangeListener={
  onPageSelected=function (p)
    PageloadSwitch(p)
    for k,v in ipairs(id_arr_pages) do
      local imgs = {
        {"folder","folder"},
        {"trans","trans"},
        {"cloud","cloud"},
        {"head","head"}
      }
      local scale = (k==(p+1)) and 1.2 or 1.0
      local colors = (k==(p+1)) and "#64B5F6" or "#FF757575"
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
