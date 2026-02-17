function eseguiAnalisiEsalvaRisultati(valori1, valori2, valori_diff, TabellaInput, nomeFile, percorsoFile, nomeColonnaInput, nomeFileOutRichiesto)
    % ESEGUI ANALISI APPAIATA: Shapiro sulla differenza (Col 7), T-test/Wilcoxon appaiati (Col 3 vs Col 6)
    
    % controllo dimensione dei campioni per il test appaiato
    if numel(valori1) ~= numel(valori2)
        error('Errore logico: I vettori di valori 1 e 2 devono avere lo stesso numero di osservazioni.');
    end
    
    n = numel(valori1);
    fprintf('\n--- ANALISI STATISTICA APPAIATA (n = %d) ---\n', n);

 
    % media e deviazione standard su colonna 3 (valori1) per la tabella di output
    statistiche = calcolaStatDescrittive(valori_diff);
    fprintf('Media: %.4f\n', statistiche.media);
    fprintf('Deviazione Standard: %.4f\n', statistiche.std);

    % Test di Normalità (Shapiro–Wilk)
    % sulla COLONNA DIFFERENZA (valori_diff)
    [h_norm, p_norm] = swtest(valori_diff, 0.05); 
    risultatoNormalita = tern(h_norm == 0, 'Distribuzione Normale', 'Distribuzione Non Normale');
    fprintf('\nNormalità della Differenza (Shapiro–Wilk): p = %.4f -> %s\n', p_norm, risultatoNormalita);

    %  Test Statistico (T-test APPAIATO o Wilcoxon APPAIATO)
    p_value_finale = NaN;
    test_eseguito = '';
    
    % === IF/ELSE BASATO SUL RISULTATO DI SHAPIRO (sulla differenza) ===
    if h_norm == 0 % Normali -> T-test appaiato (Paired T-test)
        [h, p_value_finale] = ttest(valori1, valori2); % Confronto Col 3 vs Col 6
        test_eseguito = 'Paired T-test';
    else % Non Normali -> Wilcoxon signed-rank appaiato
        [p_value_finale, h] = signrank(valori1, valori2); % Confronto Col 3 vs Col 6
        test_eseguito = 'Wilcoxon Signed-Rank';
    end

    % Conclusione Significativa
    livelloSignificativita = 0.05;
    if p_value_finale < livelloSignificativita
        conclusione = 'SIGNIFICATIVA';
    else
        conclusione = 'NON SIGNIFICATIVA';
    end
    
    fprintf('%s: p = %.4f → %s\n', test_eseguito, p_value_finale, conclusione);
    
    % Creazione File Finale dei Risultati
    
    numRigheInput = height(TabellaInput);
    
    % --- Creazione Colonna di Descrizione ---
    ColonnaNomi = table('Size', [numRigheInput, 1], 'VariableTypes', {'string'}, ...
                        'VariableNames', {'Risultati_Statistici'});
    
    ColonnaNomi(2, 1) = {'p-value'};
    ColonnaNomi(3, 1) = {'Risultato'};
    ColonnaNomi(4, 1) = {'Media'};
    ColonnaNomi(5, 1) = {'Deviazione Standard'};
    ColonnaNomi(6, 1) = {'Test'}; 
    
    % --- Creazione Colonna Valori ---
    ColonnaValori = table('Size', [numRigheInput, 1], 'VariableTypes', {'string'}, ...
                          'VariableNames', {'Valori'});
    

    ColonnaValori(2, 1) = {num2str(p_value_finale, '%.4f')};
    ColonnaValori(3, 1) = {conclusione};
    ColonnaValori(4, 1) = {num2str(statistiche.media, '%.4f')};
    ColonnaValori(5, 1) = {num2str(statistiche.std, '%.4f')};
    ColonnaValori(6, 1) = {test_eseguito};
    
    % --- Concatenazione Finale ---
    T_finale = [TabellaInput, ColonnaNomi, ColonnaValori]; 
    
    
    % Salvataggio del File
    
    % Usa il nome del file inpu
    percorsoFileOut = fullfile(percorsoFile, nomeFileOutRichiesto);
    
    fprintf('\nNome del file che verrà creato: %s\n', nomeFileOutRichiesto);
    writetable(T_finale, percorsoFileOut, 'WriteVariableNames', true);
    fprintf('\n✓ File dei risultati salvato correttamente in:\n%s\n', percorsoFileOut);
    
    winopen(percorsoFile);
  
end

function out = tern(cond, a, b)
    % Funzione ausiliaria per la selezione condizionale
    if cond, out=a; else, out=b; end
end


