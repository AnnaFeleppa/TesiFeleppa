function [Frames_sel, Angle_sel, bounds_frames] = seleziona_intervallo(Frames, Angle, Angle_s, cartella_risultati, name)
% SELEZIONA INTERVALLO 

if nargin < 3 || isempty(Angle_s), Angle_s = Angle; end

% Figura da selezionare
f = figure('Name','Seleziona intervallo (2 click: inizio & fine)','NumberTitle','off');
plot(Frames, Angle, 'Color', [0.6 0.6 0.9], 'LineWidth',1); hold on;
plot(Frames, Angle_s, 'b', 'LineWidth',1.5);
grid on; xlabel('Frame'); ylabel('Angolo [°]');
title('Clicca DUE punti: INIZIO e FINE dell''intervallo da analizzare');
legend({'Originale','Smussato'},'Location','best');

% Prende i due click
[xc, ~] = ginput(2);

if numel(xc) < 2
    warning('Selezione non completata: uso l''intero segnale.');
    Frames_sel = Frames; Angle_sel = Angle; bounds_frames = [Frames(1) Frames(end)];
    close(f); return;
end

x1 = min(xc); x2 = max(xc);

% "Snap" al frame più vicino
[~, i1] = min(abs(Frames - x1));
[~, i2] = min(abs(Frames - x2));

i1 = max(1, min(i1, numel(Frames)));
i2 = max(1, min(i2, numel(Frames)));

if i2 < i1, tmp = i1; i1 = i2; i2 = tmp; end

Frames_sel = Frames(i1:i2);
Angle_sel  = Angle(i1:i2);
bounds_frames = [Frames(i1) Frames(i2)];

% Disegna intervallo selezionato
yl = ylim;
patch([Frames(i1) Frames(i2) Frames(i2) Frames(i1)], [yl(1) yl(1) yl(2) yl(2)], ...
      [0.93 0.97 1.00], 'FaceAlpha', 0.3, 'EdgeColor', 'none');
plot(Frames_sel, Angle_s(i1:i2), 'r', 'LineWidth', 1.8);
legend({'Originale','Smussato','Intervallo','Selezione'},'Location','best');

close(f);
fprintf('Intervallo selezionato: [%d .. %d] (frames)\n', bounds_frames(1), bounds_frames(2));

end
