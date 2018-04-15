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


// Examples to display technical analysis of the $SP500 with the
// monthly time frame
getd("./src");


// The sample provided come from Yahoo Finance
// Available through the following link
// https://finance.yahoo.com/quote/%5EGSPC/history?period1=-630982800&period2=1523743200&interval=1mo&filter=history&frequency=1mo
// The file is saved with the name "SP500_m.csv"
strPriceHistory=csvRead("./examples/SP500_m.csv",",",".","string");
priceHistory=convertStrPriceHistoryN(strPriceHistory);

title("Technical Analysis with Scilab & Ichimoku - $SPX Monthly","fontname","helvetica","fontsize",6);
hCandlestick=displayCandlestick(priceHistory,%t);

legend([hCandlestick(5) hCandlestick(6) hCandlestick(4) hCandlestick(2) hCandlestick(3)],[("Tenkan: "+msprintf("%d",round(hCandlestick(5).user_data))) ("Kijun: "+msprintf("%d",round(hCandlestick(6).user_data))) ("Chikou: "+msprintf("%d",round(hCandlestick(4).user_data))) ("SSA: "+msprintf("%d",round(hCandlestick(2).user_data))) ("SSB: "+msprintf("%d",round(hCandlestick(3).user_data)))],2);
hLegend=gce();
hLegend.font_size=3;
displayDateOfQuotation(priceHistory, 'm');

axes_candlestick=findobj("tag","axes_candlestick");
axes_candlestick.margins=[0.125/5,0.125/3,0.125/2,0.125/3];

fig=gcf();
fig.axes_size=[1639,922];

// Save the imahe into a png file
xs2png(fig, "./examples/SP500_m.png");


