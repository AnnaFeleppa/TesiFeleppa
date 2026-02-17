
% Chiama la funzione di selezione per due file diversi e  confronto.
% Trasla le curve sull'asse Y: partono da 0.
% Salva il grafico finale nella cartella fissa "CONFRONTO_XSENS_MB_ML".

clc; 
clear all; 
close all;
%% 

fprintf('====================================================\n');
fprintf('  INIZIO CONFRONTO DATI XSENS (FILE 1 vs FILE 2) \n');
fprintf('====================================================\n');

% --- 1. SELEZIONE FILE 1 (richiede movimento e cattura il PATH) ---
fprintf('>>> FASE 1: Seleziona e processa il PRIMO file Excel.\n');
[Frames1, Angle1, Movimento1, Path1] = seleziona_dati_Xsens(); 

if isempty(Frames1)
    disp('Operazione interrotta dopo la selezione del File 1.');
    return;
end

% --- 2. SELEZIONE FILE 2 (usa il movimento del File 1) ---
fprintf('>>> FASE 2: Seleziona e processa il SECONDO file Excel.\n');
[Frames2, Angle2, Movimento2, ~] = seleziona_dati_Xsens(Movimento1); 

if isempty(Frames2)
    disp('Operazione interrotta dopo la selezione del File 2.');
    return;
end

% Verifica che i movimenti selezionati siano gli stessi
if ~strcmp(Movimento1, Movimento2)
    warning('I movimenti selezionati non coincidono! (%s vs %s)', Movimento1, Movimento2);
    risposta = input('Vuoi continuare a plottare comunque? (s/n): ','s');
    if strcmpi(risposta, 'n')
        disp('Plotting annullato dall''utente.');
        return;
    end
end

% --- TRASLAZIONE DEI DATI ANGOLARI (SU ASSE Y) ---
% Rende l'angolo iniziale (il primo frame della selezione) uguale a zero per entrambe le curve.
Angle_NormY1 = Angle1 - Angle1(1);
Angle_NormY2 = Angle2 - Angle2(1);

fprintf('Dati angolari traslati: la partenza di entrambe le curve è stata normalizzata a 0 gradi.\n');


% --- PREPARAZIONE CARTELLA RISULTATI ---
cartella_finale_nome = 'CONFRONTO_XSENS_MB_ML';
cartella_finale = fullfile(Path1, cartella_finale_nome);

% Verifica esistenza della cartella
if ~exist(cartella_finale, 'dir')
    mkdir(cartella_finale);
    fprintf('Creata cartella risultati: %s\n', cartella_finale);
else
    fprintf('Cartella risultati esistente: %s (salvataggio diretto)\n', cartella_finale);
end


% --- NORMALIZZAZIONE TEMPORALE (SU ASSE X) ---
% I Frame vengono normalizzati in Percentuale di Ciclo (0% a 100%).
% L'asse X (Tempo) viene chiamato Tempo_NormX.
Tempo_NormX1 = (Frames1 - Frames1(1)) / (Frames1(end) - Frames1(1)) * 100; 
Tempo_NormX2 = (Frames2 - Frames2(1)) / (Frames2(end) - Frames2(1)) * 100;


% --- 4. PLOT---
f_plot = figure('Name', sprintf('Confronto %s (Traslato)', Movimento1));

plot(Tempo_NormX1, Angle_NormY1, 'b-', 'LineWidth', 2, 'DisplayName', 'Dati Xsens MB (Traslati)');
hold on; 
plot(Tempo_NormX2, Angle_NormY2, 'r--', 'LineWidth', 2, 'DisplayName', 'Dati Xsens ML (Traslati)');
hold off;

% nome titolo (SFE_DX -> SFE DX)
mov_titolo = strrep(Movimento1, '_', ' '); 

% Aggiunta di titoli e etichette
title(sprintf('Confronto Angoli Traslati: %s', mov_titolo), 'FontSize', 14);
xlabel('Percentuale di Ciclo di Movimento (%)', 'FontSize', 12);
% L'asse Y ora rappresenta la variazione rispetto all'inizio del ciclo.
ylabel('Variazione Angolare (Gradi, partenza=0°)', 'FontSize', 12); 
legend('show', 'Location', 'best');
grid on;
box on;

% --- SALVATAGGIO GRAFICO FINALE ---
nome_file_base = ['Confronto_MB_ML_', Movimento1, '_Traslato'];

% Salvataggio PNG
outpng = fullfile(cartella_finale, [nome_file_base, '.png']);
saveas(f_plot, outpng);

% Salvataggio FIG 
outfig = fullfile(cartella_finale, [nome_file_base, '.fig']);
savefig(f_plot, outfig);

fprintf('====================================================\n');
fprintf('  CONFRONTO COMPLETATO E GRAFICO SALVATO! \n');
fprintf('  File PNG: %s\n', outpng);
fprintf('  File FIG: %s\n', outfig); 
fprintf('  Nella cartella: %s\n', cartella_finale);
fprintf('====================================================\n');
