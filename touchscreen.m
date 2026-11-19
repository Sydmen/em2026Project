%https://onlinedocs.microchip.com/oxy/GUID-7EC2A1B7-D9CD-4812-9F14-AE4A958E4C2F-en-US-8/GUID-38C48DF5-E6F2-443D-A3BC-19A5F46BC1F9.html
%https://www.sciencedirect.com/science/article/pii/S0304388625001676

%I AM USING THE FIRST LINK AS THE MAIN REFERENCE POINT

% self capacitance looks far easier to sim, so I chose that, it is
% technically not very accurate, and most touchscreens use mutual
% capacitance, but this is for only 1% extra credit to sim lol

%THESE ARE ALL GIVEN IN THE PAPER

%this is a model for the capacitance of a human body
capTouch = 2 * 10^-12; % 5pF
capHuman = 100*10^-12; % 100pF

%sensors connecting to the MCU
capParastic = 10*10^-12; % 10pF
capSensor = 100 * 10^-12; % 100pF

%you'll notice in the drawings from the reference that there is a Cg.
% I found in researching it that this capacitance is just considered to be
% so large that it is ignored. I can't find a very satisfactory reason as
% to why, but I presume it is to due with the difference in voltage from
% ground to earth ground

%this is our baseline, considered "no touch"
outOfTouch = capParastic + capSensor;

%ideal final value
withTouch =  capParastic + capSensor + (capTouch*capHuman)/(capTouch + capHuman);

%------------------------------SIMULATION------------------------------------------
t = [0:0.01:2];
capTouchSimulated = zeros(size(t));

screenDistance = 1*10^-3; %our finger will be separated by a screen, so we "approach" this distance
epsilonNaught = 8.85*10^-12; % given
humanFingerRadius = 1*10^-2; % 1 cm

%im going to have it "approach" from 1 second to 1.1 seconds, going from 100mm to screen distance
%as to how I did this, MATLAB just auto completed it after I wrote that comment. Spooky stuff
approachMask = t >= 1 & t <= 1.1;
fingerDistance = 0.1 - (0.1 - screenDistance) .* (t(approachMask) - 1) / 0.1; %this is using a linear interpolation
capTouchSimulated(approachMask) = (epsilonNaught * pi * humanFingerRadius^2) ./ fingerDistance;
capTouchSimulated(t > 1.1) = (epsilonNaught * pi * humanFingerRadius^2)  / screenDistance;

% really crazy enough, this final value we get is in the range the paper gave us. 
% It's final value is about 2.9 pF. really fucking cool

% please note the element wise division. without it, totalCap is a single number
totalCap  = capSensor + capParastic + (capTouchSimulated*capHuman)./(capTouchSimulated + capHuman);

fprintf("Ideal values:\n");
fprintf("Without touch capacitance = %d\n", outOfTouch);
fprintf("With touch capacitance = %d\n", withTouch);

finalVal = capTouchSimulated(size(t));

fprintf("\nSim values:\n");
fprintf("Final touch capacitance = %d\n", finalVal(2)); %idk why its 2 it just is

plot(t, totalCap)
yline(outOfTouch)
yline(withTouch)