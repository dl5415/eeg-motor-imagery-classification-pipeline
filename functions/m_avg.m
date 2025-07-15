
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
function [subjectData] = m_avg(subjectData,window,fs)
    for s = 1:2
        for r = 1:2
            subjectData(s).pre(r).alpha = mov_avg(subjectData(s).pre(r).alpha,window,fs);
            subjectData(s).pre(r).beta = mov_avg(subjectData(s).pre(r).beta,window,fs);
            subjectData(s).pre(r).pre_raw = mov_avg(subjectData(s).pre(r).pre_raw,window,fs);
            subjectData(s).post(r).alpha = mov_avg(subjectData(s).post(r).alpha,window,fs);
            subjectData(s).post(r).beta = mov_avg(subjectData(s).post(r).beta,window,fs);
            subjectData(s).post(r).pre_raw = mov_avg(subjectData(s).post(r).pre_raw,window,fs);
        end
    end
end

%% Helper functions

function filtered = mov_avg(signal,window,fs)
    %window = [large value -> more averaging, less fluctuations] 
    %fs = frequency of signal
    filtered = filter(ones(1,window*fs)/window/fs, 1, signal);
end


