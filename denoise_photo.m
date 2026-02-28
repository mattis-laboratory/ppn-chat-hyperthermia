function [gcamp_filt,iso_filt] = denoise_photo(config,gcamp,iso)

sigma = config.gaussSigma; 

kernelSize = 3 * sigma;     % Kernel size (3-sigma rule for truncation)
x = -kernelSize:kernelSize; % Symmetric kernel range

% Create Gaussian kernel
gaussianKernel = exp(-x.^2 / (2 * sigma^2));
gaussianKernel = gaussianKernel / sum(gaussianKernel); % Normalize 

% % Apply Gaussian filter using convolution
% gcamp_filt = conv(gcamp, gaussianKernel, 'valid');
% iso_filt = conv(iso, gaussianKernel, 'valid');

gcamp_filt = filtfilt(gaussianKernel, 1, gcamp);
iso_filt = filtfilt(gaussianKernel, 1, iso);
disp('------------Gaussian Filtered GCaMP and Isosbestic --------------')

end