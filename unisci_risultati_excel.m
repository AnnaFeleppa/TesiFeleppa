function unisci_risultati_excel()
% UNISCI_RISULTATI_EXCEL Carica e unisce più file Excel in uno solo.
% I file devono avere la stessa struttura (7 colonne).
    % ---SELEZIONE DEI FILE ---
    
 
    fprintf('Seleziona i file Excel da unire (da 1 a 13).\n');
    fprintf('Premi "Annulla" per terminare la selezione e procedere all''unione.\n');
    
    % Filtro per selezionare solo i file Excel
    filtro_excel = {'*.xlsx', 'File Excel (*.xlsx)'};
    
    % Inizializzazione per memorizzare i percorsi dei file selezionati
    file_selezionati = {};
    percorso_cartella = '';
    
    % Seleziona fino a 13 file (o finché l'utente non annulla)
    for i = 1:13
        [nome_file, percorso_file] = uigetfile(filtro_excel, sprintf('Seleziona il file %d di 13', i));
        
        
        if isequal(nome_file, 0)
            if i == 1
                disp('Nessun file selezionato. Operazione annullata.');
                return; % Esce dalla funzione se non è stato selezionato nessun file
            else
                disp('Selezione terminata. Procedo all''unione dei file selezionati.');
                break; % Esce dal ciclo, procede con l'unione dei file già selezionati
            end
        end
        
        % Aggiungi il percorso completo del file all'elenco
        file_selezionati{end+1} = fullfile(percorso_file, nome_file);
        
        % Salva il percorso della cartella del primo file selezionato
        if i == 1
            percorso_cartella = percorso_file;
        end
    end
    
    % Verifica finale per assicurarsi che ci siano file da unire
    if isempty(file_selezionati)
        disp('Nessun file valido selezionato per l''unione.');
        return;
    end
    
    disp(['Trovati ' num2str(length(file_selezionati)) ' file da unire.']);
    
    % --- CARICAMENTO E UNIONE DEI DATI ---
    
    % Inizializza tabella finale vuota
    tabella_finale = table();
    
    for i = 1:length(file_selezionati)
        file_corrente = file_selezionati{i};
        
        try
            % Carica i dati dal foglio di lavoro, assumendo che i dati inizino
            % dal primo foglio e includano le intestazioni.
            dati_correnti = readtable(file_corrente);
            
            % Se è il primo file, usiamo la sua struttura come riferimento
            if i == 1
                tabella_finale = dati_correnti;
            else
                % Accoda i dati al file finale
                tabella_finale = [tabella_finale; dati_correnti];
            end
            
            fprintf('  ✔ File unito con successo: %s\n', file_corrente);
            
        catch ME
            warning('Errore nel caricamento del file %s. File ignorato. Errore: %s', file_corrente, ME.message);
        end
    end
    
    % --- SALVATAGGIO DEL FILE FINALE ---
    
   % mettere in input nome file di output 
   prompt = 'Inserisci nome file TASK-RISULTATI-PRE-ANALISI-PARAMETRO es. SFE-DX-RISULTATI-PRE-ANALISI-MEDIA: ';
   nome_input_base = input(prompt, 's'); % 's' indica che l'input è una stringa

   % Aggiungi l'estensione .xlsx al nome inserito
   nome_output = [nome_input_base '.xlsx'];

   % Crea il percorso completo del file di output
   percorso_output = fullfile(percorso_cartella, nome_output);
    
    if ~isempty(tabella_finale)
        try
            % Salva tabella finale
            writetable(tabella_finale, percorso_output);
            
            fprintf('\n **Operazione completata con successo!** \n');
            fprintf('File finale salvato in: %s\n', percorso_output);
        catch ME
            error('Impossibile salvare il file di output. Controlla i permessi della cartella. Errore: %s', ME.message);
        end
    else
        disp('Nessun dato valido è stato unito. Nessun file finale creato.');
    end
end