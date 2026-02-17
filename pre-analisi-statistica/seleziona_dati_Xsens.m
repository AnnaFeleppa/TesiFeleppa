function [Frames_out, Angle_out, mov_out, pathname_out] = seleziona_dati_Xsens(mov_in)
% SELEZIONA DATI XSENS 


TARGET_SHEET     = 'Joint Angles ZXY';
DO_SMOOTH        = true;
SMOOTH_WIN       = 5;
Frames_out       = [];
Angle_out        = [];
pathname_out     = []; 

%%carica file
[filename, pathname] = uigetfile('*.xlsx','Seleziona file Excel (angoli)');
if isequal(filename,0)
    disp('Caricamento file annullato.'); 
    return;
end
filepath = fullfile(pathname, filename);
[~, name, ~] = fileparts(filename);

% 
cartella_risultati = ''; 

fprintf('\n--- Inizio Selezione per File: %s ---\n', filename);

%%associa mov-colonna 
if nargin < 1 || isempty(mov_in)
    mov = input('Inserisci movimento (es: SFE DX, SAA SX, EPS DX): ','s');
else
    mov = mov_in;
    fprintf('→ Movimento già selezionato: %s\n', mov);
end

mov = upper(strtrim(mov));
mov = strrep(mov,' ','_'); % Converte spazi in underscore 

mappa = struct( ...
    'SFE_DX', 25, 'SFE_SX', 37, ...
    'SAA_DX', 23, 'SAA_SX', 35, ...
    'SRIE_DX', 24, 'SRIE_SX', 36, ...
    'EFE_DX', 28, 'EFE_SX', 40, ...
    'EPS_DX', 27, 'EPS_SX', 39, ...
    'WFE_DX', 31, 'WFE_SX', 43, ...
    'WDRU_DX', 29, 'WDRU_SX', 41 );

if ~isfield(mappa, mov)
    error('Movimento "%s" non riconosciuto. Controlla la sigla.', mov);
end

ANGLE_COL = mappa.(mov);
mov_out = mov; % Restituisce nome  movimento 
fprintf('→ Colonna Excel utilizzata = %d\n', ANGLE_COL);

%%lettura dati smoothing
[~, sheets] = xlsfinfo(filepath);
if ~any(strcmpi(sheets, TARGET_SHEET))
    error('Sheet "%s" non trovato nel file.', TARGET_SHEET);
end
T = readtable(filepath, 'Sheet', TARGET_SHEET);
Frames = T{:,1};
Angle = T{:,ANGLE_COL};
Frames = Frames(:);
Angle  = Angle(:);
valid  = ~isnan(Frames) & ~isnan(Angle);
Frames = Frames(valid);
Angle  = Angle(valid);
if DO_SMOOTH
    Angle_s = movmean(Angle, SMOOTH_WIN, 'Endpoints','shrink');
else
    Angle_s = Angle;
end

%%selezione intervallo
% Usiamo cartella_risultati e name anche se sono vuoti/irrilevanti 
[Frames_sel, Angle_sel, ~] = seleziona_intervallo(Frames, Angle, Angle_s, cartella_risultati, name);
if isempty(Frames_sel)
    disp('Selezione intervallo annullata.');
    return;
end

% Ricalcola lo smoothing sull'intervallo selezionato
if DO_SMOOTH
    Angle_s_sel = movmean(Angle_sel, SMOOTH_WIN, 'Endpoints', 'shrink');
else
    Angle_s_sel = Angle_sel;
end

Frames_out = Frames_sel;
Angle_out  = Angle_s_sel;
pathname_out = pathname; % VALORE PATH SALVATO QUI
fprintf('--- Fine Selezione ---\n\n');
end
