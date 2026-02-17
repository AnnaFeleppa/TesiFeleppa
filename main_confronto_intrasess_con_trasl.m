function main_confronto_intrasess_con_trasl()

clc;

clear all;

close all;

%% ========= PARAMETRI =========

TARGET_SHEET      = 'Joint Angles ZXY';

DO_SMOOTH         = true;

SMOOTH_WIN        = 5;

D_MIN_DEFAULT     = 200;

mov = ''; %INIZIALIZZATA DOPO IL CICLO IF COI FILE SELEZIONATI

% Variabili per il confronto

dati_MB = struct('Frames_minimi', {}, 'name', {}, 'cartella_risultati', {});

dati_ML = struct('Frames_minimi', {}, 'name', {}, 'cartella_risultati', {});

% Variabile per il nome della cartella di confronto

cartella_risultati = ''; % Inizializzata qui

%% ========= CICLO DI ELABORAZIONE PER ENTRAMBI I FILE (MB e ML) =========

for i = 1:2

    is_primo_file = (i == 1); % true per MB, false per ML

    if is_primo_file

        etichetta_file = 'PRIMO (MB)';

    else

        etichetta_file = 'SECONDO (ML)';

    end

    

    fprintf('\n\n=== INIZIO ELABORAZIONE %s FILE ===\n', etichetta_file);

    %% ========= CARICAMENTO FILE =========

    [filename, pathname] = uigetfile('*.xlsx', ['Seleziona ' etichetta_file ' file Excel (angoli)']);

    if isequal(filename,0) %per inserire input, solo excel selezionabile

        disp('Caricamento file annullato.');

        return;

    end

    filepath = fullfile(pathname, filename); %unisce percorso e nome usando / o \

    [~, name_originale, ~] = fileparts(filename); %per estrapolare nome file senza estensione

    name = strrep(name_originale, '-', '_'); % Formato '001_MB_SFE_DX'

    

    %% ========= ASSOCIAZIONE AUTOMATICA MOVIMENTO → COLONNA =========

    if is_primo_file

        mov = input('Inserisci movimento (es: SFE DX, SAA SX, EPS DX): ','s');

        mov = upper(strtrim(mov));

        mov_cartella = strrep(mov,' ','-'); % Formato SFE-DX per nome cartella

        mov = strrep(mov,' ','_'); % Formato SFE_DX per chiave mappa

        

      % Controlliamo che la stringa sia lunga almeno 3 caratteri per evitare errori di indicizzazione.

        if length(name_originale) >= 3

            % Estraiamo i primi tre caratteri (es. '001')

            codice_soggetto = name_originale(1:3); 

        else

            codice_soggetto = 'SOGG';

            warning('Impossibile estrarre Soggetto (prime 3 cifre) dal nome. Nome file troppo corto: %s. Usato SOGG.', name_originale);

        end

        % 2. Creazione della cartella risultati

        nome_cartella = [codice_soggetto '-' mov_cartella '-CONFRONTO-RISULTATI'];

        cartella_risultati = fullfile(pathname, nome_cartella);

        if ~exist(cartella_risultati, 'dir'), mkdir(cartella_risultati); end

        

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

    else

        % Per il secondo file, usiamo il movimento e la colonna del primo file

        ANGLE_COL = mappa.(mov);

    end

    % Copia file nella cartella di confronto (eseguito in entrambi i cicli)

    try, copyfile(filepath, fullfile(cartella_risultati, filename)); end

    fprintf('Cartella risultati: %s\n\n', cartella_risultati);

    fprintf('→ Movimento selezionato: %s  |  Colonna Excel utilizzata = %d\n\n', mov, ANGLE_COL);

    

    %% ========= LETTURA DATI  =========

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

    %% ========= SELEZIONE INTERVALLO (GINPUT) =========

    [Frames, Angle, ~] = seleziona_intervallo_ginput(Frames, Angle, Angle_s, cartella_risultati, name);

    

    if DO_SMOOTH

        Angle_s = movmean(Angle, SMOOTH_WIN, 'Endpoints', 'shrink');

    else

        Angle_s = Angle;

    end

    

    % ---  TRASLAZIONE lungo ASSE Y
    fprintf('Traslazione degli angoli per iniziare da 0° (Azzeramento iniziale)...\n');

    valore_iniziale = Angle(1);

    Angle_traslato = Angle - valore_iniziale;

    Angle_s_traslato = Angle_s - valore_iniziale;

    Angle = Angle_traslato;

    Angle_s = Angle_s_traslato;

    h_fig_traslato = figure('Name', ['Segnale Traslato Verticalmente - ' etichetta_file]);

    plot(Frames, Angle_s, 'b-', 'LineWidth', 1.5);

    hold on;

    plot(Frames, Angle, 'r:', 'LineWidth', 0.5);

    yline(0, 'k--', 'LineWidth', 1, 'HandleVisibility','off');

    xlabel('Frame Originale Selezionato');

    ylabel('Angolo Traslato (Gradi, Inizio a 0)');

    % Aggiungo 'Interpreter', 'none' per evitare l'effetto pedice con underscore

    title(sprintf('Segnale Selezionato e Azzerato - Movimento: %s - File: %s', mov, etichetta_file), 'Interpreter', 'none'); 

    legend('Angolo Smussato (Angle\_s)', 'Angolo Originale (Angle)', 'Location', 'best');

    grid on;

    hold off;

    

    nome_file_fig_azzerato = fullfile(cartella_risultati, [name '_segnale_azzerato.fig']);

    savefig(h_fig_traslato, nome_file_fig_azzerato);

    fprintf('Grafico Azzerato salvato come: %s\n', nome_file_fig_azzerato);

    fprintf('Premi un tasto per continuare con l''analisi...\n');

    pause;

    close(h_fig_traslato);

    

    %% ========= DURATA CICLO =========

    L = stima_durata_ciclo(Angle_s, Frames);

    if isnan(L)

        warning('Durata ciclo non stimabile. Uso parametri di default.');

        distanza_minima = D_MIN_DEFAULT;

    else

        distanza_minima = max(D_MIN_DEFAULT, round(0.8 * L));

    end

    fprintf('Durata ciclo stimata: %.1f frame | Distanza minima: %d\n', L, distanza_minima);

    %% ========= MINIMI GLOBALI =========

    [Frames_minimi, ~] = trova_minimi_globali(Frames, Angle_s, distanza_minima, cartella_risultati, name);

    if numel(Frames_minimi) < 2

        error('Minimi insufficienti per la segmentazione (%d).', numel(Frames_minimi));

    end

    %% ========= SEGMENTAZIONE  =========

    dividi_segnale_tra_minimi(Frames, Angle, Frames_minimi, cartella_risultati, name);

    %% ========= NORMALIZZAZIONE 0–100%  =========

    normalizza_segmenti(Frames, Angle, Frames_minimi, cartella_risultati, name);

    %% ========= MEMORIZZAZIONE DATI PER CONFRONTO  =========

 if is_primo_file

        % Assegna i valori all'ELEMENTO 1 dell'array di strutture dati_MB

        dati_MB(1).Frames_minimi = Frames_minimi;

        dati_MB(1).name = name;

        dati_MB(1).cartella_risultati = cartella_risultati;

    else

        % Assegna i valori all'ELEMENTO 1 dell'array di strutture dati_ML

        dati_ML(1).Frames_minimi = Frames_minimi;

        dati_ML(1).name = name;

        dati_ML(1).cartella_risultati = cartella_risultati;

    end

    

end % Fine ciclo for 1:2

%% ========= ANALISI E CONFRONTO FINALE  =========

% Unisco i segmenti normalizzati del primo file

unisci_segmenti_normalizzati_st(dati_MB.Frames_minimi, dati_MB.cartella_risultati, dati_MB.name);

fprintf('Eseguita unisci_segmenti_normalizzati per il primo file. Verificare la cartella risultati.\n');

% unisce anche per il secondo file 

unisci_segmenti_normalizzati_st(dati_ML.Frames_minimi, dati_ML.cartella_risultati, dati_ML.name);

fprintf('Eseguita unisci_segmenti_normalizzati per il secondo file. Verificare la cartella risultati.\n');

fprintf('\n=== CALCOLO METRICHE E CONFRONTO (MB vs ML) ===\n');

% Esecuzione delle metriche modificate per il confronto

calcola_media(dati_MB, dati_ML, mov, cartella_risultati);

calcola_massimi(dati_MB, dati_ML, mov, cartella_risultati);

calcola_rom(dati_MB, dati_ML, mov, cartella_risultati);

calcola_area(dati_MB, dati_ML, mov, cartella_risultati);
fprintf('\n=== Generazione grafici di confronto ciclo-ciclo ===\n');

% Caricamento dei dati .mat generati da unisci_segmenti_normalizzati_st
dataMB = load(fullfile(dati_MB.cartella_risultati, [dati_MB.name '_segmenti_centrali.mat']));
dataML = load(fullfile(dati_ML.cartella_risultati, [dati_ML.name '_segmenti_centrali.mat']));

% Creazione cartella dedicata
path_confronto = fullfile(cartella_risultati, 'confronto ciclo ciclo');
if ~exist(path_confronto, 'dir'), mkdir(path_confronto); end

% Identificazione nomi per legenda (usa i nomi dei file originali salvati in dati_MB/ML)
nome_legenda_MB = dati_MB.name; 
nome_legenda_ML = dati_ML.name;

% Determino quanti cicli confrontare (il minimo comune tra i due file)
num_cicli_disponibili = min(size(dataMB.segmenti_uniti, 2), size(dataML.segmenti_uniti, 2));

for k = 1:num_cicli_disponibili
    % Recupero il numero originale del ciclo (es. 2, 3, 4...)
    id_ciclo = dataMB.nuovi_nomi_cicli(k); 
    
    h_fig = figure('Visible', 'off'); % Non apre 8 finestre, lavora in background
    hold on;
    
    % Plot MB (Blu) e ML (Rosso)
    plot(dataMB.percentuale_ciclo, dataMB.segmenti_uniti(:, k), 'b', 'LineWidth', 2);
    plot(dataML.percentuale_ciclo, dataML.segmenti_uniti(:, k), 'r', 'LineWidth', 2);
    
    grid on;
    xlabel('Ciclo [%]');
    ylabel('Angolo [°]');
    title(sprintf('Confronto Ciclo %02d - Movimento: %s', id_ciclo, strrep(mov,'_',' ')));
    
    % Legenda con i nomi dei file (puliti dagli underscore per evitare il pedice)
    legend(strrep(nome_legenda_MB,'_','-'), strrep(nome_legenda_ML,'_','-'), 'Location', 'best');
    
    % Salvataggio file
    nome_output = sprintf('Confronto_Ciclo_%02d.png', id_ciclo);
    saveas(h_fig, fullfile(path_confronto, nome_output));
    
    close(h_fig); 
    fprintf('Salvato grafico: %s\n', nome_output);
end

fprintf('\n Pipeline completata.\n');

end