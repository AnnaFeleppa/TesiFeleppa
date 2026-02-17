function gestisci_salvataggio_risultati_confronto(mov, nome_parametro, risultati_MB, risultati_ML, cartella_risultati, nome_MB_input, nome_ML_input)

nome_file_excel = fullfile(cartella_risultati, [mov '_' upper(nome_parametro) '.xlsx']);
fprintf('→ Salvataggio risultati %s in %s\n', upper(nome_parametro), nome_file_excel);

% --- CORREZIONE DI ROBUSTEZZA: Pulizia e Estrazione del Soggetto ---

[~, nome_MB_base, ~] = fileparts(nome_MB_input);
[~, nome_ML_base, ~] = fileparts(nome_ML_input);

% 2. Estrazione diretta dei primi tre caratteri (es. '001')
%    Assicuriamo che sia una stringa classica (char array) prima dell'indicizzazione.
if isstring(nome_MB_base)
    nome_MB_base = char(nome_MB_base);
end
if isstring(nome_ML_base)
    nome_ML_base = char(nome_ML_base);
end

% 3. Prendiamo i primi tre caratteri
%    Se la stringa è lunga almeno 3 caratteri.
if length(nome_MB_base) >= 3
    soggetto_MB = nome_MB_base(1:3); % Estrae '001'
else
    soggetto_MB = 'SOGG_MB';
    warning('Nome file MB troppo corto. Usato SOGG_MB.');
end

if length(nome_ML_base) >= 3
    soggetto_ML = nome_ML_base(1:3); % Estrae '001'
else
    soggetto_ML = 'SOGG_ML';
    warning('Nome file ML troppo corto. Usato SOGG_ML.');
end


% Assicuriamoci che i segmenti siano allineati per il confronto.
ids = risultati_MB.Segmento;
vals_MB = risultati_MB{:, 2};
vals_ML = risultati_ML{:, 2};

% Creazione delle colonne richieste
col_soggetto_MB = repmat({soggetto_MB}, numel(ids), 1);
col_segmento_MB = ids;
col_parametro_MB = vals_MB;

col_soggetto_ML = repmat({soggetto_ML}, numel(ids), 1);
col_segmento_ML = ids;
col_parametro_ML = vals_ML;

% Calcolo della differenza
col_differenza = vals_MB - vals_ML;

% Nomi delle colonne dell'output
nome_col_parametro_MB = [nome_parametro '_MB'];
nome_col_parametro_ML = [nome_parametro '_ML'];
nome_col_differenza = ['Differenza_' nome_parametro '_MB_ML'];

% Creazione della tabella dei nuovi risultati (solo il confronto corrente)
nuovi_risultati = table(col_soggetto_MB, col_segmento_MB, col_parametro_MB, ...
                        col_soggetto_ML, col_segmento_ML, col_parametro_ML, ...
                        col_differenza, ...
                        'VariableNames', {'Soggetto MB', 'Segmento MB', nome_col_parametro_MB, ...
                                          'Soggetto_ML', 'Segmento ML', nome_col_parametro_ML, ...
                                          nome_col_differenza});


    % Se il file non esiste, salviamo direttamente
    writetable(nuovi_risultati, nome_file_excel);
    fprintf('Nuovo file creato e salvato: %s\n', nome_file_excel);


end