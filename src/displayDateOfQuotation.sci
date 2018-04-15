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


// Utility function to convert a year with 2 digits
function year2digits=convertYearIn2Digits(year4digits)
      if (year4digits >= 2000) then
        year2digits=year4digits-2000;
      else
        year2digits=year4digits-1900;
      end
endfunction

// Display the date on x axis
// varargin(1) => 'd' => Daily
//                'w' => Weekly
//                'm' => Monthly
//                'qy' => Quarterly
//                'hy' => Half yearly
//                'y' => Yearly
function displayDateOfQuotation(priceHistory,varargin)
  if (isempty(varargin)) then
    dateMode='d';
  else
    dateMode=varargin(1);
  end
  f=gcf();
  f.user_data=priceHistory;
  strCallback="displayDateOfQuotationO("""+dateMode+""")";
  h=uicontrol(f,"style","pushbutton","callback",strCallback,"String","YY-MM-DD","Position",[20 40 90 20]);
  h.Tag="RefreshDateButton";
  axis=gca();
  axis.font_size=2;
  axis.y_location = "right";
  //hv=uicontrol(f,"style","pushbutton","callback","displayVolume(priceHistory)","String","Volume","Position",[20 70 100 20]);
  zoom(priceHistory);
  displayDateOfQuotationO(dateMode);
endfunction

// Display date on candlestick axis
function displayDateOfQuotationO(dateMode)
  axes_candlestick=findobj("tag","axes_candlestick");
  if (isempty(axes_candlestick) == %f) then
    axis=axes_candlestick;
  else
    axis=gca();
  end
  priceHistory_date=axis.user_data(:,1);
  
  axis.auto_ticks(1)="on";
  [s d]=size(axis.x_ticks.locations);
  if (s > 18) then
    start = axis.x_ticks.locations(1);
    stop = axis.x_ticks.locations($);
    step = floor((stop-start)/18);
    ticks = start:step:stop;
    [n m] = size(ticks);
    strTicks = [];
    for i=1:m
      strTicks = [strTicks msprintf("%d",ticks(i))];
    end
    
    axis.x_ticks = tlist(axis.x_ticks(1),ticks,strTicks);
    [s d]=size(axis.x_ticks.locations);
  end

  [sq dq]=size(priceHistory_date);
  
  refreshAxes();

  a=0;
  lastI = 0;
  offset = 0;
  for i=1:s
    if (axis.x_ticks.locations(i) == 0)
      axis.x_ticks.labels(i)="";
    else
      if (axis.x_ticks.locations(i) <= sq)
        if (axis.x_ticks.locations(i) > 0) then
          vecDate = datevec(priceHistory_date(axis.x_ticks.locations(i)));
        else
          vecDate = %nan;
        end
        if (dateMode=='5y') then
          if (isnan(vecDate(1)) == %f) then
             strDate = msprintf("%04d",giveFiveYear(vecDate(1)));
          else
            strDate = "";
          end            
        elseif (dateMode=='qy') then
          quarter=1;
          select(vecDate(2))
          case 1 then
            quarter=1;
          case 4 then
            quarter=2;
          case 7 then
            quarter=3;
          case 10 then
            quarter=4;
          end
            strDate = msprintf("%02d-Q%d",convertYearIn2Digits(vecDate(1)),quarter);
//            strDate = msprintf("$\\rotatebox{90}{%02d-Q%d}$",convertYearIn2Digits(vecDate(1)),quarter);
          elseif (dateMode=='y') then
            if (isnan(vecDate(1)) == %f) then
              strDate = msprintf("%04d",vecDate(1));
            else
              strDate = "";
            end
          elseif (dateMode=='m') then
            if (isnan(vecDate(1)) == %f) then
              strDate = msprintf("%02d-%02d",vecDate(1),vecDate(2));
            else
              strDate = "";
            end
          else
            if (isnan(vecDate) == %f) then
              strDate = msprintf("%02d-%02d-%02d",convertYearIn2Digits(vecDate(1)),vecDate(2),vecDate(3));
            else
              strDate="";
            end
          end
        axis.x_ticks.labels(i)=strDate;
        lastI = i;
      else
        delta = axis.x_ticks.locations(i)-sq;
        if (dateMode=='d') then
          // Todo day add others days of closing ...
          if (weekday(priceHistory_date(sq)+delta) == 7)
            offset = offset+2;
          elseif (weekday(priceHistory_date(sq)+delta) == 1)
            offset = offset+1;
          end
          vecDate = datevec(priceHistory_date(sq)+delta+offset);
        elseif (dateMode=='w') then
          vecDate = datevec(priceHistory_date(sq)+delta*7);
        elseif (dateMode=='m') then
          vecDate = datevec(priceHistory_date(sq)+delta*30.5);
        elseif (dateMode=='qy') then
          vecDate = datevec(priceHistory_date(sq)+delta*3*30.5);
        elseif (dateMode=='y') then
          vecDate = datevec(priceHistory_date(sq)+delta*365.25);
        end
        if (dateMode=='qy') then
          quarter=1;
          select(vecDate(2))
            case 1 then
              quarter=1;
            case 4 then
              quarter=2;
            case 7 then
              quarter=3;
            case 10 then
              quarter=4;
            end
          strDate = msprintf("%02d-Q%d",convertYearIn2Digits(vecDate(1)),quarter);
        elseif (dateMode=='hy') then
           hy=1;
           select(vecDate(2))
             case 1 then
               hy=1;
             case 7 then
               hy=2;
             end
           strDate = msprintf("%02d-S%d",convertYearIn2Digits(vecDate(1)),hy);
        elseif (dateMode=='y') then
          strDate = msprintf("%04d",vecDate(1));
        elseif (dateMode=='m') then
          strDate = msprintf("%02d-%02d",vecDate(1),vecDate(2));
        else
          strDate = msprintf("%02d-%02d-%02d",convertYearIn2Digits(vecDate(1)),vecDate(2),vecDate(3));
        end
          axis.x_ticks.labels(i)=strDate;
      end
    end
  end
endfunction
