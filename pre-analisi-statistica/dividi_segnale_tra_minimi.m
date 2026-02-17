function dividi_segnale_tra_minimi(Frames, Angle, Frames_minimi, cartella_risultati, name)

if numel(Frames_minimi) < 2, fprintf('Minimi insufficienti.\n'); return; end

cartella_segmenti = fullfile(cartella_risultati, [name '_segmenti']);
if ~exist(cartella_segmenti, 'dir'), mkdir(cartella_segmenti); end

num_segmenti = numel(Frames_minimi)-1;
fprintf('\n=== SEGMENTAZIONE: %d segmenti ===\n', num_segmenti);

for i = 1:num_segmenti
    f0 = Frames_minimi(i); f1 = Frames_minimi(i+1);
    idx = (Frames >= f0) & (Frames <= f1);
    segF = Frames(idx); segA = Angle(idx);

    % rimuovi duplicati su frame (interp1 richiede ascissa strettamente crescente)
    [segF_u, ia] = unique(segF, 'stable');
    segA_u = segA(ia);

    segmento.Frames = segF_u;
    segmento.Angle  = segA_u;
    segmento.bounds = [f0 f1];

    save(fullfile(cartella_segmenti, sprintf('%s_segmento_%02d.mat', name, i)), 'segmento');
    fprintf('Seg %02d: [%d-%d] punti=%d\n', i, f0, f1, numel(segF_u));
end
fprintf('Segmenti salvati in: %s\n', cartella_segmenti);
end
