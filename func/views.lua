import "android.R$color"
import "android.graphics.PorterDuff"
import "android.widget.TextView"
import "android.content.res.ColorStateList"
import "android.R$id"
import "android.widget.LinearLayout"
import "android.widget.ImageView"
import "android.graphics.Color" -- RippleArr
import "android.graphics.drawable.GradientDrawable"

function RippleArr(view,arr)
  --[[
  圆角(view,{m={宽度,颜色},t={颜色},y={r1,r2,r3,r4} 
  ]]
  local drawable = GradientDrawable()--初始化对象
  --drawable.setShape(GradientDrawable.RECTANGLE)
  if arr.m~=nil then--描边
    --设置边框 : 宽度 颜色
    drawable.setStroke(2, Color.parseColor("#000000"))
  end

    --设置填充色
    InsideColor = Color.parseColor(arr.t or "#ffffff")
    drawable.setColor(InsideColor)
  
  if arr.y~=nil then--圆角
    --设置圆角 : 左上 右上 右下 左下
    local y1,y2,y3,y4 = tonumber(arr.y[1]),tonumber(arr.y[2]),tonumber(arr.y[3]),tonumber(arr.y[4])
    drawable.setCornerRadii({y1,y1,y2,y2,y3,y3,y4,y4});
  end

  view.setBackgroundDrawable(drawable)
end


function Ripple(id,lx,color)
  xpcall(function()
    ripple = activity.obtainStyledAttributes({android.R.attr.selectableItemBackgroundBorderless}).getResourceId(0,0)
    ripples = activity.obtainStyledAttributes({android.R.attr.selectableItemBackground}).getResourceId(0,0)
    for index,content in ipairs(id) do
      if lx=="圆" then
        content.setBackgroundDrawable(activity.Resources.getDrawable(ripple).setColor(ColorStateList(int[0].class{int{}},int{color})))
      end
      if lx=="方" then
        content.setBackgroundDrawable(activity.Resources.getDrawable(ripples).setColor(ColorStateList(int[0].class{int{}},int{color})))
      end
    end
  end,function(e)
  end)
end

function getChilds(v, ...)
  local ints = {...}
  for i=1 , #ints do
    v = v.getChildAt(ints[i])
  end
  return v
end

function setScaleXY(view_id, int_a, int_b)
  local int_b = int_b or int_a
  local view_id = type(view_id) ~= "table" and {view_id} or view_id
  for k,v in ipairs(view_id) do
    v.setScaleX(int_a)--设置X轴缩放
    v.setScaleY(int_b)--设置Y轴缩放
  end
end

function setViewColor(view_id, int_c)
  local view_id = type(view_id) ~= "table" and {view_id} or view_id
  for k,v in ipairs(view_id) do

    if luajava.instanceof(v,TextView) then
      v.setTextColor(int_c)
     elseif luajava.instanceof(v,ImageView) then
      v.setColorFilter(int_c,PorterDuff.Mode.SRC_ATOP)
     elseif luajava.instanceof(v,LinearLayout) then
      v.setBackgroundColor(int_c)
    end

  end
end


function fillet(view_id,int_rad)
  import "android.graphics.drawable.GradientDrawable"
  local radiu=int_rad
  view_id.getWindow().setBackgroundDrawable(GradientDrawable().setCornerRadii({radiu,radiu,radiu,radiu,radiu,radiu,radiu,radiu}).setColor(0xffffffff))
end



import "android.graphics.drawable.ColorDrawable"
import "android.graphics.PorterDuffColorFilter"

function setSwitchColor(view_v, int_a, int_b)
  -- 按钮
  view_v.ThumbDrawable.setColorFilter(PorterDuffColorFilter(int_a,PorterDuff.Mode.SRC_ATOP));
  -- 背景
  view_v.TrackDrawable.setColorFilter(PorterDuffColorFilter(int_b,PorterDuff.Mode.SRC_ATOP))
end

function setDialogButtonColor(view_v, int_a, int_b, int_c)
  view_v.getButton(view_v.BUTTON_POSITIVE).setTextColor(int_a or 0xFF444444)
  view_v.getButton(view_v.BUTTON_NEGATIVE).setTextColor(int_b or 0xFF444444)
  view_v.getButton(view_v.BUTTON_NEUTRAL).setTextColor(int_c or 0xFF444444)
end

function setEditLineColor(view_edit, int_a)
  view_edit.getBackground().setColorFilter(PorterDuffColorFilter(int_a or 0xFF444444,PorterDuff.Mode.SRC_ATOP));
end