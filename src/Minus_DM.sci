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


//Minus Directional Movement
function minus_DM=Minus_DM(priceHistory)
// 
// The DM1 (one period) is base on the largest part of
// today's range that is outside of yesterdays range.
// 
// The following 7 cases explain how the +DM and -DM are
// calculated on one period:
// 
// Case 1:                       Case 2:
//    C|                        A|
//     |                         | C|
//     | +DM1 = (C-A)           B|  | +DM1 = 0
//     | -DM1 = 0                   | -DM1 = (B-D)
// A|  |                           D| 
//  | D|                    
// B|
// 
// Case 3:                       Case 4:
//    C|                           C|
//     |                        A|  |
//     | +DM1 = (C-A)            |  | +DM1 = 0
//     | -DM1 = 0               B|  | -DM1 = (B-D)
// A|  |                            | 
//  |  |                           D|
// B|  |
//    D|
// 
// Case 5:                      Case 6:
// A|                           A| C|
//  | C| +DM1 = 0                |  |  +DM1 = 0
//  |  | -DM1 = 0                |  |  -DM1 = 0
//  | D|                         |  |
// B|                           B| D|
// 
// 
// Case 7:
// 
//    C|
// A|  |
//  |  | +DM=0
// B|  | -DM=0
//    D|
// 
// In case 3 and 4, the rule is that the smallest delta between
// (C-A) and (B-D) determine which of +DM or -DM is zero.
// 
// In case 7, (C-A) and (B-D) are equal, so both +DM and -DM are
// zero.
// 
// The rules remain the same when A=B and C=D (when the highs
// equal the lows).
// 
// When calculating the DM over a period > 1, the one-period DM
// for the desired period are initialy sum. In other word, 
// for a -DM14, sum the -DM1 for the first 14 days (that's 
// 13 values because there is no DM for the first day!)
// Subsequent DM are calculated using the Wilder's
// smoothing approach:
// 
//                                    Previous -DM14
//  Today's -DM14 = Previous -DM14 -  -------------- + Today's -DM1
//                                         14
// 
// Reference:
//    New Concepts In Technical Trading Systems, J. Welles Wilder Jr
// 
//
  [n m]=size(priceHistory);
  minus_DM=zeros(n,2)+%nan;
  minus_DM(:,1)=priceHistory(:,1);
  today=1;
  prevHigh = priceHistory(today,3);
  prevLow  = priceHistory(today,4);

  for today=2:n
    High=priceHistory(today,3);
    Low=priceHistory(today,4);

    if (High > prevHigh) then
      // 1 3 4 7
      if (Low > prevLow) then
        // 1
        minus_DM(today,2)=High-prevHigh;
      else
        //3 4 7
        deltaH=High-prevHigh;
        deltaL=Low-prevLow;
        if (deltaH==deltaL) then
          //7
          minus_DM(today,2)=0;
        elseif (deltaH>-deltaL)
          //3
          minus_DM(today,2)=deltaH;
        else
          //4
          minus_DM(today,2)=deltaL;
        end
      end
    else
      //2 5 6
      deltaL=Low-prevLow;
      if (deltaL>=0) then
        //5 6
        minus_DM(today,2)=0;
      else
        //2
        minus_DM(today,2)=deltaL;
      end
    end
    prevHigh=High;
    prevLow=Low;
  end
endfunction
