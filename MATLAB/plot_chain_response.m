function plot_chain_response(chain, f_max_Hz, N)
%PLOT_CHAIN_RESPONSE Plot amplitude and phase response of whole chain.
%
% Example:
%   plot_chain_response(chain, 2e6, 200000);

if nargin < 2 || isempty(f_max_Hz)
    f_max_Hz = get_chain_default_fmax(chain);
end

if nargin < 3 || isempty(N)
    N = 100000;
end

f = linspace(0, f_max_Hz, N).';
resp = chain_response(chain, f);

figure;
tiledlayout(2, 1);

nexttile;
plot(resp.frequency_Hz/1e3, resp.magnitude_dB, "LineWidth", 1.1);
grid on;
xlabel("Frequency [kHz]");
ylabel("Magnitude [dB]");
title("Chain amplitude response");
ylim([-140 5]);

nexttile;
plot(resp.frequency_Hz/1e3, resp.phase_deg, "LineWidth", 1.1);
grid on;
xlabel("Frequency [kHz]");
ylabel("Phase [deg]");
title("Chain phase response");

fprintf("\nChain response:\n");
for k = 1:numel(chain)
    fprintf("  %d: %s\n", k, chain{k}.name);
end

end


function f_max_Hz = get_chain_default_fmax(chain)

f_max_Hz = 1e6;

for k = 1:numel(chain)
    if isfield(chain{k}, "fs_in_Hz") && ~isnan(chain{k}.fs_in_Hz)
        f_max_Hz = chain{k}.fs_in_Hz;
        return;
    end
end

end