function stat = calcolaStatDescrittive(valori)
    % Calcola media e deviazione standard.
    valori = valori(:);
    stat.media = mean(valori, 'omitnan');
    stat.std = std(valori, 'omitnan');
    
end