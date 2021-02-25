require"import"
import "android.graphics.drawable.LayerDrawable"
import "android.graphics.drawable.ClipDrawable"
import "android.graphics.drawable.GradientDrawable"

_M = {}

function _M.progress(int_bak, int_col, int_radius)
  local roundRadius = int_radius or 15
  local colors = int_col or 0xFF000000     --主色
  local colors2 = int_bak or 0xffFFD7D7D7  --背景
  --8dp 圆角半径 The x-radius of the oval used to round the corners

  -- 准备progressBar带圆角的背景Drawable
  local  progressBg = GradientDrawable();
  -- 设置圆角弧度
  progressBg.setCornerRadius(roundRadius);
  -- 设置绘制颜色
  progressBg.setColor(colors2);

  -- 准备progressBar带圆角的进度条Drawable
  local progressContent = GradientDrawable();
  progressContent.setCornerRadius(roundRadius);
  -- 设置绘制颜色，此处可以自己获取不同的颜色
  progressContent.setColor(colors);
  -- ClipDrawable是对一个Drawable进行剪切操作，可以控制这个drawable的剪切区域，以及相相对于容器的对齐方式
  local progressClip = ClipDrawable(progressContent, Gravity.LEFT, ClipDrawable.HORIZONTAL);
  -- Setup LayerDrawable and assign to progressBar

  -- 待设置的Drawable数组
  local progressDrawables = {progressBg, progressClip};
  local progressLayerDrawable = LayerDrawable(progressDrawables);
  -- 根据ID设置progressBar对应内容的Drawable
  progressLayerDrawable.setId(0, android.R.id.background);
  progressLayerDrawable.setId(1, android.R.id.progress);
  return progressLayerDrawable
end


return _M