function unisci_segmenti_normalizzati_st(Frames_minimi, cartella_risultati, name)
% UNISCI_SEGMENTI_NORMALIZZATI
% Crea un'unica matrice con tutti i segmenti normalizzati, la salva e
% lascia il grafico a schermo.

%% Conversioni di sicurezza (string → char)
if isstring(name)
    name = char(name);
elseif iscell(name)
    name = char(name{1});
end
if isstring(cartella_risultati)
    cartella_risultati = char(cartella_risultati);
elseif iscell(cartella_risultati)
    cartella_risultati = char(cartella_risultati{1});
end

cartella_norm = fullfile(cartella_risultati, [name '_segmenti_normalizzati']);

if ~exist(cartella_norm, 'dir')
    fprintf('Cartella segmenti normalizzati non trovata: %s\n', cartella_norm);
    return;
end
if isempty(Frames_minimi) || numel(Frames_minimi) < 2
    fprintf('Non ci sono abbastanza minimi per unire i segmenti.\n');
    return;
end

num_segmenti = numel(Frames_minimi) - 1;
fprintf('\n=== UNIONE SEGMENTI NORMALIZZATI ===\n');

segmenti_uniti = [];
% In analisi biomeccanica, spesso il primo e l'ultimo 'segmento'
% sono incompleti, quindi è comune saltarli.
primo_segmento = 2;
ultimo_segmento = num_segmenti - 1;

for i = primo_segmento:ultimo_segmento
    nome_file = sprintf('%s_segmento_%02d_norm.mat', name, i);
    filepath = fullfile(cartella_norm, nome_file);
    
    if exist(filepath, 'file')
        dati = load(filepath);
        if isfield(dati, 'segmento_norm')
            segmento_norm = dati.segmento_norm;
        else
            % Gestione dinamica del nome del campo
            campo = fieldnames(dati);
            segmento_norm = dati.(campo{1});
        end
        % Si assume che la colonna 2 contenga l'angolo
        segmenti_uniti = [segmenti_uniti, segmento_norm(:,2)]; 
        fprintf('Segmento %d aggiunto\n', i);
    else
        fprintf('⚠ Segmento %d non trovato (%s)\n', i, nome_file);
    end
end

if isempty(segmenti_uniti)
    fprintf('Nessun segmento valido trovato per unione.\n');
    return;
end

% Calcolo del vettore percentuale 0-100%
percentuale_ciclo = linspace(0, 100, size(segmenti_uniti,1))';

% Salvataggio del file .mat
nome_file_mat = fullfile(cartella_risultati, [name '_tutti_segmenti_normalizzati.mat']);
save(nome_file_mat, 'segmenti_uniti', 'percentuale_ciclo');

% --- GRAFICO (Viene lasciato aperto per visualizzazione) ---
figura = figure('Position', [100, 100, 1200, 600]);
plot(percentuale_ciclo, segmenti_uniti, 'LineWidth', 1.5);
xlabel('Ciclo [%]');
ylabel('Angolo [°]');
title(sprintf('Tutti i segmenti normalizzati (esclusi primo e ultimo) - %s', name), 'Interpreter', 'none');
grid on;

% Creazione della legenda
legend_labels = arrayfun(@(x) sprintf('Ciclo %d', x - primo_segmento + 1), ...
                         primo_segmento:ultimo_segmento, 'UniformOutput', false);
legend(legend_labels, 'Location', 'best');

% Salvataggio della figura
nome_fig_png = fullfile(cartella_risultati, [name '_tutti_segmenti_normalizzati.png']);
nome_fig_fig = fullfile(cartella_risultati, [name '_tutti_segmenti_normalizzati.fig']);
saveas(figura, nome_fig_png);
saveas(figura, nome_fig_fig);

% Forza l'aggiornamento della grafica per assicurare che la figura sia visibile
drawnow; 

fprintf('\nSegmenti uniti salvati in:\n%s\n', nome_file_mat);
fprintf('Grafici salvati in:\n%s\n%s\n', nome_fig_png, nome_fig_fig);
fprintf('\n GRAFICO DEI SEGMENTI NORMALIZZATI VISUALIZZATO A SCHERMO \n');

% NON viene chiamato 'close' quindi la figura rimane aperta.
end
