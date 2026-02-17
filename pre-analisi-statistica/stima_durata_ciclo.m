function L = stima_durata_ciclo(Angle, Frames)

Angle  = Angle(:); 
Frames = Frames(:);
N = length(Angle);
if N < 3, L = NaN; return; end

% picchi (massimi) con prominenza relativa
prom = 0.05 * range(Angle);
if prom <= 0, L = NaN; return; end
[~, locs] = findpeaks(Angle, 'MinPeakProminence', prom);

if numel(locs) >= 2
    L = mean(diff(locs));
    return;
end

% fallback: autocorrelazione
x = Angle - mean(Angle);
[acf,lags] = xcorr(x,'coeff');
acf = acf(lags>=0);
lags = lags(lags>=0);

% ignora lag 0 e picchi troppo vicini
[~, pks] = findpeaks(acf, 'MinPeakDistance', 5);
if ~isempty(pks)
    L = mean(lags(pks));
else
    L = NaN;
end
end
