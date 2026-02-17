% TASK - Pulizia singolo parametro (MB/ML) 
% Selezione file Excel del tipo:"TASK-RISULTATI-PRE-ANALISI-PARAMETRO.xlsx"
% Calcola media e std sui valori MB e ML insieme
% Salva "TASK-SCARTATI-PARAMETRO.xlsx" con le righe in cui MB o ML è fuori da [m ± 2*sigma]
% Se per un soggetto outlier MB >=5 o outlier_ML >=5 soggetto scartato
% Altrimenti si mantengono tutte 
% Salva "TASK-POST-PULIZIA-PARAMETRO.xlsx" senza i soggetti scartati

clear; clc;

% Selezione file
[fn, fp] = uigetfile({'*.xlsx;*.xls', 'Excel files (*.xlsx, *.xls)'}, ...
    'Seleziona file TASK-RISULTATI-PRE-ANALISI-PARAMETRO');
if isequal(fn,0)
    disp('Selezione annullata.');
    return;
end
inFile = fullfile(fp, fn);
fprintf('File selezionato:\n  %s\n', inFile);


T = readtable(inFile);

if width(T) < 6
    error('Il file deve avere almeno 6 colonne. Trovate: %d', width(T));
end

% Colonne come da tua descrizione:
% 1: soggetto_MB, 2: rip_MB, 3: valore_MB
% 4: soggetto_ML, 5: rip_ML, 6: valore_ML
subMB = T{:,1};
repMB = T{:,2};
valMB = T{:,3};

subML = T{:,4};
repML = T{:,5};
valML = T{:,6};


subKey = string(subMB);
subKey(subKey == "" | ismissing(subKey)) = missing;


if ~isequal(string(subMB), string(subML))
    warning('Colonna soggetto MB e ML non coincidono riga-per-riga. Procedo comunque.');
end
if ~isequal(repMB, repML)
    warning('Colonna ripetizione MB e ML non coincide riga-per-riga. Procedo comunque.');
end

% Media e ddev st 
allVals = [valMB(:); valML(:)];
allVals = allVals(~isnan(allVals)); 

if isempty(allVals)
    error('Nessun valore numerico trovato in colonna 3 e 6.');
end

mu = mean(allVals);
sigma = std(allVals, 0); 

fprintf('\nStatistiche globali su [col3; col6]:\n');
fprintf('  media = %.6g\n', mu);
fprintf('  std   = %.6g\n', sigma);

lowThr  = mu - 2*sigma;
highThr = mu + 2*sigma;
fprintf('  Intervallo: [%.6g, %.6g]\n\n', lowThr, highThr);

% trova outlier per MB e ML
outMB = (valMB < lowThr) | (valMB > highThr);
outML = (valML < lowThr) | (valML > highThr);

idxOut = outMB | outML;

T_scartati = T(idxOut, :);
T_scartati.Flag_Outlier_MB = outMB(idxOut);
T_scartati.Flag_Outlier_ML = outML(idxOut);

outFile_scartati = make_outname(inFile, fp, '-RISULTATI-PRE-ANALISI-', '-SCARTATI-');
fprintf('Salvataggio file scartati:\n  %s\n', outFile_scartati);
writetable(T_scartati, outFile_scartati);

% scarto soggetto: se outlier_MB >=5 OR outlier_ML >=5
subjects = unique(subKey);
subjects = subjects(~ismissing(subjects));

nOutMB = zeros(size(subjects));
nOutML = zeros(size(subjects));

for i = 1:numel(subjects)
    s = subjects(i);
    maskS = (subKey == s);

    nOutMB(i) = sum(outMB(maskS));
    nOutML(i) = sum(outML(maskS));
end

discardSubject = (nOutMB >= 5) | (nOutML >= 5);
subjects_discard = subjects(discardSubject);

fprintf('\nSoggetti da scartare (regola >=5 outlier su MB o ML):\n');
if isempty(subjects_discard)
    fprintf('  Nessuno.\n');
else
    for k = 1:numel(subjects_discard)
        s = subjects_discard(k);
        j = find(subjects == s, 1, 'first');
        fprintf('  Soggetto %s: outMB=%d, outML=%d\n', s, nOutMB(j), nOutML(j));
    end
end

% elimina i soggetti da scartare
maskKeepRows = ~ismember(subKey, subjects_discard);
T_post = T(maskKeepRows, :);

outFile_post = make_outname(inFile, fp, '-RISULTATI-PRE-ANALISI-', '-POST-PULIZIA-');
fprintf('\nSalvataggio file post-pulizia (senza soggetti scartati):\n  %s\n', outFile_post);
writetable(T_post, outFile_post);

fprintf('\nFatto.\n');


function outFile = make_outname(inFile, folderPath, tokenIn, tokenOut)
    [~, name, ext] = fileparts(inFile);

    if contains(name, tokenIn)
        nameOut = strrep(name, tokenIn, tokenOut);
    else
        
        nameOut = [name tokenOut(1:end-1)];
    end

    outFile = fullfile(folderPath, [nameOut ext]);
end
