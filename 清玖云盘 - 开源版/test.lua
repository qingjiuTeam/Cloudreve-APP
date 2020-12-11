require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
activity.setTitle('程序标题')
activity.setTheme(R.Theme_AppLua14)
activity.setContentView(loadlayout("layout"))




function 指南()
  InputLayout={
    LinearLayout;
    Focusable=true;
    FocusableInTouchMode=true;
    orientation="vertical";
    {
      ScrollView;
      layout_width="80%w";
      layout_gravity="center";
      layout_height="70%w";
      id="lis",
      {
        TextView;
        layout_width="-1";
        layout_height="-2";
        TextSize="1.4%w",
        text=[[
+如何返回上一级文件夹
-按返回键即可
            
+搜索为什么只搜索当前文件夹
-默认搜索当前文件夹，按下回车即可搜索全局哦

+分享设置时间/次数为什么没有用
-分享时间和次数必须同时存在的哦
 后端原因我也没办法(；一_一)
 
+为什么有bug迟迟不修
-开发者只有节假日才在线嗷
 所以一般是周更
 或者是这个bug不好修复
 且优先级不是太高
 
+UI好丑
-会改的，别骂了T_T
 有相关建议也可以提
 有助app更快改进
 
+为什么有些文件上传会闪退
-技术问题，若解决会使app体积增大,
 但我不喜欢，所以看看有没有其他解决办法
 ]],
      };
    };
  };



  local lise= AlertDialog.Builder(this)
  .setTitle("使用指南")
  .setView(loadlayout(InputLayout))
  .setPositiveButton("确定",nil)
  .setNegativeButton("取消",nil)
  .show()

  import "android.graphics.drawable.GradientDrawable"
  local radiu=25
  lise.getWindow().setBackgroundDrawable(GradientDrawable().setCornerRadii({radiu,radiu,radiu,radiu,radiu,radiu,radiu,radiu}).setColor(0xFFFFFFFF))

end
指南()

