require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"

return function(StartPath,event,theme)
  if theme==1 then
    主题="#ff212121"
    强调="#ffffffff"
    字体="#c0ffffff"
   else
    主题="#ffffffff"
    强调="#ff444444"
    字体="#ff444444"
  end
  function CloseDialog(dialog)
    dialog.dismiss()
  end
  import "android.graphics.Typeface"
  import "android.graphics.drawable.ColorDrawable"
  import "android.graphics.drawable.*"
  import "java.io.*"
  local abm={
    LinearLayout;
    layout_width="fill";
    paddingTop="0dp";
    {
      CardView;
      layout_width="fill";
      radius="0dp";
      translationZ="0dp";
      background=主题;
      Elevation="10";
      {
        LinearLayout;
        orientation="vertical";
        layout_width="fill";
        layout_height="fill";
        {
          LinearLayout;
          layout_width="fill";
          Gravity="left|center";
          layout_marginTop="24dp";
          layout_marginLeft="24dp";
          layout_marginRight="24dp";
          {
            TextView;
            layout_weight="1";
            layout_marginLeft="4dp";
            Typeface=Typeface.createFromFile(File(activity.getLuaDir().."/res/product.ttf"));
            textSize="20sp";
            Text="文件选择";
            textColor=字体;
          };
          {
            Button;
            style="?android:attr/buttonBarButtonStyle";
            text="close",
            textColor="#85ADF5",
            Typeface=Typeface.defaultFromStyle(Typeface.BOLD);
            id="choice_exitbtn",
            onClick=function()CloseDialog(fileChoseDialog)end;
          };
        };
        {
          RelativeLayout;
          layout_width="fill";
          layout_height="fill";
          {
            PageView;
            id="pageview";
            pages={
              {
                LinearLayout;
                layout_width="fill";
                layout_height="fill";
                orientation="vertical";
                {
                  TextView;
                  layout_width="fill";
                  textSize="14sp";
                  paddingTop="8dp";
                  paddingLeft="24dp";
                  paddingRight="24dp";
                  paddingBottom="8dp";
                  Typeface=Typeface.createFromFile(File(activity.getLuaDir().."/res/product.ttf"));
                  Text="sdcard";
                  textColor=字体;
                  id="cp";
                };
                {
                  ListView;
                  fastScrollEnabled=true;
                  id="lva";
                  layout_width="fill";
                  layout_height="fill";
                };
              };
              {
                ListView;
                fastScrollEnabled=true;
                paddingTop="8dp";
                id="shortcutListId";
                layout_width="fill";
                layout_height="fill";
              };
            };
          };
          {
            LinearLayout;
            layout_width="fill";
            layout_height="fill";
            gravity="bottom|center";
            {
              LinearLayout;
              layout_height="2dp";
              layout_width="fill";
              background="#3fffffff";
              translationZ="0dp";
              Elevation="0";
            };
          };
          {
            LinearLayout;
            layout_width="fill";
            layout_height="fill";
            gravity="bottom|center";
            {
              LinearLayout;
              layout_height="2dp";
              layout_width="50%w";
              Gravity="center";
              id="psdm";
              background=强调;
            };
            {
              LinearLayout;
              layout_width="50%w";
            };
          };
        };
      };
    };
  };

  local fileDialog=AlertDialog.Builder(activity)
  fileDialog.setView(loadlayout(abm))
  fileChoseDialog=fileDialog.show()
  windowm = fileChoseDialog.getWindow();
  windowm.setBackgroundDrawable(ColorDrawable(0x00ffffff));
  wlpm = windowm.getAttributes();
  wlpm.gravity = Gravity.BOTTOM;
  wlpm.width = WindowManager.LayoutParams.MATCH_PARENT;
  wlpm.height = WindowManager.LayoutParams.WRAP_CONTENT;
  windowm.setAttributes(wlpm);

  itm={
    LinearLayout;
    layout_height="-2";
    layout_width="-1";
    Gravity="left|center";
    paddingTop="12dp";
    paddingLeft="24dp";
    paddingRight="24dp";
    paddingBottom="12dp";
    {
      ImageView;
      src="res/file";
      layout_height="24dp";
      layout_width="24dp";
      colorFilter=字体;
      id="tb";
    };
    {
      TextView;
      layout_width="-1";
      layout_marginLeft="16dp";
      layout_height="-2";
      textSize="14sp";
      Text="sdcard";
      textColor=字体;
      Typeface=Typeface.createFromFile(File(activity.getLuaDir().."/res/product.ttf"));
      id="ll";
    };
  };

  ddp=LuaAdapter(activity,itm)

  function SetItem(path)
    path=tostring(path)
    ddp.clear()--清空适配器
    cp.Text=tostring(path)--设置当前路径
    if path~="/sdcard" then--不是根目录则加上../
      ddp.add{ll="<-"..tostring(File(cp.Text).getParentFile()),tb={src="res/re.png"}}
    end
    ls=File(path).listFiles()
    if ls~=nil then
      ls=luajava.astable(File(path).listFiles()) --全局文件列表变量
      table.sort(ls,function(a,b)
        return (a.isDirectory()~=b.isDirectory() and a.isDirectory()) or ((a.isDirectory()==b.isDirectory()) and a.Name<b.Name)
      end)
     else
      ls={}
    end
    for index,c in ipairs(ls) do
      if c.isDirectory() then--如果为文件夹
        ddp.add{ll=c.Name.."/",tb={src="res/folder.png"}}
       else
        if c.isFile() then
          --如果为文件
          if c.Name:find("%.fas") then
            ddp.add{ll=c.Name,tb={src="res/box.png"}}
           elseif c.Name:find("%.alp$") then
            ddp.add{ll=c.Name,tb={src="res/box.png"}}
           elseif c.Name:find("%.apk$") then
            ddp.add{ll=c.Name,tb={src="res/android.png"}}
           elseif c.Name:find("%.txt$") or c.Name:find("%.bat$") or c.Name:find("%.lua$") or c.Name:find("%.aly$") then
            ddp.add{ll=c.Name,tb={src="res/zfile.png"}}
           elseif c.Name:find("%.mp3$") or c.Name:find("%.ogg$") then
            ddp.add{ll=c.Name,tb={src="res/music.png"}}
           elseif c.Name:find("%.img$") or c.Name:find("%.png$") or c.Name:find("%.jpg$") then
            ddp.add{ll=c.Name,tb={src="res/image.png"}}
           elseif c.Name:find("%.ppt$") then
            ddp.add{ll=c.Name,tb={src="res/ppt.png"}}
           elseif c.Name:find("%.word$") then
            ddp.add{ll=c.Name,tb={src="res/word.png"}}
           elseif c.Name:find("%.pdf$") then
            ddp.add{ll=c.Name,tb={src="res/pdf.png"}}
           else
            ddp.add{ll=c.Name,tb={src="res/file.png"}}
            end
          --]]          

          end
        end
      end
    end
    lva.onItemClick=function(l,v,p,s)
      项目=tostring(v.Tag.ll.Text)
      if tostring(cp.Text)=="/sdcard" then
        路径=ls[p+1]
       else
        路径=ls[p]
      end
      if 项目=="<-"..tostring(File(cp.Text).getParentFile()) then
        SetItem(File(cp.Text).getParentFile())
       elseif 路径.isDirectory() then
        SetItem(路径)
       elseif 路径.isFile() then
        文件路径=cp.Text.."/"..v.Tag.ll.Text
        event(文件路径,function() choice_exitbtn.performClick() end)
      end
    end
    lva.setAdapter(ddp)

    shortcutList={
      LinearLayout;
      layout_height="-2";
      layout_width="-1";
      Gravity="left|center";
      paddingTop="12dp";
      paddingLeft="24dp";
      paddingRight="24dp";
      paddingBottom="12dp";
      {
        ImageView;
        layout_height="24dp";
        layout_width="24dp";
        layout_marginRight="16dp";
        layout_marginTop="8dp";
        layout_marginBottom="8dp";
        colorFilter=字体;
        id="shortcutIcon";
      };
      {
        LinearLayout;
        orientation="vertical";
        layout_width="-1";
        layout_height="-1";
        gravity="center|left";
        {
          TextView;
          layout_width="fill";
          textSize="14sp";
          singleLine="true";
          textColor=字体;
          id="shortcutTitle";
          Typeface=Typeface.createFromFile(File(activity.getLuaDir().."/res/product.ttf"));
        };
        {
          TextView;
          layout_width="fill";
          textSize="12sp";
          textColor=字体;
          singleLine="true";
          Typeface=Typeface.createFromFile(File(activity.getLuaDir().."/res/product.ttf"));
          id="shortcutPath";
        };
      };
    };
    shortcutAdp=LuaAdapter(activity,shortcutList)
    if File("/sdcard/download").exists()==true then
      shortcutAdp.add{shortcutTitle="系统下载目录",shortcutPath="/sdcard/download",shortcutIcon={src="res/folder.png"}}
    end
    if File("/sdcard/tencent/QQfile_recv").exists()==true then
      shortcutAdp.add{shortcutTitle="QQ文件下载目录",shortcutPath="/sdcard/tencent/QQfile_recv",shortcutIcon={src="res/folder.png"}}
    end
    if File("/sdcard/tencent/QQ_Images").exists()==true then
      shortcutAdp.add{shortcutTitle="QQ保存的图片",shortcutPath="/sdcard/tencent/QQ_Images",shortcutIcon={src="res/folder.png"}}
    end
    if File("/sdcard/tencent/TIMfile_recv").exists()==true then
      shortcutAdp.add{shortcutTitle="TIM文件下载目录",shortcutPath="/sdcard/tencent/TIMfile_recv",shortcutIcon={src="res/folder.png"}}
    end
    if File("/sdcard/tencent/Tim_Images").exists()==true then
      shortcutAdp.add{shortcutTitle="Tim保存的图片",shortcutPath="/sdcard/tencent/Tim_Images",shortcutIcon={src="res/folder.png"}}
    end
    if File("/sdcard/DCIM/").exists()==true then
      shortcutAdp.add{shortcutTitle="相机",shortcutPath="/sdcard/DCIM",shortcutIcon={src="res/folder.png"}}
    end
    if File("/sdcard/Pictures").exists()==true then
      shortcutAdp.add{shortcutTitle="图片库",shortcutPath="/sdcard/Pictures",shortcutIcon={src="res/folder.png"}}
    end
    -- shortcutAdp.add{shortcutTitle="内部目录",shortcutPath="/data/user/0/com.pretend.appluag",shortcutIcon={src="res/folder.png"}}
   
    shortcutListId.setAdapter(shortcutAdp)
    shortcutListId.onItemClick=function(l,v,p,s)
      local path=tostring(v.Tag.shortcutPath.Text)
      SetItem(path)
      pageShow(0)
    end

    function pageShow(number)
      pageview.showPage(number)
    end
    pageview.setOnPageChangeListener(PageView.OnPageChangeListener{
      onPageScrolled=function(a,b,c)
        local w=activity.getWidth()/2
        local wd=c/2
        if a==0 then
          psdm.setX(wd)
        end
        if a==1 then
          psdm.setX(wd+w)
        end
      end,
    })
    SetItem(StartPath)
  end

