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
// http://real-chart.finance.yahoo.com/table.csv?s=%5EGSPC&a=00&b=3&c=1950&d=04&e=16&f=2016&g=m&ignore=.csv
// The file is saved with the name "SP500_m.csv"
strPriceHistory=csvRead("./examples/SP500_m.csv",",",".","string");
priceHistory=convertStrPriceHistory(strPriceHistory);

hCandlestick=displayCandlestick(priceHistory,%t);

