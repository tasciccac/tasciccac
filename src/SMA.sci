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

// Simple Moving Average
// Optionnal argument StandardDeviation default 2
function [sma,binf,bsup]=SMA(v,width,varargin)

  fstddev=2;  
  if (isempty(varargin) == %f) then
    fstddev = varargin(1);
  end

  [s d]=size(v);
  sma=v(width:$,:);
  binf=v(width:$,:);
  bsup=v(width:$,:);
  for i=s:-1:width
    sma(i-width+1,1)=mean(v(i-width+1:i,1));
    ecarttype=stdev(v(i-width+1:i,1),'*',sma(i-width+1,1));
    binf(i-width+1,1)=sma(i-width+1,1)-fstddev*ecarttype;
    bsup(i-width+1,1)=sma(i-width+1,1)+fstddev*ecarttype;
  end
endfunction
