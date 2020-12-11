require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"


--activity.setContentView(loadlayout("layout"))

import"func.views"

rdata = require"func.data"

local page = id_transmission_page
local label = id_transmission_label
local arr_pages = {
  label.getChildAt(0), -- download
  label.getChildAt(1), -- upload
  label.getChildAt(2) -- offline download
}


Ripple(arr_pages,"方",0xFFECECEC)


arr_pages[1].onClick = function()
  page.showPage(0)
end

arr_pages[2].onClick = function()
  page.showPage(1)
end

arr_pages[3].onClick = function()
  page.showPage(2)
end



import "android.graphics.Color"
page.onPageChangeListener={
  onPageSelected=function (p)
    for k,v in ipairs(arr_pages) do
      local colors = (k==(p+1)) and "#FF757575" or "#FFFAFAFA"
      local ashline = v.getChildAt(1)
      setViewColor(ashline, Color.parseColor(colors))

    end
  end}





local item = {
  LinearLayout;
  layout_height="8%h";
  gravity="center";
  layout_width="-1";
  {
    LinearLayout;
    layout_height="fill";
    gravity="center";
    layout_width="10%w";
    {
      ImageView;
      layout_height="fill";
      layout_width="fill";
      src="src/file.png";
    };
  };
  {
    LinearLayout;
    layout_height="fill";
    layout_marginLeft="8dp";
    gravity="center";
    layout_width="70%w";
    orientation="vertical";
    {
      TextView;
      text="获取失败";
      id="filename";
      textSize="15sp";
      layout_gravity="left";
    };
    {
      ProgressBar;
      style="?android:attr/progressBarStyleHorizontal";
      layout_width="fill";
      layout_height="3dp";
      id="bar";
    };
    {
      LinearLayout;
      layout_gravity="right";
      gravity="center";
      layout_width="fill";
      --   layout_marginTop="-5dp";
      {
        LinearLayout;
        layout_weight="1";
        {
          TextView;
          text="暂停中";
          textSize="13sp";
        };
      };
      {
        LinearLayout;
        layout_weight="1";
        gravity="right";
        {
          TextView;
          text="2.6MB/1.4GB";
          id="state";
        };
      };
    };
  };
  {
    LinearLayout;
    layout_width="10%w";
    layout_marginLeft="8dp";
    layout_height="fill";
    gravity="center";
    {
      ImageView;
      layout_width="fill";
      layout_height="fill";
      src="src/suspend.png";
    };
  };
};



local styles = require"func.style"

local data_download = {
  --[[
  {
    path = ""
    filename={text="测试文件1"},
    state={text="1012.2MB/1.8TB"},
    bar={max=100,progress=1,ProgressDrawable = styles.progress();}
  },
  {
    path = ""
    filename={text="测试文件2"},
    state={text="214MB/1.2GB"},
    bar={max=100,progress=20,ProgressDrawable = styles.progress();}
  }
]]
}



function getUrlFilesize(url)
  import "java.net.URL"
  local realUrl = URL(url)-- 打开和URL之间的连接
  local con = realUrl.openConnection();
  local length=con.getContentLength(); --获取网络文件大小
  con.disconnect()
  return length
end



--[[
data{
  name: 文件名称
  path: 下载路径
  size: 文件总大小
  md5 : 总文件MD5
  url : 文件链接
  id  : 分配的id 用于管理下载
  }
--]]

-- 数据调度通知
function download_createData(arr_n, fun_c)
  local data = rdata.getData("download_data")
  if data == nil or #data == 0 then
    rdata.setData("download_data",{})
   else
    local ids = table.find(data, arr_n.id)
    fun_c(ids)
  end
end


--download_createData({})




function addDownlist(url,fun_c)
  Http.download(url, "/sdcard/couldDownload/", function(code, body)
  end)
  table.insert(data_download, {
    path = "",
    filename={text="测试文件1"},
    state={text="0/"..getUrlFilesize(url)},
    bar={max=100,progress=1,ProgressDrawable = styles.progress()}
  })
end



--[[
getDownurl("LjxgTk",function(code, body)
  Errorhandle(code,body,function()
    addDownlist(body.data)
  end)
end)
--]]


-- url
-- bar.max progress
adp_trans = LuaAdapter(activity, data, item)
id_list_download.Adapter = adp_trans




--[[ download_progress_v1
{ 
  type:onedrive_id / linear
  data:{
    id:
    }
  name:
  path:
  size:
  state: start/suspend/wait/complete
  }

--]]

--[[ download_complete_v1

--]]



adp_trans.notifyDataSetChanged()



id_list_download.setEmptyView(id_empty_download)
id_list_upload.setEmptyView(id_empty_upload)
id_list_offline.setEmptyView(id_empty_offline)

