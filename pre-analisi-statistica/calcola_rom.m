function calcola_rom(dati_MB, dati_ML, mov, cartella_risultati_confronto)
% CALCOLA_ROM - Calcola la ROM per ciascun segmento (esclusi primo e ultimo) per MB e ML e salva il confronto.

fun_rom = @(y) max(y, [], 'omitnan') - min(y, [], 'omitnan');
risultati_MB = calcola_singolo_parametro(dati_MB, 'ROM', fun_rom);
risultati_ML = calcola_singolo_parametro(dati_ML, 'ROM', fun_rom);

if isempty(risultati_MB) || isempty(risultati_ML)
    fprintf('Impossibile confrontare il ROM: segmenti insufficienti o non validi in uno dei file.\n');
    return;
end

gestisci_salvataggio_risultati_confronto(mov, 'ROM', risultati_MB, risultati_ML, cartella_risultati_confronto, dati_MB.name, dati_ML.name);
fprintf('Confronto ROM completato.\n');

end
