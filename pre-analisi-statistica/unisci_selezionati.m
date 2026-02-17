
% come input dati 4 file "TASK-POST-PULIZIA-PARAMETRO.xlsx" (stessa TASK, parametri diversi)
% Output: 4 file "TASK-PRE-STAT-PARAMETRO.xlsx" con stessi soggetti

clear; clc;

% selezione 4 file
[fn, fp] = uigetfile({'*.xlsx;*.xls', 'Excel files (*.xlsx, *.xls)'}, ...
    'Seleziona i 4 file TASK-POST-PULIZIA-PARAMETRO (AREA, MASSIMO, MEDIA, ROM)', ...
    'MultiSelect','on');

if isequal(fn,0)
    disp('Selezione annullata.');
    return;
end

if ischar(fn)
    fn = {fn}; 
end

if numel(fn) ~= 4
    error('Devi selezionare ESATTAMENTE 4 file. Selezionati: %d', numel(fn));
end

files = cellfun(@(x) fullfile(fp, x), fn, 'UniformOutput', false);

fprintf('File selezionati:\n');
for i=1:4
    fprintf('  (%d) %s\n', i, files{i});
end
fprintf('\n');

% Leggo i 4 file e ricavo l’insieme soggetti per ciascuno 
Tcell  = cell(1,4);
Scell  = cell(1,4);   
SkeyCol = cell(1,4);  

for i=1:4
    T = readtable(files{i});
    if width(T) < 1
        error('File %d non contiene colonne valide.', i);
    end

    subRaw = T{:,1};          
    subKey = string(subRaw);  
    subKey(subKey == "" | ismissing(subKey)) = missing;

    
    subSet = unique(subKey);
    subSet = subSet(~ismissing(subSet));

    Tcell{i}   = T;
    Scell{i}   = subSet;
    SkeyCol{i} = subKey;
end

% Intersezione soggetti su tutti e 4
S_inter = Scell{1};
for i=2:4
    S_inter = intersect(S_inter, Scell{i});
end

fprintf('Numero soggetti per file:\n');
for i=1:4
    fprintf('  File %d: %d soggetti\n', i, numel(Scell{i}));
end
fprintf('Intersezione: %d soggetti\n\n', numel(S_inter));

if isempty(S_inter)
    warning('Intersezione vuota: nessun soggetto comune ai 4 file. I file PRE-STAT saranno vuoti.');
end

% salva come TASK-PRE-STAT-PARAMETRO
for i=1:4
    T = Tcell{i};
    subKey = SkeyCol{i};

    keepRows = ismember(subKey, S_inter);
    T_out = T(keepRows, :);

    outFile = make_outname(files{i}, fp, '-POST-PULIZIA-', '-PRE-STAT-');

    fprintf('Salvo PRE-STAT (%d/4):\n  %s\n', i, outFile);
    writetable(T_out, outFile);
end

fprintf('\nFatto.\n');


function outFile = make_outname(inFile, folderPath, tokenIn, tokenOut)
    [~, name, ext] = fileparts(inFile);

    if contains(name, tokenIn)
        nameOut = strrep(name, tokenIn, tokenOut);
    else
        % fallback semplice
        nameOut = [name tokenOut(1:end-1)];
    end

    outFile = fullfile(folderPath, [nameOut ext]);
end
