function calcola_area(dati_MB, dati_ML, mov, cartella_risultati_confronto)
% CALCOLA_AREA - Calcola l'area sotto la curva (AUC) per ciascun segmento (esclusi primo e ultimo) per MB e ML e salva il confronto.

fun_auc = @(S) trapz(S.segmento_norm(:,1), S.segmento_norm(:,2));
risultati_MB = calcola_singolo_parametro_speciale(dati_MB, 'Area', fun_auc);
risultati_ML = calcola_singolo_parametro_speciale(dati_ML, 'Area', fun_auc);

if isempty(risultati_MB) || isempty(risultati_ML)
    fprintf('Impossibile confrontare l''Area: segmenti insufficienti o non validi in uno dei file.\n');
    return;
end

gestisci_salvataggio_risultati_confronto(mov, 'Area', risultati_MB, risultati_ML, cartella_risultati_confronto, dati_MB.name, dati_ML.name);
fprintf('Confronto Area completato.\n');

end