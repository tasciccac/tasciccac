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

function priceHistory=convertStrPriceHistory(strPriceHistory)
  [n m]=size(strPriceHistory);
  priceHistory=zeros(n-1,7);
  for i=n:-1:2
    vecDate = msscanf(strPriceHistory(i,1),"%d-%d-%d");
    numDate = datenum(vecDate);
    Open = msscanf(strPriceHistory(i,2),"%f");
    High = msscanf(strPriceHistory(i,3),"%f");
    Low = msscanf(strPriceHistory(i,4),"%f");
    Close = msscanf(strPriceHistory(i,5),"%f");
    Volume = msscanf(strPriceHistory(i,6),"%f");
    AdjClose = msscanf(strPriceHistory(i,7),"%f");
    priceHistory(n-i+1,:) = [numDate Open High Low Close Volume AdjClose];
  end
endfunction
