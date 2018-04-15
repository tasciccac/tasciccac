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


function hSAR=drawSAR(priceHistory,varargin)
  if (isempty(varargin)<>%T)  then
    //The first additionnal arg is the acceleration factor
    optInAcceleration=varargin(1);
  else
    optInAcceleration=0.02;
  end

  sar=SAR(priceHistory,optInAcceleration);
  [n m]=size(sar);
  cBelow=color("forestgreen");
  cAbove=color("red");

  plot2d(1:n,sar(:,2));
  hSARBelow=gce();
  hSARBelow.children(1).line_mode="off"
  hSARBelow.children(1).mark_mode="on"
  hSARBelow.children(1).mark_style=9;
  hSARBelow.children(1).mark_foreground=-2;
  hSARBelow.children(1).mark_background=cBelow;
  hSARBelow.user_data = sar($,2);
  hSARBelow.tag = "SAR Below";

  plot2d(1:n,sar(:,3));
  hSARAbove=gce();
  hSARAbove.children(1).line_mode="off"
  hSARAbove.children(1).mark_mode="on"
  hSARAbove.children(1).mark_style=9;
  hSARAbove.children(1).mark_foreground=-2;
  hSARAbove.children(1).mark_background=cAbove;
  hSARAbove.user_data = sar($,3);
  hSARAbove.tag = "SAR Above";

  if (isnan(hSARAbove.user_data) == %f) then
//      hSAR=glue([hSARAbove hSARbelow]);
      hSAR=[hSARAbove hSARBelow];
  else
//      hSAR=glue([hSARbelow hSARAbove]);
      hSAR=[hSARBelow hSARAbove];
  end
endfunction
