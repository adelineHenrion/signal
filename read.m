% [y,Fe] = audioread("exercices/APP/Problem1/Jardin01.mp3");
% 
% Te=1/Fe; % Temps d'échantillonage du signal
% [Ech,Pistes]=size(y); % grâce à la fonction size nous avons le nombre d'échantillons et aussi le nombre de pistes de notre signal
% t=(0:Ech-1)*Te; % le temps correspond aux nombres d'échantillons multiplié par le temps d'échantillonage (-1 car on compte à partir de 0)
% Dbruit=0.05; % variable qui définit durée bruit
% 
% info=audioinfo(filename4);
% duree=(info.Duration); % recupère le temps
% start=1; % initialisation du début
% fin=duree*Fe-Fe*0.1; % nombre echantillon final (nombre total - nombre echantillon dans une frame)
% compteur_frame_haute=0; % frame haute
% compteur_frame_basse=0; % frame basse
% 
% plot(y);

close all

filename4="Jardin01.mp3";


[y, Fe] = audioread(filename4); % Signal

Te = 1 / Fe; % Temps échantillonage signal

[Ech,Pistes] = size(y); % Nombre d'échantillons + nombre de pistes

t = (0:Ech-1) * Te; % t = Nb Echan * temps d'un échan

Dbruit = 0.05; % Durée du bruit

info = audioinfo(filename4); % Infos du signal
duree = (info.Duration); % Temps

start = 1; % initialisation du début
fin = duree * Fe - Fe * 0.1; % nombre echantillon final (nombre total - nombre echantillon dans une frame)
compteur_frame_haute = 0; % frame haute
compteur_frame_basse = 0; % frame basse
% 10^(pSPM + S - 94)/20 -> S = -48 (Sensibilité) 10^((80 - 48 - 94)/20) =>
% puissance en Volt
list = []; %initialisation liste des bornes


while start < fin % tant que le nombre d'échantillon est bas

    Av_pow = 0; % initialisation de la puissance moyenne 
    for i = start:start + Fe * 0.1 % Une frame
        Av_pow = Av_pow + y(i)^2;
    end
    Av_pow = Av_pow / (Fe * 0.1);
    Dbm = 10 * log10(Av_pow) + 30; % equivalent en dbm
    
    if Dbm > -2 % si supérieur au seuil calculé

        compteur_frame_haute = compteur_frame_haute + 1; % frame haute +1

        if compteur_frame_basse > 5
           premier_echantillon = start - compteur_frame_basse * Fe * 0.1; % echantillon du début
           premier_echantillon_signal = premier_echantillon / Fe; % equivalent en seconde
           
           if premier_echantillon_signal < 0.1
                premier_echantillon_signal = 0;
           end

           fin_signal = start / Fe; % equivalent seconde

           puissance_bruit = 0; % initialisation de la puissance du bruit
           for j = premier_echantillon:start
               puissance_bruit = puissance_bruit + y(j)^2; % calcul
               %y2(j) = 0;
           end
           puissance_bruit = puissance_bruit / (start - premier_echantillon);
           puissance_bruit_dbm = 10 * log10(puissance_bruit) + 30; % equivalent dbm
           RMS = sqrt(puissance_bruit); % rms
              
           r = xcorr(y(premier_echantillon:start)); % coefficient autocorrélation du bruit
           disp("bruit faible détecté de " + premier_echantillon_signal + " à " + fin_signal + " s | " + puissance_bruit_dbm + " dbm | " + RMS + " V RMS | " + max(r) + " coefficient autocoréllation")
        end
        compteur_frame_basse = 0; % changement de bruit, initilise le nouveau type de bruit
    else
        compteur_frame_basse = compteur_frame_basse + 1; % frame basse +1
        if compteur_frame_haute > 10
            premier_echantillon = start - compteur_frame_haute * Fe * 0.1;
            premier_echantillon_signal = premier_echantillon / Fe;
            fin_signal = start / Fe;

            if premier_echantillon > 1 % pour éviter les doublons
                list = [list;premier_echantillon];
            end            
            list = [list;start]; % liste des bornes des bruits fort

            puissance_bruit = 0; % Calcul de la puissance du bruit sur les echantillons
            for echantillon = premier_echantillon:start
                puissance_bruit = puissance_bruit + y(echantillon)^2;
            end

            puissance_bruit = puissance_bruit / (start-premier_echantillon);
            DB =10 * log10(puissance_bruit) + 30;
            RMS = sqrt(puissance_bruit); % Tension efficace 

            r = xcorr(y(premier_echantillon:start));
            
            disp("bruit fort détecté de " + premier_echantillon_signal + " à " + fin_signal + " s | " + DB + " dbm | " + RMS + " V RMS | " + max(r) + " coefficient autocoréllation")
        end
        compteur_frame_haute=0;
    end

    start=start+Fe*0.1; %augmente d'une frame
end


y3=y;
for i=1:length(y3)
    y3(i)=0; %fonction constante egale à 0
end
for i=1:length(list)
    if mod(i,2)==1 % permet de changer l'intervalle entre deux borne
        for j=list(i):list(i+1)
            y3(j)=0.5;
        end
    end
end

plot(t,y);
xlabel('Temps')
ylabel('Signal audio')
title('Jardin01.mp3 en fonction du temps')
hold on
plot(t,y3,'r')
hold off
legend("audio","bruit fort")