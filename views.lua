require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"

local _M = {}




_M.CardandText = function(key)
  -- text,icon,color,clic
  return {LinearLayout;
    layout_weight="1";
    gravity="center";
    orientation="vertical";
    {CardView;
      background=key.color or "#90CAF9";
      layout_height="60dp";
      layout_width="60dp";
      elevation=key.elv;
      radius="36dp";
      onClick=key.click or nil;
      {LinearLayout;
        layout_width="fill";
        layout_height="fill";
        gravity="center";
        id=key.id;
        {ImageView;
          layout_gravity="center";
          src=key.icon or "src/addpro";
          layout_width="34dp";
          layout_height="34dp";
          -- colorFilter="#ffffff";
          id="close";
        };
      };
    };
    {TextView;
      layout_gravity="center";
      text=key.text or "错误";
      layout_marginTop="8dp";
      textColor="#424242";
      typeface={nil,1};
    };
  };
end

_M.splitLine = function(key)
  return {LinearLayout;
    layout_marginTop="16dp";
    layout_gravity=key.gravity or "top|center";
    layout_width=key.width or "90%w";
    layout_height=key.line or "1";
    background=key.color or "#BDBDBD";
  }
end



return _M