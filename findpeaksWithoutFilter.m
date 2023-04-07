close all; clear;
filename = "../../../Documents/Shared/ISEP/A1//App/signal/Signaux ECG (Pb II Matlab)-20230403/100.wav";
[y, Fe] = audioread(filename);
dt = 1/Fe;
t = 0:dt:(length(y)*dt)-dt;

plot(t,y) % plot normal

[pks, locs] = findpeaks(y);
hold on;
plot(t(locs), pks, 'vr', 'MarkerFaceColor','r', 'MarkerSize', 6)