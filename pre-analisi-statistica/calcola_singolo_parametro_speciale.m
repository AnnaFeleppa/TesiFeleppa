function risultati = calcola_singolo_parametro_speciale(dati, nome_colonna, funzione_calcolo)
% Calcola un parametro (es. Area) che necessita sia della colonna X (tempo normalizzato) che Y (angolo).

name = dati.name;
Frames_minimi = dati.Frames_minimi;
cartella_risultati = dati.cartella_risultati;

if numel(Frames_minimi) < 4
    risultati = [];
    return;
end

cartella_norm = fullfile(cartella_risultati, [name '_segmenti_normalizzati']);
if ~exist(cartella_norm, 'dir')
    risultati = [];
    return;
end

num_seg = numel(Frames_minimi) - 1;
segmenti_validi = 2:(num_seg - 1);
vals = []; ids = [];

for i = segmenti_validi
    file = fullfile(cartella_norm, sprintf('%s_segmento_%02d_norm.mat', name, i));
    if ~exist(file, 'file'), continue; end
    S = load(file);
    if ~isfield(S, 'segmento_norm'), continue; end
    
    % L'Area richiede l'intera struttura S, con segmenti normalizzati (X e Y)
    if any(isnan(S.segmento_norm(:,2))), continue; end
    
    vals(end+1,1) = funzione_calcolo(S); %#ok<AGROW>
    ids(end+1,1)  = i; %#ok<AGROW>
end

if isempty(vals)
    risultati = [];
else
    risultati = table(ids, vals, 'VariableNames', {'Segmento', nome_colonna});
end

end
