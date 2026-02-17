function inverti_angoli_con_selezione_intervallo()
% INVERTI_ANGOLI_CON_SELEZIONE_INTERVALLO
% Seleziona un file Excel di angoli, plotta il segnale,
% selezione di un intervallo da invertire (-1) e salva il nuovo
% file Excel con aggiunta '-OPPOSTO_SELEZIONE'.

clc;
clear all;
close all;

%% ========= PARAMETRI =========
TARGET_SHEET = 'Joint Angles ZXY'; % Nome del foglio di lavoro dove si trovano gli angoli
mappa = struct( ...
    'SFE_DX', 25, 'SFE_SX', 37, ...
    'SAA_DX', 23, 'SAA_SX', 35, ...
    'SRIE_DX', 24, 'SRIE_SX', 36, ...
    'EFE_DX', 28, 'EFE_SX', 40, ...
    'EPS_DX', 27, 'EPS_SX', 39, ...
    'WFE_DX', 31, 'WFE_SX', 43, ...
    'WDRU_DX', 29, 'WDRU_SX', 41 ); % Mappa movimento -> Colonna Excel

fprintf('=== INVERTI ANGOLI EXCEL CON SELEZIONE INTERVALLO ===\n');

%% ========= CARICAMENTO FILE =========
[filename, pathname] = uigetfile('*.xlsx', 'Seleziona il file Excel degli angoli');
if isequal(filename,0)
    disp('Caricamento file annullato.');
    return;
end
filepath = fullfile(pathname, filename);
[~, name_originale, ext] = fileparts(filename);

% ========= RICHIESTA MOVIMENTO E ASSOCIAZIONE COLONNA =========
mov = input('Inserisci movimento (es: SFE DX, SAA SX, EPS DX): ','s');
mov = upper(strtrim(mov)); 
mov_mappa = strrep(mov,' ','_'); 

if ~isfield(mappa, mov_mappa)
    error('Movimento "%s" non riconosciuto. Controlla la sigla.', mov);
end
ANGLE_COL = mappa.(mov_mappa);

fprintf('\n→ Movimento selezionato: **%s**\n', mov);
fprintf('→ Colonna Excel utilizzata (indice numerico): **%d**\n', ANGLE_COL);

% ========= LETTURA DATI  =========
try
    T = readtable(filepath, 'Sheet', TARGET_SHEET, 'ReadVariableNames', true);
catch ME
    error('Errore lettura file: %s', ME.message);
end

if ANGLE_COL > size(T, 2)
    error('Indice di colonna selezionato (%d) non valido.', ANGLE_COL);
end

col_name = T.Properties.VariableNames{ANGLE_COL};
fprintf('→ Nome della colonna selezionata: **%s**\n', col_name);

% Estrai i dati di Frames (prima colonna) e Angle (colonna selezionata)
Frames = T{:, 1};
Angle  = T{:, ANGLE_COL};

if ~isnumeric(Angle)
    error('I dati nella colonna "%s" non sono numerici.', col_name);
end

% ========= SELEZIONE INTERVALLO (GINPUT) E INVERSIONE =========
[T, bounds_frames] = seleziona_intervallo_ginput_inversion(T, Frames, Angle, ANGLE_COL, col_name, pathname, name_originale);

fprintf('** Inversione del segno completata** per l''intervallo Frames [%d .. %d].\n', bounds_frames(1), bounds_frames(2));

% ========= SALVATAGGIO NUOVO FILE EXCEL =========
% Creazione del nuovo nome e percorso del file
new_filename = [name_originale '-OPPOSTO_SELEZIONE' ext];
new_filepath = fullfile(pathname, new_filename);

try
    writetable(T, new_filepath, 'Sheet', TARGET_SHEET);
    fprintf('\n** File salvato con successo!**\n');
    fprintf('Percorso del nuovo file: **%s**\n', new_filepath);
catch ME
    error('Errore durante il salvataggio del file: %s', ME.message);
end

fprintf('\nPipeline completata.\n');

end

% =========================================================================

function [T, bounds_frames] = seleziona_intervallo_ginput_inversion(T, Frames, Angle, ANGLE_COL, col_name, pathname, name)
% SELEZIONA_INTERVALLO_GINPUT_INVERSION
% Mostra il segnale, permette di selezionare l'intervallo da invertire,
% esegue l'inversione e restituisce la tabella aggiornata.
%
% INPUT/OUTPUT:
%   T             : Tabella dati (viene aggiornata in output)
%   Frames, Angle : Vettori Frames e Angoli
%   ANGLE_COL     : Indice colonna Angoli
%   col_name      : Nome colonna Angoli
%   pathname, name: Per salvare il grafico nella cartella del file

% Figura interattiva
f = figure('Name','Seleziona intervallo da invertire (2 click: inizio & fine)','NumberTitle','off');
plot(Frames, Angle, 'b', 'LineWidth', 1.5); hold on;
grid on; xlabel('Frame'); ylabel(['Angolo ' col_name ' [°]']);
title('Clicca DUE punti: INIZIO e FINE dell''intervallo da INVERTIRE (Moltiplica per -1)');

% Prendi due click
[xc, ~] = ginput(2);

if numel(xc) < 2
    warning('Selezione non completata: nessuna inversione effettuata.');
    bounds_frames = [NaN NaN];
    close(f); return;
end

x1 = min(xc); x2 = max(xc);

% "Snap" al frame più vicino (ricerca dell'indice)
[~, i1] = min(abs(Frames - x1));
[~, i2] = min(abs(Frames - x2));

% Assicurati che gli indici siano validi e in ordine
i1 = max(1, min(i1, numel(Frames)));
i2 = max(1, min(i2, numel(Frames)));
if i2 < i1, tmp = i1; i1 = i2; i2 = tmp; end

bounds_frames = [Frames(i1) Frames(i2)];

% --- ESEGUI INVERSIONE ---
% Angoli da invertire (dal frame i1 al frame i2)
Angle_da_invertire = Angle(i1:i2);

% Inversione (Moltiplica per -1)
Angle_invertito = Angle_da_invertire * -1;

% Sostituisci i valori nella tabella originale T
T{i1:i2, ANGLE_COL} = Angle_invertito;

% --- PLOT RISULTATO ---
% Aggiorna il vettore Angle con i valori invertiti per il plot
Angle(i1:i2) = Angle_invertito;

% Disegna l'intervallo selezionato e i dati invertiti
yl = ylim;
patch([Frames(i1) Frames(i2) Frames(i2) Frames(i1)], [yl(1) yl(1) yl(2) yl(2)], ...
      [1.0 0.9 0.9], 'FaceAlpha', 0.5, 'EdgeColor', 'none', 'DisplayName','Intervallo Invertito');

plot(Frames, Angle, 'r', 'LineWidth', 2); % Plotta i dati aggiornati
title({'Angolo prima (blu) e dopo (rosso) l''inversione', ['Intervallo: Frames ' num2str(bounds_frames(1)) ' - ' num2str(bounds_frames(2))]});
legend({'Originale','Intervallo Invertito','Dato Invertito'},'Location','best');

% Salva PNG
outpng = fullfile(pathname, [name '_inversione_intervallo.png']);
saveas(f, outpng);
close(f);
fprintf('Grafico dell''inversione salvato: %s\n', outpng);

end