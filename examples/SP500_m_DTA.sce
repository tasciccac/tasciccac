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

title("Dynamical Technical Analysis with Scilab - $SPX Monthly","fontname","helvetica","fontsize",6);
hCandlestick=displayCandlestick(priceHistory,%f);

// Draw the moving average
// Pivot is (h+l+c)/3
pivot=getPivot(priceHistory);
hSMA20=drawSMA(pivot(:,2),20,1);
hSMA7=drawSMA(priceHistory(:,5),7,0);
hJacks=drawJacks(priceHistory);
hOggys=drawOggys(priceHistory);

hSAR=drawSAR(priceHistory);

if (isnan(hSAR(1).user_data(1)) == %f) then
  hSAR = hSAR(1);
end


legend([hSMA7 hOggys hSMA20(1) hJacks hSMA20(2) hSAR],[("SMA7: "+msprintf("%d",round(hSMA7.user_data))) ("Oggys") ("SMA20: "+msprintf("%d",round(hSMA20.user_data))) ("Jacks") ("BBinf - BBsup : " +msprintf("%d - %d",round(hSMA20(2).user_data),round(hSMA20(3).user_data))) ("SAR: "+msprintf("%d",round(hSAR.user_data)))],2);
hLegend=gce();
hLegend.font_size=3;
displayDateOfQuotation(priceHistory, 'm');

axes_candlestick=findobj("tag","axes_candlestick");
axes_candlestick.margins=[0.125/5,0.125/3,0.125/2,0.125/3];

fig=gcf();
fig.axes_size=[1639,922];

// Save the imahe into a png file
xs2png(fig, "SP500_m_dta.png");


