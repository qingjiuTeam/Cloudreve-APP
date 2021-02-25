local lay = {
  LinearLayout;
  layout_width="-1";
  layout_height="56dp";
  {
    LinearLayout;
    layout_width="48dp";
    gravity="center";
    layout_height="fill";
    {
      ImageView;
      layout_width="26dp";
      layout_height="fill";
      id="icon"

    };
  };
  {
    LinearLayout;
    layout_gravity="center";
    gravity="left";
    orientation="vertical";
    layout_weight="1";
    {
      TextView;
      textSize="16sp";
      id="filename";
      text="{filename}";
      textColor="#616161";
      singleLine=true;
      ellipsize='middle';
      -- typeface={nil,1};
    };
    {
      TextView;
      layout_marginTop="0dp";
      textSize="14sp";
      textColor="#9E9E9E";
      id="info";
      text="1980-01-01 08:00 {size}MB";
    };
  };
  {LinearLayout;
    layout_height="fill";
    layout_width="42dp";
    layout_marginEnd="10dp";
    onClick="func_foder_menu_Onclick";
    {TextView;id="ids";TextSize=0};
    {
      ImageView;
      layout_width="26dp";
      layout_height="fill";
      layout_gravity="center";
      src="src/menu";
    };
  };
};

return lay