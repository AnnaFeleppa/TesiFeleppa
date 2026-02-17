function main_analisi_stat()
    fprintf('   ANALISI STATISTICA COMPARATIVA (Col 3 vs Col 6)\n');

    % === SELEZIONE FILE EXCEL ===
    [nomeFile, percorsoFile] = uigetfile('*.xlsx', 'Seleziona il file Excel da analizzare');
    if nomeFile == 0
        fprintf('Selezione annullata dall''utente.\n');
        return;
    end
    
    percorsoCompleto = fullfile(percorsoFile, nomeFile);
    fprintf('\nFile selezionato: %s\n', percorsoCompleto);
    
    % === CARICAMENTO DATI ===
    try
        Dati = readtable(percorsoCompleto, 'PreserveVariableNames', true);
    catch ME
        fprintf('ERRORE durante la lettura del file: %s\n', ME.message);
        return;
    end
    
    colonna1_idx = 3; % Colonna per prova MB
    colonna2_idx = 6; % Colonna per prova ML
    colonna_diff_idx = 7; % Colonna della differenza (per Shapiro)
    
    % --- Verifica e Estrazione Dati ---
    if size(Dati, 2) < max([colonna1_idx, colonna2_idx, colonna_diff_idx])
        fprintf('ERRORE: Il file Excel non contiene tutte le colonne richieste (3, 6, 7).\n');
        return;
    end
    
    % Estrazione e pulizia dei tre vettori
    valori1 = table2array(Dati(:, colonna1_idx));
    valori2 = table2array(Dati(:, colonna2_idx));
    valori_diff = table2array(Dati(:, colonna_diff_idx));

    % Rimuove le righe con NaN in *tutte e tre* le colonne per garantire l'appaiamento
    validRows = ~isnan(valori1) & ~isnan(valori2) & ~isnan(valori_diff);
    
    valori1 = valori1(validRows);
    valori2 = valori2(validRows);
    valori_diff = valori_diff(validRows);
    Dati_filtrati = Dati(validRows, :); % Filtra anche la tabella di input
    
    if numel(valori1) < 3
        fprintf('ATTENZIONE: Meno di 3 osservazioni valide per l''analisi appaiata.\n');
        return;
    end
    
    fprintf('✓ %d osservazioni appaiate caricate per Col 3, Col 6, e Col 7 (Differenza).\n', numel(valori1));

    % --- Richiesta del nome del file finale all'utente ---
    prompt = sprintf('Inserire nome file TASK-RISULTATI-FINALI-PARAMETRO es. SFE-DX-RISULTATI-FINALI-SFE\nNome file: ');
    nomeFileOutRichiesto = input(prompt, 's');
    
    if isempty(nomeFileOutRichiesto)
        fprintf('\nNome file non inserito. Analisi annullata.\n');
        return;
    end
    
    if ~endsWith(lower(nomeFileOutRichiesto), '.xlsx')
        nomeFileOutRichiesto = [nomeFileOutRichiesto, '.xlsx'];
    end
    
    % === ESECUZIONE ANALISI E SALVATAGGIO RISULTATI ===
    nomeColonnaInput = Dati_filtrati.Properties.VariableNames{colonna1_idx}; % Usiamo l'header della Col 3
    
    eseguiAnalisiEsalvaRisultati(valori1, valori2, valori_diff, Dati_filtrati, nomeFile, percorsoFile, nomeColonnaInput, nomeFileOutRichiesto);

end