function [Frames_minimi, Valori_minimi] = trova_minimi_globali(Frames, Angle_s, distanza_minima, cartella_risultati, name)

%% Trova i minimi in modo automatico
[~, locs] = findpeaks(-Angle_s, 'MinPeakDistance', distanza_minima);
Frames_minimi = Frames(locs);
Valori_minimi = Angle_s(locs);

%% Grafico dei minimi trovati
fig = figure('Position',[100 100 1000 400]);
plot(Frames, Angle_s, 'b-', 'LineWidth', 1.4); hold on;
h_min = plot(Frames_minimi, Valori_minimi, 'ro','MarkerFaceColor','r','MarkerSize',8);
title('Correzione manuale minimi');
xlabel('Frame'); ylabel('Angolo');
grid on;

fprintf('\n--- MODALITÀ CORREZIONE MINIMI ---\n');
fprintf('* Click SINISTRO: seleziona 2 punti e aggiunge minimo nel loro intervallo\n');
fprintf('* Click DESTRO : rimuove il minimo più vicino\n');
fprintf('* Tasto U      : UNDO ultima modifica\n');
fprintf('* ENTER        : conferma e continua\n\n');

undo_stack = {};

%% Modifica manuale dei minimi
while true
    figure(fig);
    [x,~,button] = ginput(1);

    % ENTER → finito
    if isempty(x), break; end

    switch button
        case 1 % CLICK SINISTRO -> seleziona intervallo per nuovo minimo
            [x2,~] = ginput(1);
            if isempty(x2), continue; end
            xmin = min(x,x2); xmax = max(x,x2);

            idx_int = Frames>=xmin & Frames<=xmax;
            if any(idx_int)
                [mval,pos] = min(Angle_s(idx_int));
                f = Frames(idx_int);  f = f(pos);
                undo_stack{end+1} = {'add', f, mval};
                Frames_minimi(end+1) = f;
                Valori_minimi(end+1) = mval;
            end

        case 3 % CLICK DESTRO -> rimuovi minimo più vicino
            if ~isempty(Frames_minimi)
                [~,idx] = min(abs(Frames_minimi - x));
                undo_stack{end+1} = {'remove', Frames_minimi(idx), Valori_minimi(idx)};
                Frames_minimi(idx) = [];
                Valori_minimi(idx) = [];
            end

        otherwise % tasto da tastiera (es. 'u')
            ch = get(fig,'CurrentCharacter');
            if strcmpi(ch,'u') && ~isempty(undo_stack)
                last = undo_stack{end}; undo_stack(end)=[];
                if strcmp(last{1},'add')
                    idx = Frames_minimi==last{2};
                    Frames_minimi(idx)=[]; Valori_minimi(idx)=[];
                elseif strcmp(last{1},'remove')
                    Frames_minimi(end+1)=last{2};
                    Valori_minimi(end+1)=last{3};
                end
            end
    end

    % aggiorna grafico
    [Frames_minimi,ord] = sort(Frames_minimi);
    Valori_minimi = Valori_minimi(ord);
    set(h_min,'XData',Frames_minimi,'YData',Valori_minimi);
    drawnow;
end

%% Salvataggio grafico
cartella_minimi = fullfile(cartella_risultati,'minimi');
if ~exist(cartella_minimi,'dir'), mkdir(cartella_minimi); end
saveas(fig, fullfile(cartella_minimi,[name '_minimi_selezionati.png']));
close(fig);

end
