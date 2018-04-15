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


// Jack the line where the SMA 20 changes direction

function hJacks = drawJacks(priceHistory)
 [n m] = size(priceHistory);

  pivot=getPivot(priceHistory);

  // Display Jacks (Current + Nexts)
  if (n > 20) then
    x=[n-20 n+0.5];
    y=[pivot(n-20,2) pivot(n-20,2)];
    for i=1:11
      x=[x n+i-0.5 n+i+0.5];
      y=[y pivot(n-20+i,2) pivot(n-20+i,2)];
    end
    plot2d(x,y);
    hJacks=gce();
    hJacks.tag="JackC";
    hJacks.user_data=pivot(n-20,2);
    hJacks.children(1).thickness=2;
    hJacks.children(1).line_style=2;
  end     
  // Plot vertical
  axes=gca();
  ymin=axes.data_bounds(1,2);
  ymax=axes.data_bounds(2,2);
//  ymin=axes.y_ticks.locations(1);
//  ymax=axes.y_ticks.locations($);

  plot2d([n-20 n-20], [ymin ymax]);
  hV21=gce();
  hV21.children(1).line_style=9;
// hV20.children(1).foreground=color("grey");
endfunction

// Oggy the line where the SMA 7 changes direction

function hOggys = drawOggys(priceHistory)
  [n m] = size(priceHistory);

  if (n > 7) then
    x=[n-7 n+0.5];
    y=[priceHistory(n-7,5) priceHistory(n-7,5)];
    for i=1:4
      x=[x n+i-0.5 n+i+0.5];
      y=[y priceHistory(n-7+i,5) priceHistory(n-7+i,5)];
    end
    plot2d(x,y);
    hOggys=gce();
    hOggys.tag="Oggys";
    hOggys.user_data=priceHistory(n-7,5);
//          hOggyC.children(1).thickness=2;
    hOggys.children(1).line_style=2;
  end
  // Plot vertical
  axes=gca();
  ymin=axes.data_bounds(1,2);
  ymax=axes.data_bounds(2,2);
//  ymin=axes.y_ticks.locations(1);
//  ymax=axes.y_ticks.locations($);

  plot2d([n-7 n-7], [ymin ymax]);
  hV8=gce();
  hV8.children(1).line_style=9;
// hV8.children(1).foreground=color("grey");

endfunction
