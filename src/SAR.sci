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


function sar=SAR(priceHistory,varargin)
  // Set default value
  accelerationFactor=0.02;
  accelerationIncrement=0.02;
  maxAccelerationFactor=0.2;

  nin=size(varargin);
  if  (nin>=1) then
    accelerationFactor=varargin(1);
  end
  if  (nin>=2) then
    accelerationIncrement=varargin(2);
  end
  if  (nin>=3) then
    maxAccelerationFactor=varargin(3);
  end

  [n m] = size(priceHistory);
   
  sar=zeros(n,4)+%nan;
  sar(:,1)=priceHistory(:,1);
  
  trend=zeros(n,1)+%nan;
  extremePoint=zeros(n,1)+%nan;

  // Estimate the first trend with Minus_DM
  dm=Minus_DM(priceHistory(1:2,:));
//  dm(2,2) = +1;
  if (dm(2,2)>=0) then
    trend(2,1)=1;
    sar(2,2) = min(priceHistory(1:2,4));
    sar(2,4) = sar(2,2);
    extremePoint(2,1) = max(priceHistory(1:2,3));
  else
    trend(2,1)=-1;
    sar(2,3) = max(priceHistory(1:2,3));
    sar(2,4) = sar(2,3);
    extremePoint(2,1) = min(priceHistory(1:2,4));
  end
  
  for i=3:n
    // If trend is bullish SAR is below
    if (trend(i-1) == 1) then
      extremePoint(i,1) = max([priceHistory(i-1:i,3)' extremePoint(i-1,1)]);
      if (sar(i-1,4) > priceHistory(i,4)) then
        // Low is below bullish sar, switch to bearish trend
        if ((extremePoint(i,1) > extremePoint(i-1)) & (accelerationFactor < maxAccelerationFactor)) then
            accelerationFactor = min([maxAccelerationFactor, (accelerationFactor + accelerationIncrement)]);
        end
        sar(i,2) = sar(i-1,4) + accelerationFactor*(extremePoint(i,1)-sar(i-1,4));

        trend(i,1) = -1;
        accelerationFactor = 0.02;
        sar(i,4) = extremePoint(i,1);
        sar(i,3) = sar(i,4);
        extremePoint(i,1) = priceHistory(i,4);
      else
        trend(i,1) = 1;

        if ((extremePoint(i,1) > extremePoint(i-1)) & (accelerationFactor < maxAccelerationFactor)) then
            accelerationFactor = min([maxAccelerationFactor, (accelerationFactor + accelerationIncrement)]);
        end
        sar(i,4) = sar(i-1,4) + accelerationFactor*(extremePoint(i,1)-sar(i-1,4));
        sar(i,4) = min([sar(i,4) min(priceHistory(i-1:i,4))]);
        sar(i,2) = sar(i,4);
      end
    elseif (trend(i-1) == -1) then
      extremePoint(i,1) = min([priceHistory(i-1:i,4)' extremePoint(i-1,1)]);
      if (sar(i-1,4) < priceHistory(i,3)) then
        // Bullish SAR reached
        if ((extremePoint(i,1) < extremePoint(i-1,1)) & (accelerationFactor < maxAccelerationFactor)) then
            accelerationFactor = min([maxAccelerationFactor,(accelerationFactor + accelerationIncrement)]);
        end
        sar(i,3) = sar(i-1,4) + accelerationFactor*(extremePoint(i,1)-sar(i-1,4));

        trend(i,1) = 1;
        accelerationFactor = 0.02;
        sar(i,4) = extremePoint(i,1);
        sar(i,2) = sar(i,4);
        extremePoint(i,1) = priceHistory(i,3);
      else
        trend(i,1) = -1;
        if ((extremePoint(i,1) < extremePoint(i-1,1)) & (accelerationFactor < maxAccelerationFactor)) then
            accelerationFactor = min([maxAccelerationFactor,(accelerationFactor + accelerationIncrement)]);
        end
        sar(i,4) = sar(i-1,4) + accelerationFactor*(extremePoint(i,1)-sar(i-1,4));
        sar(i,4) = max([sar(i,4) max(priceHistory(i-1:i,3))]);
        sar(i,3) = sar(i,4);
      end
    end
  end
endfunction
