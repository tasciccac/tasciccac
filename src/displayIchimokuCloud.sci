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
// 3 => tenkan
// 4 => kijun
// 5 => senkouA
// 6 => senkouB

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

function ichimokuCloud=getIchimokuCloud(priceHistory,shortPeriod,midPeriod)
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


function hKumo=displayIchimokuCloud(priceHistory,varargin)
  bDisplayLine = %T;
  if (isempty(varargin)==%F) then
    bDisplayLine = varargin(1);
  end

  [n m]=size(priceHistory);
  ICH_shortPeriod=9;
  ICH_MidPeriod=26;
  // Color of cloud
  // When Senkou A > Senkou B
  cloudColorWhenSAGSB=color("lightblue1");
  //    cloudColorWhenSALSB=color('palegreen');
  cloudColorWhenSALSB=color(152+32,255,152+32);

  ichimokuCloud=getIchimokuCloud(priceHistory,ICH_shortPeriod,ICH_MidPeriod);

  // Build xpoly
  // Compare SSA & SSB
  if (ichimokuCloud(ICH_MidPeriod+ICH_MidPeriod*2,5) >= ichimokuCloud(ICH_MidPeriod+ICH_MidPeriod*2,6)) then
    bSenkAGreatThanSenkB = %T;
  else
    bSenkAGreatThanSenkB = %F;
  end
  startOfCloud=ICH_MidPeriod+ICH_MidPeriod*2+1;
  startOfCloud_ix=startOfCloud;
  startOfCloud_iy=ichimokuCloud(startOfCloud_ix,5);

  cloudBorderA=[];
  cloudBorderB=[];
  cloud_handles=[];
  for i=ICH_MidPeriod+ICH_MidPeriod*2+1:n+ICH_MidPeriod
    // Build border of polygone
    if (bSenkAGreatThanSenkB == %T) then
      if (ichimokuCloud(i,5) >= ichimokuCloud(i,6))  then
        // Always in the same cloud
        cloudBorderA=[cloudBorderA ichimokuCloud(i,5)];
        cloudBorderB=[cloudBorderB ichimokuCloud(i,6)];
      else
        // The cloud change Trace the previous Cloud
        // Add the intersection point
        [a1 b1]=reglin([i-1 i],[ichimokuCloud(i-1,5) ichimokuCloud(i,5)]);
        [a2 b2]=reglin([i-1 i],[ichimokuCloud(i-1,6) ichimokuCloud(i,6)]);
        ix=(b1-b2)/(a2-a1);
        iy=a1*ix+b1;

        xfpoly([startOfCloud_ix startOfCloud:i-1 ix i-1:-1:startOfCloud startOfCloud_ix],[startOfCloud_iy cloudBorderA iy flipdim(cloudBorderB,2) startOfCloud_iy],-cloudColorWhenSAGSB);
        e=gce();
        cloud_handles=[cloud_handles e];
        cloudBorderA=[ichimokuCloud(i,5)];
        cloudBorderB=[ichimokuCloud(i,6)];
        startOfCloud=i;
        startOfCloud_ix=ix;
        startOfCloud_iy=iy;

        bSenkAGreatThanSenkB=%F;
      end
    elseif (ichimokuCloud(i,5) < ichimokuCloud(i,6))  then
      // Always in the same cloud
      cloudBorderA=[cloudBorderA ichimokuCloud(i,5)];
      cloudBorderB=[cloudBorderB ichimokuCloud(i,6)];
    else
      // The cloud change Trace the previous Cloud
      // Add the intersection point
      [a1 b1]=reglin([i-1 i],[ichimokuCloud(i-1,5) ichimokuCloud(i,5)]);
      [a2 b2]=reglin([i-1 i],[ichimokuCloud(i-1,6) ichimokuCloud(i,6)]);
      ix=(b1-b2)/(a2-a1);
      iy=a1*ix+b1;
      xfpoly([startOfCloud_ix startOfCloud:i-1 ix i-1:-1:startOfCloud startOfCloud_ix],[startOfCloud_iy cloudBorderA iy flipdim(cloudBorderB,2) startOfCloud_iy],-cloudColorWhenSALSB);
      e=gce();
      cloud_handles=[cloud_handles e];

      cloudBorderA=[ichimokuCloud(i,5)];
      cloudBorderB=[ichimokuCloud(i,6)];
      startOfCloud=i;
      startOfCloud_ix=ix;
      startOfCloud_iy=iy;
      bSenkAGreatThanSenkB=%T;
    end
  end
  // Trace the last Cloud
  if (bSenkAGreatThanSenkB==%T) then
    xfpoly([startOfCloud_ix startOfCloud:n+ICH_MidPeriod n+ICH_MidPeriod:-1:startOfCloud startOfCloud_ix],[startOfCloud_iy cloudBorderA flipdim(cloudBorderB,2) startOfCloud_iy],-cloudColorWhenSAGSB);
    e=gce();
    cloud_handles=[cloud_handles e];
  else
    xfpoly([startOfCloud_ix startOfCloud:n+ICH_MidPeriod n+ICH_MidPeriod:-1:startOfCloud startOfCloud_ix],[startOfCloud_iy cloudBorderA flipdim(cloudBorderB,2) startOfCloud_iy],-cloudColorWhenSALSB);
    e=gce();
    cloud_handles=[cloud_handles e];
  end
  // Group all cloud entity
  glue(cloud_handles);

  // SenkouA
  plot2d(ichimokuCloud(:,1),ichimokuCloud(:,5),style=[color("deepskyblue")]);
  hSsa=gce();
  // SenkouB
  plot2d(ichimokuCloud(:,1),ichimokuCloud(:,6),style=[color("green")]);
  hSsb=gce();
  hSsa.tag="SSA";
  hSsa.user_data=[ichimokuCloud($-26,5)];
  hSsb.tag="SSB";
  hSsb.user_data=[ichimokuCloud($-26,6)];

  hKumo=[hSsa hSsb];

  if (bDisplayLine == %T) then
    hIchiLines = displayIchimokuLines(priceHistory);
    hKumo=[hKumo hIchiLines];
  end
endfunction

function hIchimokuLines=displayIchimokuLines(priceHistory)
  [n m]=size(priceHistory);
  ICH_shortPeriod=9;
  ICH_MidPeriod=26;
  ichimokuCloud=getIchimokuCloud(priceHistory,ICH_shortPeriod,ICH_MidPeriod);
  //Chikou
  plot2d(ichimokuCloud(:,1),ichimokuCloud(:,2),style=[color("blue2")]);
  hChikou=gce();
  hChikou.tag="Chikou";
  hChikou.user_data=[ichimokuCloud($-52,2)];
  hChikou.children(1).thickness=2
  // Tenkan
  plot2d(ichimokuCloud(:,1),ichimokuCloud(:,3),style=[color("scilabred3")]);
  hTenkan=gce();
  hTenkan.tag="Tenkan";
  hTenkan.user_data=[ichimokuCloud($-26,3)];
  hTenkan.children(1).thickness=2
  // Kijun
  plot2d(ichimokuCloud(:,1),ichimokuCloud(:,4),style=[color("forestgreen")]);
  hKijun=gce();
  hKijun.tag="Kijun";
  hKijun.user_data=[ichimokuCloud($-26,4)];
  hKijun.children(1).thickness=3;
  hIchimokuLines=[hChikou hTenkan hKijun];
endfunction


