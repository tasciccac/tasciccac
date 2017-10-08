//  Copyright (C) 2016 tasciccac.
//
//  tasciccac is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  tasciccac is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with tasciccac.  If not, see <http://www.gnu.org/licenses/>.
//
// 1 => Same index as price
// 2 => chikou
// 3 => Tenkan-sen
// 4 => Kijun-sen
// 5 => Senkou span A
// 6 => Senkou span B

// Mean of the higher and the lower of last period
function extremaMean=FExtremaMean(priceHistory,Period)
  [n m]=size(priceHistory);
  extremaMean=priceHistory(:,1:2);
  extremaMean(:,2)=zeros(n)+%nan;

  for i=Period:n
    extremaMean(i,2)=(max(priceHistory(i-Period+1:i,3))+min(priceHistory(i-Period+1:i,4)))/2;
  end
endfunction

function chikou=getChikou(priceHistory,midPeriod)
  chikou=[priceHistory(1:$-midPeriod,1) priceHistory(midPeriod+1:$,5)];
endfunction


function tenkan=getTenkan(priceHistory,shortPeriod)
  tenkan=FExtremaMean(priceHistory,shortPeriod);
endfunction

function kijun=getKijun(priceHistory,midPeriod)
  kijun=FExtremaMean(priceHistory,midPeriod);
endfunction

function ichimokuCloud=getIchimokuCloud(priceHistory,varargin)
  shortPeriod=9;
  midPeriod=26;
  
  if (isempty(varargin) == %f) then
    nin=size(varargin);
    if (nin >= 1) then
      shortPeriod = varargin(1);
    end
    if (nin >= 1) then
      midPeriod = varargin(2);
    end
  end
  
  tenkan=getTenkan(priceHistory,shortPeriod);
  kijun=getKijun(priceHistory,midPeriod);
  chikou=getChikou(priceHistory,midPeriod);

  [n m]=size(priceHistory);
  ichimokuCloud=zeros(n+midPeriod,6)+%nan;
  ichimokuCloud(:,1)=[1:n+midPeriod]';
  ichimokuCloud(1:$-2*midPeriod,2)=chikou(:,2);
  ichimokuCloud(1:$-midPeriod,3)=tenkan(:,2);
  ichimokuCloud(1:$-midPeriod,4)=kijun(:,2);

  //SenkouA
  //Mean of Tenkan and Kijun projected midPeriod period ahead
  ichimokuCloud(midPeriod+1:$,5)=(tenkan(:,2)+kijun(:,2))/2;

  //SenkouB
  senkouB=FExtremaMean(priceHistory,midPeriod*2);
  ichimokuCloud(midPeriod+1:$,6)=senkouB(:,2);
endfunction



// Draw an Ichimoku cloud on the current figure
function hKumo=drawIchimokuCloud(priceHistory,varargin)
  // optionnal argument to draw lines
  bDisplayLine = %t;
  if (isempty(varargin)==%f) then
    bDisplayLine = varargin(1);
  end

  n=size(priceHistory,'r');
  ICH_shortPeriod=9;
  ICH_MidPeriod=26;
  // Color of cloud
  // When Senkou A > Senkou B
  // #B8FFB8
  cloudColorWhenSAGSB=color(152+32,255,152+32);
  //    cloudColorWhenSALSB=color('palegreen');
  // #BFEFFF
  cloudColorWhenSALSB=color("lightblue1");

  ichimokuCloud=getIchimokuCloud(priceHistory,ICH_shortPeriod,ICH_MidPeriod);
  
  SSA_Greater_SSB_x=(ichimokuCloud(:,5) >= ichimokuCloud(:,6));
  twist_x = find((SSA_Greater_SSB_x(2:$) <> SSA_Greater_SSB_x(1:$-1)) == %t);

  clouds=list();
  cloud_handles = [];
  
  cloud_startx = ICH_MidPeriod*3;
  cloud_starty = (ichimokuCloud(cloud_startx,5)+ichimokuCloud(cloud_startx,6))/2;
  
  cloud_endx = %nan;
  cloud_endy = %nan;

  if (isempty(twist_x) == %f) then
    twist_x = twist_x + 1;
    if (twist_x(1) > cloud_startx) then
      // Trace the bear cloud first
      cloud_x = [cloud_startx:twist_x(1)-1];
      cloud_ssb_y = ichimokuCloud(cloud_startx:twist_x(1)-1,6)';
      cloud_ssa_y = ichimokuCloud(cloud_startx:twist_x(1)-1,5)';
      
      // Remove fill when SSA == SSB
      while (cloud_ssb_y(1) == cloud_ssa_y(1)) do
        if (size(cloud_ssb_y,'*') > 1) then
          cloud_startx=cloud_x(1);
          cloud_starty=cloud_ssb_y(1);
          cloud_x=cloud_x(2:$);
          cloud_ssb_y=cloud_ssb_y(2:$);
          cloud_ssa_y=cloud_ssa_y(2:$);
        else
          break;
        end
      end
      
      // Add the end of cloud
      [a1 b1] = reglin([twist_x(1)-1 twist_x(1)], [ichimokuCloud(twist_x(1)-1,5) ichimokuCloud(twist_x(1),5)]);
      [a2 b2] = reglin([twist_x(1)-1 twist_x(1)], [ichimokuCloud(twist_x(1)-1,6) ichimokuCloud(twist_x(1),6)]);
      cloud_endx=(b1-b2)/(a2-a1);
      cloud_endy=a1*cloud_endx+b1;
  
      cloud.x = [cloud_startx cloud_x cloud_endx flipdim(cloud_x,2) cloud_startx];
      cloud.y = [cloud_starty cloud_ssb_y cloud_endy flipdim(cloud_ssa_y,2) cloud_starty];
      cloud.type = 'bearish';
  
      xfpoly(cloud.x, cloud.y,-cloudColorWhenSALSB);
      cloud_handles=[cloud_handles gce()];
      
      clouds(0) = cloud;
      
      cloud_startx = cloud_endx;
      cloud_starty = cloud_endy;
    else
      
    end
  end

  for i=1:1:size(twist_x,'*')-1
    cloud_x = [twist_x(i):twist_x(i+1)-1];
    cloud_ssa_y = ichimokuCloud(cloud_x,5)';
    cloud_ssb_y = ichimokuCloud(cloud_x,6)';

    // Remove fill when SSA == SSB
    while (cloud_ssb_y(1) == cloud_ssa_y(1)) do
      if (size(cloud_ssb_y,'*') > 1) then
        cloud_startx=cloud_x(1);
        cloud_starty=cloud_ssb_y(1);
        cloud_x=cloud_x(2:$);
        cloud_ssb_y=cloud_ssb_y(2:$);
        cloud_ssa_y=cloud_ssa_y(2:$);
      else
        break;
      end
    end

    // Add the end of cloud
    [a1 b1] = reglin([twist_x(i+1)-1 twist_x(i+1)], [ichimokuCloud(twist_x(i+1)-1,5) ichimokuCloud(twist_x(i+1),5)]);
    [a2 b2] = reglin([twist_x(i+1)-1 twist_x(i+1)], [ichimokuCloud(twist_x(i+1)-1,6) ichimokuCloud(twist_x(i+1),6)]);
    cloud_endx=(b1-b2)/(a2-a1);
    cloud_endy=a1*cloud_endx+b1;

//    cloud_x = [cloud_x ix];
//    cloud_y = [cloud_y iy];

    cloud.x = [cloud_startx cloud_x cloud_endx flipdim(cloud_x,2)];
    cloud.y = [cloud_starty cloud_ssa_y cloud_endy flipdim(cloud_ssb_y,2)];

    // Find the offset where SSA <> SSB
    offset=0;
    while (ichimokuCloud(twist_x(i)+offset,5) == ichimokuCloud(twist_x(i)+offset,6)) then
      offset = offset + 1;
      if ((twist_x(i)+offset) > size(ichimokuCloud,'r')) then
        offset = offset - 1;
        break;
      end
    end

    if (ichimokuCloud(twist_x(i)+offset,5) > ichimokuCloud(twist_x(i)+offset,6)) then
      xfpoly(cloud.x, cloud.y, -cloudColorWhenSAGSB);
      cloud.type = 'bullish';
    else
      xfpoly(cloud.x, cloud.y, -cloudColorWhenSALSB);
      cloud.type = 'bearish';
    end

    clouds(0) = cloud;
    cloud_handles=[cloud_handles gce()];

    cloud_startx = cloud_endx;
    cloud_starty = cloud_endy;
  end
  
  // Trace the last Cloud
  if (isnan(cloud_endx) == %f) then
    cloud_startx = cloud_endx;
    cloud_starty = cloud_endy;
  end

  if (isempty(twist_x) == %f) then
    cloud_x = twist_x($):n+ICH_MidPeriod;
  else
    cloud_x = cloud_startx:n+ICH_MidPeriod;
    twist_x = cloud_startx;
  end

  cloud_ssa_y = ichimokuCloud(cloud_x,5)';
  cloud_ssb_y = ichimokuCloud(cloud_x,6)';

  // Remove fill when SSA == SSB
  while (cloud_ssb_y(1) == cloud_ssa_y(1)) do
    if (size(cloud_ssb_y,'*') > 1) then
      cloud_startx=cloud_x(1);
      cloud_starty=cloud_ssb_y(1);
      cloud_x=cloud_x(2:$);
      cloud_ssb_y=cloud_ssb_y(2:$);
      cloud_ssa_y=cloud_ssa_y(2:$);
    else
      break;
    end
  end


  cloud.x = [cloud_startx cloud_x flipdim(cloud_x,2)];
  cloud.y = [cloud_starty cloud_ssa_y flipdim(cloud_ssb_y,2)];

  // Find the offset where SSA <> SSB
  offset=0;
  
  while (ichimokuCloud(twist_x($)+offset,5) == ichimokuCloud(twist_x($)+offset,6)) then
    offset = offset + 1;
    if ((twist_x($)+offset) > size(ichimokuCloud,'r')) then
      offset = offset - 1;
      break;
    end
  end
  
  if (ichimokuCloud(twist_x($)+offset,5) > ichimokuCloud(twist_x($)+offset,6)) then
    xfpoly(cloud.x, cloud.y, -cloudColorWhenSAGSB);
    cloud.type = 'bullish';
  else
    xfpoly(cloud.x, cloud.y, -cloudColorWhenSALSB);
    cloud.type = 'bearish';
  end

  cloud_handles=[cloud_handles gce()];

  // Group all cloud entity
  glue(cloud_handles);

  // SenkouA #00BFFF
  plot2d(ichimokuCloud(:,1),ichimokuCloud(:,5),style=[color("deepskyblue")]);
  hSsa=gce();
  hSsa.tag="SSA";
  hSsa.user_data=[ichimokuCloud($-26,5)];
  // SenkouB
  plot2d(ichimokuCloud(:,1),ichimokuCloud(:,6),style=[color("green")]);
  hSsb=gce();
  hSsb.tag="SSB";
  hSsb.user_data=[ichimokuCloud($-26,6)];

  hKumo=[hSsa hSsb];

  if (bDisplayLine == %t) then
    hIchiLines = displayIchimokuLines(priceHistory);
    hKumo=[hKumo hIchiLines];
  end
endfunction



function hIchimokuLines=displayIchimokuLines(priceHistory)
  [n m]=size(priceHistory);
  ICH_shortPeriod=9;
  ICH_MidPeriod=26;
  ichimokuCloud=getIchimokuCloud(priceHistory,ICH_shortPeriod,ICH_MidPeriod);

  nbUTTenkanExt = 5;

  for i=1:nbUTTenkanExt
    // Add Tenkan Extension
    ichimokuCloud($-26+i,3) = (min(priceHistory($-ICH_shortPeriod+1+i:$,4))+max(priceHistory($-ICH_shortPeriod+1+i:$,3)))/2;
  end

  nbUTKijunExt = 14;
  for i=1:nbUTKijunExt
    // Add Kijun Extension
    ichimokuCloud($-26+i,4) = (min(priceHistory($-ICH_MidPeriod+1+i:$,4))+max(priceHistory($-ICH_MidPeriod+1+i:$,3)))/2;
  end

  // Tenkan #B00000
  plot2d(ichimokuCloud(1:$-26,1),ichimokuCloud(1:$-26,3),style=[color("scilabred3")]);
  hTenkan=gce();
  hTenkan.tag="Tenkan";
  hTenkan.user_data=[ichimokuCloud($-26,3)];
  hTenkan.children(1).thickness=2;
  // Tenkan Extension
  plot2d(ichimokuCloud($-26:$-26+nbUTTenkanExt,1),ichimokuCloud($-26:$-26+nbUTTenkanExt,3),style=[color("scilabred3")]);
  hTenkanExt=gce();
  hTenkanExt.tag="TenkanExt";
  hTenkanExt.children(1).thickness=2;
  hTenkanExt.children(1).line_style=5;

  // Kijun #228B22
  plot2d(ichimokuCloud(1:$-26,1),ichimokuCloud(1:$-26,4),style=[color("forestgreen")]);
  hKijun=gce();
  hKijun.tag="Kijun";
  hKijun.user_data=[ichimokuCloud($-26,4)];
  hKijun.children(1).thickness=3;
  // Kijun Extension
  plot2d(ichimokuCloud($-26:$-26+nbUTKijunExt,1),ichimokuCloud($-26:$-26+nbUTKijunExt,4),style=[color("forestgreen")]);
  hKijunExt=gce();
  hKijunExt.tag="KijunExt";
  hKijunExt.children(1).thickness=3;
  hKijunExt.children(1).line_style=5;

  //Chikou #0000D0
  plot2d(ichimokuCloud(:,1),ichimokuCloud(:,2),style=[color("blue2")]);
  hChikou=gce();
  hChikou.tag="Chikou";
  hChikou.user_data=[ichimokuCloud($-52,2)];
  hChikou.children(1).thickness=2

  hIchimokuLines=[hChikou hTenkan hKijun];
  
endfunction


