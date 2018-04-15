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

//  Display a japanese candlestick chart
//  priceHistory[in] An array with history of prices date / open / min / max / volume
//  varargin
//  1: bWithIchimokuCloud[in] => %t will display the Ichimoku Kinko Huyo
function hCandlestick=displayCandlestick(priceHistory,varargin)
  bWithIchimokuCloud=%F;
  if (isempty(varargin) == %F) then
    bWithIchimokuCloud = varargin(1);
  end

  drawlater();

  hKumo=[];
  if (bWithIchimokuCloud == %T) then
    hKumo=drawIchimokuCloud(priceHistory,%F);
  end

  colorBearishCandle = color("firebrick1"); // #FF3030
  colorBullishCandle = color("green3"); // #00D000

  [n m]=size(priceHistory);
  //
  candleWidth=0.17;
  hCandles=[];
  for i=1:n
    top=max([priceHistory(i,2) priceHistory(i,5)]);
    bottom=min([priceHistory(i,2) priceHistory(i,5)]);
    plot2d([i i], [top priceHistory(i,3)]);
    hUppershadow=gce();
    plot2d([i i], [bottom priceHistory(i,4)]);
    hLowershadow=gce();
    xrect(i-2*candleWidth,top,4*candleWidth,top-bottom);
    hBody=gce();
    //      hBody.line_mode="off";
    hBody.fill_mode="on";
    //Close line
    plot2d([i-2*candleWidth i+2*candleWidth],[priceHistory(i,5) priceHistory(i,5)]);
    hCloseLine=gce();
    //Open line
    plot2d([i-2*candleWidth i+2*candleWidth],[priceHistory(i,2) priceHistory(i,2)]);
    hOpenLine=gce();
    hBody.thickness = 1;
    if (priceHistory(i,2) > priceHistory(i,5)) then
      currentColor = colorBearishCandle;
    elseif (priceHistory(i,2) < priceHistory(i,5)) then
      currentColor = colorBullishCandle;
    else
      currentColor = color("black");
      hBody.thickness = 2;
    end

    hBody.background = currentColor;
    hBody.foreground = currentColor;

    hCloseLine.children(1).foreground = currentColor;
    hOpenLine.children(1).foreground = currentColor;
    hUppershadow.children(1).thickness = 2;
    hLowershadow.children(1).thickness = 2;
    hUppershadow.children(1).foreground = currentColor;
    hLowershadow.children(1).foreground = currentColor;

    hCandle=glue([hUppershadow hLowershadow hBody hCloseLine hOpenLine]);
    hCandle.user_data=priceHistory(i,:);
    hCandles=[hCandles hCandle];
  end
  hCandlestick=glue(hCandles);
  hCandlestick.tag="Candlestick";
  hCandlestick.user_data=priceHistory;

  axes_candlestick=findobj("tag","axes_candlestick");
  if (isempty(axes_candlestick) == %t) then
    axes_candlestick=gca();
    axes_candlestick.tag="axes_candlestick";
    axes_candlestick.user_data=priceHistory;
  end

  if (isempty(hKumo) == %f) then
    if (bWithIchimokuCloud == %t) then
      hKumo=[hKumo displayIchimokuLines(priceHistory)];
      hKumo.tag="Kumo";
    end
    hCandlestick=[hCandlestick hKumo];
  end
  drawnow();
endfunction
