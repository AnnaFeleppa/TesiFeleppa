function normalizza_segmenti(Frames, Angle, Frames_minimi, cartella_risultati, name)
% NORMALIZZA_SEGMENTI
% Normalizza ogni segmento a 101 punti (0–100%)

PCT_POINTS = 101; % Numero di punti normalizzati

if isempty(Frames_minimi) || length(Frames_minimi) < 2
    fprintf('Non ci sono abbastanza minimi per normalizzare.\n');
    return;
end

num_segmenti = length(Frames_minimi) - 1;
cartella_normalizzati = fullfile(cartella_risultati, [name '_segmenti_normalizzati']);
if ~exist(cartella_normalizzati, 'dir')
    mkdir(cartella_normalizzati);
end

fprintf('\n=== NORMALIZZAZIONE SEGMENTI ===\n');
fprintf('Numero di segmenti da normalizzare: %d\n\n', num_segmenti);

percentuale_ciclo = linspace(0, 100, PCT_POINTS)';

for i = 1:num_segmenti
    frame_inizio = Frames_minimi(i);
    frame_fine = Frames_minimi(i+1);
    
    idx_segmento = (Frames >= frame_inizio) & (Frames <= frame_fine);
    frames_seg = Frames(idx_segmento);
    angle_seg = Angle(idx_segmento);
    
    if length(frames_seg) < 2
        fprintf('ATTENZIONE: Segmento %d ha meno di 2 punti, saltato.\n', i);
        continue;
    end
    
    angle_norm = interp1(frames_seg, angle_seg, ...
        linspace(frames_seg(1), frames_seg(end), PCT_POINTS), ...
        'linear');
    
    segmento_norm = [percentuale_ciclo, angle_norm'];
    
    nome_file = sprintf('%s_segmento_%02d_norm.mat', name, i);
    filepath = fullfile(cartella_normalizzati, nome_file);
    save(filepath, 'segmento_norm');
    
    fprintf('Segmento %d normalizzato: %d → %d punti\n', ...
        i, length(frames_seg), PCT_POINTS);
end

fprintf('\nSegmenti normalizzati salvati in:\n%s\n', cartella_normalizzati);
end
