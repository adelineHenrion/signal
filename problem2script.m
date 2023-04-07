close all; clear;
filename = "filePath";
[y, Fe] = audioread(filename);
dt = 1/Fe;
t = 0:dt:(length(y)*dt)-dt;

tiledlayout(3,1)
nexttile
plot(t,y) % plot normal

nexttile
cutoff_freq = 20; % fréquence de coupure en Hz
[b, a] = butter(2, cutoff_freq/(Fe/2), 'low'); % calcul des coefficients du filtre
filtered_ecg = filtfilt(b, a, y); % appliquer le filtre passe-bas
plot(filtered_ecg) %plot filtré

% Méthode 1
[pks, locs] = findpeaks(y, "MinPeakHeight", 0.9);
hold on;
plot(locs, pks, 'vr', 'MarkerFaceColor','r', 'MarkerSize', 6)

% Calcul du bpm méthode 1
rr_intervals = diff(locs)/Fe
hrv = 60./rr_intervals
bpmMoyenMeth1 = mean(hrv)
varianceBpmMeth1 = std(hrv)


%Méthode 2

deriv_signal = diff(filtered_ecg);
nexttile
plot(deriv_signal)
[peak, locs] = findpeaks(deriv_signal, 'MinPeakDistance', 0.5*Fe);

% On supprime les pics aberrants
moyen = mean(peak)
finalPeak = []
finalLoc = []
for i = 1: length(peak)
    if(peak(i) > (moyen - 0.5 * moyen) & peak(i) < (moyen + 0.5 * moyen))
        finalLoc = [finalLoc, locs(i)];
        finalPeak = [finalPeak, peak(i)]
    end
end
hold on;

% On plot le résultat
plot(finalLoc, finalPeak, 'vr', 'MarkerFaceColor','r', 'MarkerSize', 6)


% Calcul du bpm méthode 2
rr_intervals = diff(finalLoc)/Fe
hrv = 60./rr_intervals
bpmMoyenMeth2 = mean(hrv)
varianceBpmMeth2 = std(hrv)
