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
  priceHistory=zeros(n-1,6);
  for i=n:-1:2
    vecDate = msscanf(strPriceHistory(i,1),"%d-%d-%d");
    numDate = datenum(vecDate);
    Open = msscanf(strPriceHistory(i,2),"%f");
    High = msscanf(strPriceHistory(i,3),"%f");
    Low = msscanf(strPriceHistory(i,4),"%f");
    Close = msscanf(strPriceHistory(i,5),"%f");
    Volume = msscanf(strPriceHistory(i,6),"%f");
    priceHistory(n-i+1,:) = [numDate Open High Low Close Volume];
  end
endfunction

function priceHistory=convertStrPriceHistoryN(strPriceHistory)
  // line to remove
  k=find(strPriceHistory(:,5)=="null");
  n=size(strPriceHistory,'r');
  for i=1:size(k,'*')
    strPriceHistory=strPriceHistory([1:(k(i)-1) (k(i)+1):n],:);
    n=n-1;
  end

  n=size(strPriceHistory,'r');
  priceHistory=zeros(n-1,6);
 
  for i=2:n
    vecDate = msscanf(strPriceHistory(i,1),"%d-%d-%d");
    numDate = datenum(vecDate);
    Open = msscanf(strPriceHistory(i,2),"%f");
    High = msscanf(strPriceHistory(i,3),"%f");
    Low = msscanf(strPriceHistory(i,4),"%f");
    Close = msscanf(strPriceHistory(i,6),"%f");
    Volume = msscanf(strPriceHistory(i,7),"%f");
    priceHistory(i-1,:) = [numDate Open High Low Close Volume];    
  end
endfunction


function strPriceHistory=convertPriceHistoryToStr(priceHistory)
  [n m]=size(priceHistory);
  strPriceHistory=["Date" "Open" "High" "Low" "Close" "Volume" "Adj Close"];
  for i=n:-1:1
    vecDate = datevec(priceHistory(i,1));
    strDate = msprintf("%04d-%02d-%02d",vecDate(1),vecDate(2),vecDate(3));
    strOpen = msprintf("%f",priceHistory(i,2));
    strHigh = msprintf("%f",priceHistory(i,3));
    strLow = msprintf("%f",priceHistory(i,4));
    strClose = msprintf("%f",priceHistory(i,5));
    strVolume = msprintf("%d",priceHistory(i,6));
    strPriceHistory=[strPriceHistory; strDate strOpen strHigh strLow strClose strVolume strClose];
  end
endfunction
    
