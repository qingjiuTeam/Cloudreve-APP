local lay = {
  LinearLayout;
  layout_width="-1";
  layout_height="8%h";
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
    layout_width="fill";
    {
      TextView;
      textSize="16sp";
      id="filename";
      text="{filename}";
      singleLine=true;
      ellipsize='middle';
    };
    {
      TextView;
      layout_marginTop="0dp";
      textSize="14sp";
      id="info";
      text="1980-01-01 08:00 {size}MB";
    };
  };
};

return lay