function calcola_massimi(dati_MB, dati_ML, mov, cartella_risultati_confronto)
% CALCOLA_MASSIMI - Calcola il massimo per ciascun segmento (esclusi primo e ultimo) per MB e ML e salva il confronto.

risultati_MB = calcola_singolo_parametro(dati_MB, 'Massimo', @(y) max(y, [], 'omitnan'));
risultati_ML = calcola_singolo_parametro(dati_ML, 'Massimo', @(y) max(y, [], 'omitnan'));

if isempty(risultati_MB) || isempty(risultati_ML)
    fprintf('Impossibile confrontare i massimi: segmenti insufficienti o non validi in uno dei file.\n');
    return;
end

gestisci_salvataggio_risultati_confronto(mov, 'Massimo', risultati_MB, risultati_ML, cartella_risultati_confronto, dati_MB.name, dati_ML.name);
fprintf('Confronto Massimi completato.\n');

end