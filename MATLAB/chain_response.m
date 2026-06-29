function resp = chain_response(chain, f_Hz)
%CHAIN_RESPONSE Complex response of a multi-stage DSP chain.
%
% Digital decimator stages are evaluated at their input sampling rate.
% Because their response is periodic, this also accounts for aliases from
% previous sampling/decimation stages.

f_Hz = f_Hz(:);

H = ones(size(f_Hz));

for k = 1:numel(chain)
    H = H .* chain{k}.response(f_Hz);
end

resp.frequency_Hz = f_Hz;
resp.H = H;
resp.magnitude = abs(H);
resp.magnitude_dB = 20*log10(abs(H) + eps);
resp.phase_rad = unwrap(angle(H));
resp.phase_deg = rad2deg(resp.phase_rad);

end