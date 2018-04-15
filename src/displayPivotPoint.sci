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


function pivot=getPivot(priceHistory)
  [n m]=size(priceHistory);
  pivot=zeros(n,2);
  
  pivot(:,1)=priceHistory(:,1);
  pivot(:,2)=(priceHistory(:,3)+priceHistory(:,4)+priceHistory(:,5))/3;
endfunction

function sPP=getPivotPoint(priceHistory,numDate)
  x=find(priceHistory(:,1) == numDate);
  Pivot=(priceHistory(x,3)+priceHistory(x,4)+priceHistory(x,5))/3;
  
  R1=(Pivot*2) - priceHistory(x,4);
  S1=(Pivot*2) - priceHistory(x,3);
  R2=Pivot + (priceHistory(x,3) - priceHistory(x,4));
  S2=Pivot - (priceHistory(x,3) - priceHistory(x,4));
// R3 = H + 2x (Pivot - B)
  R3=priceHistory(x,3) + 2*(Pivot - priceHistory(x,4));
// S3 = B - 2x (H - Pivot)
  S3=priceHistory(x,4) - 2*(priceHistory(x,3) - Pivot);
//    R3=Pivot + 2*(priceHistory(x,3) - priceHistory(x,4));
//    S3=Pivot - 2*(priceHistory(x,3) - priceHistory(x,4));
//    R4=priceHistory(x,3) + 1*(Pivot - priceHistory(x,4));
//    S4=priceHistory(x,4) - 1*(priceHistory(x,3) - Pivot);

  R4=Pivot + 3*(priceHistory(x,3) - priceHistory(x,4));
  S4=Pivot - 3*(priceHistory(x,3) - priceHistory(x,4));

  sPP=struct("Pivot",Pivot,"R1",R1,"S1",S1,"R2",R2,"S2",S2,"R3",R3,"S3",S3,"R4",R4,"S4",S4);
endfunction

function diplayPPd(strMnemo,varargin)
  historyProvider="Euronext";

  if (historyProvider=="Euronext")
    priceHistory_d=getPHFromEuronext(strMnemo,%t,'d');
    priceHistory_w=getPHFromEuronext(strMnemo,%t,'w');
    sPPd=getPivotPoint(priceHistory_d,priceHistory_w($-1,1));
    sPPw=getPivotPoint(priceHistory_w,priceHistory_w($-1,1));
  end
endfunction


//Display pivot point + R1/S1 & R2/S2
// priceHistory
// fromNumDate
// typeofAnalysis
// sPP
// typeofCandle
// Example: 
// priceHistory_w=getPHFromEuronext("CA",%t,'w')
// sPPw=getPivotPoint(priceHistory_w,priceHistory_w($-1,1))
// displayPivotPoint(priceHistory,priceHistory($,1),'d',sPPw,'w')
function hPP=displayPivotPoint(priceHistory,varargin)
  [nout nin]=argn();
  [n m]=size(priceHistory);
  fromNumDate=priceHistory($-1,1);
  typeofAnalysis='d';
  deltaD=priceHistory($,1)-priceHistory($-1,1);
  typeofCandle='d';
  bWithValue = %f;
  strFormatValue = " %.2f";
  x_offset = 0;
    
  if (deltaD<6) then
    typeofCandle='d';
  elseif (deltaD<28) then
    typeofCandle='w';
    typeofAnalysis='w';
  elseif (deltaD<80) then
    typeofCandle='m';
    typeofAnalysis='m';
  elseif (deltaD<100) then
    typeofCandle='qy';
    typeofAnalysis='qy';
  elseif (deltaD<400) then
    typeofCandle='y';
    typeofAnalysis='y';
  else
    typeofCandle='5y';
    typeofAnalysis='5y';
  end
  if (nin > 1) then
    fromNumDate=varargin(1);
  end

  sPP=getPivotPoint(priceHistory,fromNumDate);

  if (nin > 2) then
    typeofAnalysis=varargin(2);
  end
  if (nin > 3) then
    sPP=varargin(3);
  end
  if (nin > 4) then
    typeofCandle=varargin(4);
  end
  if (nin > 5) then
    bWithValue=varargin(5);
  end
  if (nin > 6) then
    strFormatValue = varargin(6);
  end
  if (nin > 7) then
    x_offset = varargin(7);
  end

  x=find(priceHistory(:,1) == fromNumDate);
  if (typeofAnalysis == 'd') then
    if (typeofCandle=='d') then
      start_x=x+0.5;
      end_x=x+1.5;
    elseif (typeofCandle=='w') then
      start_x=x+0.5;
      end_x=x+5.5;
    elseif (typeofCandle=='m') then
      start_x=x-0.5;
      end_x=min(x+40.5,n+16);
    end
  elseif (typeofAnalysis == 'w') then
    if (typeofCandle=='d') then
      start_x=x-0.5;
      end_x=x+5.5;
    elseif (typeofCandle=='w') then
      start_x=x+0.5;
      end_x=x+1.5;
    elseif (typeofCandle=='m') then
      start_x=x-0.5;
      end_x=x+4.5;
    elseif (typeofCandle=='qy') then
      start_x=x-0.5;
      end_x=x+12.5;
    elseif (typeofCandle=='y') then
      start_x=x-0.5;
      end_x=x+52.5;
    end
  elseif (typeofAnalysis == 'm') then
    if (typeofCandle=='d') then
      start_x=x-0.5;
      end_x=x+30.5;
//        x_offset = -3;
    elseif (typeofCandle=='w') then
      if (fromNumDate <> priceHistory($,1)) then
        deltawkday = 2-weekday(fromNumDate);
        x=find(priceHistory(:,1) == fromNumDate+deltawkday);

        if (isempty(x) == %t) then
          x=find(priceHistory(:,1) == fromNumDate);
        end
      else
        x=size(priceHistory,'r')+1;
      end
      start_x=x-0.5;
      end_x=x+4.5;
    elseif (typeofCandle=='m') then
      start_x=x+0.5;
      end_x=x+1.5;
    end
  elseif (typeofAnalysis == 'qy') then
    if (typeofCandle=='w') then
      start_x=x-0.5;
      end_x=x+12.5;
    elseif (typeofCandle=='m') then
      start_x=x-0.5;
      end_x=x+4.5;
    elseif (typeofCandle=='qy') then
      start_x=x+0.5;
      end_x=x+1.5;
    end
  elseif (typeofAnalysis == 'hy') then
    if (typeofCandle=='w') then
      start_x=x-0.5;
      end_x=x+26.5;
    elseif (typeofCandle=='m') then
      start_x=x-0.5;
      end_x=x+6.5;
    elseif (typeofCandle=='qy') then
      start_x=x-0.5;
      end_x=x+2.5;
    elseif (typeofCandle=='hy') then
      start_x=x-0.5;
      end_x=x+1.5;
    end
  elseif (typeofAnalysis == 'y') then
    if (typeofCandle=='d') then
      start_x=x-0.5;
      end_x=x+260.5;
    elseif (typeofCandle=='w') then
      start_x=x-0.5;
      end_x=x+52.5;
    elseif (typeofCandle=='m') then
      start_x=x-0.5;
      end_x=x+12.5;
    elseif (typeofCandle=='qy') then
      start_x=x-0.5;
      end_x=x+4.5;
    elseif (typeofCandle=='hy') then
      start_x=x-0.5;
      end_x=x+2.5;
    elseif (typeofCandle=='y') then
      start_x=x+0.5;
      end_x=x+1.5;
    end
  elseif (typeofAnalysis == '5y') then
    if (typeofCandle=='5y') then
      start_x=x+0.5;
      end_x=x+1.5;
    end
  end

  plot2d([start_x end_x],[sPP.Pivot sPP.Pivot]);
  hPivot=gce();
  hPivot.user_data=sPP.Pivot;
  hPivot.tag="Pivot";
  strPP = "PP"+typeofAnalysis;
  if (bWithValue == %t) then
    strPP = strPP + msprintf(strFormatValue, sPP.Pivot);
  end
  xstring(end_x+x_offset,sPP.Pivot,strPP);
  hStrPP=gce();
  hStrPP.tag=strPP;
  hStrPP.font_size=2;

  plot2d([start_x end_x],[sPP.R1 sPP.R1]);
  hR1=gce();
  hR1.user_data=sPP.R1;
  hR1.tag="R1";
  hR1.children(1).foreground=color("red");
  strR1 = "R1"+typeofAnalysis;
  if (bWithValue == %t) then
    strR1 = strR1 + msprintf(strFormatValue, sPP.R1);
  end
  xstring(end_x+x_offset,sPP.R1,strR1);
  hStrR1=gce();
  hStrR1.tag=strR1;
  hStrR1.font_size=2;

  plot2d([start_x end_x],[sPP.S1 sPP.S1]);
  hS1=gce();
  hS1.user_data=sPP.S1;
  hS1.tag="S1";
  hS1.children(1).foreground=color("green");
  strS1 = "S1"+typeofAnalysis;
  if (bWithValue == %t) then
    strS1 = strS1 + msprintf(strFormatValue, sPP.S1);
  end
  xstring(end_x+x_offset,sPP.S1,strS1);
  hStrS1=gce();
  hStrS1.tag=strS1;
  hStrS1.font_size=2;

  plot2d([start_x end_x],[sPP.R2 sPP.R2]);
  hR2=gce();
  hR2.user_data=sPP.R2;
  hR2.tag="R2";
  hR2.children(1).foreground=color("red");
  strR2 = "R2"+typeofAnalysis;
  if (bWithValue == %t) then
    strR2 = strR2 + msprintf(strFormatValue, sPP.R2);
  end
  xstring(end_x+x_offset,sPP.R2,strR2);
  hStrR2=gce();
  hStrR2.tag=strR2;
  hStrR2.font_size=2;

  plot2d([start_x end_x],[sPP.S2 sPP.S2]);
  hS2=gce();
  hS2.user_data=sPP.S2;
  hS2.tag="S2";
  hS2.children(1).foreground=color("green");
  strS2 = "S2"+typeofAnalysis;
  if (bWithValue == %t) then
    strS2 = strS2 + msprintf(strFormatValue, sPP.S2);
  end
  xstring(end_x+x_offset,sPP.S2,strS2);
  hStrS2=gce();
  hStrS2.tag=strS2;
  hStrS2.font_size=2;

  plot2d([start_x end_x],[sPP.R3 sPP.R3]);
  hR3=gce();
  hR3.user_data=sPP.R3;
  hR3.tag="R3";
  hR3.children(1).foreground=color("red");
  strR3 = "R3"+typeofAnalysis;
  if (bWithValue == %t) then
    strR3 = strR3 + msprintf(strFormatValue, sPP.R3);
  end
  xstring(end_x+x_offset,sPP.R3,strR3);
  hStrR3=gce();
  hStrR3.tag=strR3;
  hStrR3.font_size=2;

  plot2d([start_x end_x],[sPP.S3 sPP.S3]);
  hS3=gce();
  hS3.user_data=sPP.S3;
  hS3.tag="S3";
  hS3.children(1).foreground=color("green");
  strS3 = "S3"+typeofAnalysis;
  if (bWithValue == %t) then
    strS3 = strS3 + msprintf(strFormatValue, sPP.S3);
  end
  xstring(end_x+x_offset,sPP.S3,strS3);
  hStrS3=gce();
  hStrS3.tag=strS3;
  hStrS3.font_size=2;
  
  //R4 S4
  plot2d([start_x end_x],[sPP.R4 sPP.R4]);
  hR4=gce();
  hR4.user_data=sPP.R4;
  hR4.tag="R4";
  hR4.children(1).foreground=color("red");
  strR4 = "R4"+typeofAnalysis;
  if (bWithValue == %t) then
    strR4 = strR4 + msprintf(strFormatValue, sPP.R4);
  end
  xstring(end_x+x_offset,sPP.R4,strR4);
  hStrR4=gce();
  hStrR4.tag=strR4;
  hStrR4.font_size=2;

  plot2d([start_x end_x],[sPP.S4 sPP.S4]);
  hS4=gce();
  hS4.user_data=sPP.S3;
  hS4.tag="S4";
  hS4.children(1).foreground=color("green");
  strS4 = "S4"+typeofAnalysis;
  if (bWithValue == %t) then
    strS4 = strS4 + msprintf(strFormatValue, sPP.S4);
  end
  xstring(end_x+x_offset,sPP.S4,strS4);
  hStrS4=gce();
  hStrS4.tag=strS4;
  hStrS4.font_size=2;

  hPP=glue([hPivot hStrPP hR1 hStrR1 hS1 hStrS1 hR2 hStrR2 hS2 hStrS2 hR3 hStrR3 hS3 hStrS3 hR4 hStrR4 hS4 hStrS4]);
endfunction


// Display weekly pivot point on daily analysis
//
function hPPw=displayWeeklyPivotPoint(priceHistory)
  // Find the start of the previous week
  priceHistory_w=cnvertDlyToWklyHstory(priceHistory($-20:$,:));

  dateN=datenum();
  if ((weekday(dateN) == 1) | (weekday(dateN) == 7)) then
    sPPw=getPivotPoint(priceHistory_w,priceHistory_w($,1));
    hPPw=displayPivotPoint(priceHistory,priceHistory($,1),'w',sPPw,'d',%f);
    move(hPPw, [1 0]);
  else
    sPPw=getPivotPoint(priceHistory_w,priceHistory_w($-1,1));
    hPPw=displayPivotPoint(priceHistory,priceHistory_w($,1),'w',sPPw,'d',%f);
  end
endfunction

function hPPm=displayMonthlyPivotPoint(priceHistory)
  // Find the start of the previous month
  priceHistory_m=cnvertWklyToMnthlyHstory(priceHistory($-11:$,:));
  sPPm=getPivotPoint(priceHistory_m,priceHistory_m($-1,1));
  hPPm=displayPivotPoint(priceHistory,priceHistory_m($,1),'m',sPPm,'w',%f);
endfunction

function hPPqy=displayQrtlyPivotPoint(priceHistory)
  // Find the start of the previous quarter
  priceHistory_qy=cnvertMthlyToQtrlyHstory(priceHistory($-11:$,:));
  sPPqy=getPivotPoint(priceHistory_qy,priceHistory_qy($-1,1));
  hPPqy=displayPivotPoint(priceHistory,priceHistory_qy($,1),'qy',sPPqy,'m',%f);
endfunction

