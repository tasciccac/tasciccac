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

function zoom(priceHistory,varargin)
  numberOfCandleToSee=100;
  y_mini_rate=0.236;
  y_maxi_rate=0.236;
  if (isempty(varargin) == %F) then
    numberOfCandleToSee=varargin(1);
    [nout nin]=argn();
    if (nin >= 3) then
      y_mini_rate = varargin(2);
    end
    if (nin >= 4) then
      y_maxi_rate = varargin(3);
    end
  end
  [n m] = size(priceHistory);
  if (n >= numberOfCandleToSee) then
    mini=min(priceHistory(n-numberOfCandleToSee+1:n,4));
    maxi=max(priceHistory(n-numberOfCandleToSee+1:n,3));
    delta=maxi-mini;

    y_mini=mini-delta*(y_mini_rate);
    y_maxi=maxi+delta*(y_maxi_rate);
    a=gca();
    a.zoom_box=[n-numberOfCandleToSee y_mini n+26 y_maxi -1 1]
  end
endfunction
