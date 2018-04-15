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


// Draw a moving average
// \param [in] priceHistory The price history
// \param [in] width The witdth of the moving average
// varargin(1) => bWithBollinger %t to display the Bollinger band
// varargin(2) => Color the color 
// varargin(3) => thickness
// varargin(4) => style
// varargin(5) => factor of std deviation

function hMM=drawMA(priceHistory,width,varargin)
  bWithBollinger=%f;
  [nout nin]=argn();

  // Set the color of standard with
  select width
    case 20 then
      strColor='scilabred3';
    case 50 then        
      strColor='scilabgreen4';
    case 7 then
      strColor='mediumblue';
    else
      strColor='black';
  end
  thickness=2;
  line_style=7;
  fstddev = 2;

  if (nin > 2) then
    bWithBollinger = varargin(1);
  end

  if (nin > 3) then
    strColor = varargin(2);
  end
  if (nin > 4) then
    thickness = varargin(3);
  end
  if (nin > 5) then
    line_style = varargin(4);
  end
  if (nin > 6) then
    fstddev = varargin(5);
  end

  [priceHistoryMM binf bsup]=MM(priceHistory,width);
  [n m]=size(priceHistoryMM);
  if (n >= 1) then
    plot2d(width+(0:n-1),priceHistoryMM);
    hMM=gce();
    hMM.tag=msprintf("MM%d",width);
    hMM.user_data=priceHistoryMM($);
    hMM.children(1).thickness=thickness;
    hMM.children(1).line_style=line_style;
    hMM.children(1).foreground=color(strColor);
    if (bWithBollinger == 1) then
      plot2d(width+(0:n-1), bsup);
      hBBsup=gce();
      hBBsup.tag=msprintf("BBsup%d",width);
      hBBsup.user_data=bsup($);
      plot2d(width+(0:n-1), binf);
      hBBinf=gce();
      hBBinf.tag=msprintf("BBinf%d",width);
      hBBinf.user_data=binf($);
      hMM=[hMM hBBsup hBBinf];
    end
  else
    hMM=[];
  end
endfunction
