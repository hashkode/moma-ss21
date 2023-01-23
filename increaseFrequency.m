function [time] = increaseFrequency(t, f)
%   Function to increase frequency to 50 Hz 
%   Some Data collected via MATLAB Mobile had a frequency of 49.9 Hz
%   This will result in an error by using the Unit Test
%   This function squeezes the time vector to increase the frequency


factor = 50/f + 0.0001; % add a small threshold to vanish the influence of
                        % averaging the sample frequency
                        
time = linspace(t(1),t(end)/factor,size(t,2)); % Squeeze the time vector
                                               % such that it has a 
                                               % frequency over 50 Hz

end


