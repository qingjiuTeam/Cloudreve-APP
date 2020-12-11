require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"


import"func.views"



local _M = {}

function _M.Load(...)--加载框
  local dl=ProgressDialog.show(activity, nil, ...).show()
   dl.setCanceledOnTouchOutside(true)--可取消

  -- .setCancelable(true)--设置是否可以通过点击Back键取消
  -- .setCanceledOnTouchOutside(false)--设置在点击Dialog外是否取消Dialog进度条

  local params = dl.getWindow().getAttributes();
  params.alpha = 0.9;--透明度
  --params.indeterminateTint=0xffffffff--布局表中可以设置圈圈颜色 但这里不行
  --params.height=1000
  --params.gravity = Gravity.CENTER
  params.dimAmount = 0.0--背景灰度值
  --dl.getWindow().setAttributes(params)--应用效果 尽量在show后
  --print(params)

  import "android.graphics.PorterDuff"
  import "android.graphics.PorterDuffColorFilter"
  dl.getWindow().findViewById(android.R.id.progress).IndeterminateDrawable.setColorFilter(PorterDuffColorFilter(0xFF444444,PorterDuff.Mode.SRC_ATOP))

  --print(a)
  --a.setColorFilter(0x4bff5dff,PorterDuff.Mode.SRC_ATOP)
  --print(params,v)
  fillet(dl,12)
  return dl
end
--dlPregress(nil,"标题")



function _M.Alert(title,text,b1,bc1,b2,bc2,b3,bc3)
  local dl=AlertDialog.Builder(this)
  .setTitle(title)
  .setMessage(text)
  .setPositiveButton(b1,bc1)
  .setNegativeButton(b2,bc2)
  .setNeutralButton(b3,bc3)

  local dl=dl.show()

  --[[
  params = dl.getWindow().getAttributes();
  params.alpha = 0.95;--透明度
  --params.indeterminateTint=0xffffffff--布局表中可以设置圈圈颜色 但这里不行
  --params.height=1000
  --params.gravity = Gravity.CENTER
  params.dimAmount = 0.0--背景灰度值
  --dl.getWindow().setAttributes(params)--应用效果 尽量在show后
  --print(params)
--]]

  dl.getButton(dl.BUTTON_POSITIVE).setTextColor(0xFF444444)
  dl.getButton(dl.BUTTON_NEGATIVE).setTextColor(0xFF444444)
  dl.getButton(dl.BUTTON_NEUTRAL).setTextColor(0xFF444444)
  fillet(dl,12)
  return dl
end





return _M
