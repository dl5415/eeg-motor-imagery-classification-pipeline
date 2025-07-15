%% Function that temporally filters data

function subjectData = temporal_filter(subjectData, af1, af2, bf1, bf2, pf1, pf2, N)
    fs = subjectData(1).pre(1).hdr.fs;
    % normalize the frequencies
    aWp = [af1, af2]*2/fs;
    bWp = [bf1, bf2]*2/fs;
    cWp = [pf1, pf2]*2/fs;
    [aB, aA] = butter(N, aWp);
    [bB, bA] = butter(N, bWp);
    [cB, cA] = butter(N, cWp);
    for s = 1:2
        for r = 1:2
            subjectData(s).pre(r).alpha = filter(aB, aA, subjectData(s).pre(r).eeg);
            subjectData(s).pre(r).beta = filter(bB, bA, subjectData(s).pre(r).eeg);
            %preprocessed raw
            subjectData(s).pre(r).pre_raw = filter(cB, cA, subjectData(s).pre(r).eeg);
            subjectData(s).post(r).alpha = filter(aB, aA, subjectData(s).post(r).eeg);
            subjectData(s).post(r).beta = filter(bB, bA, subjectData(s).post(r).eeg);
            subjectData(s).post(r).pre_raw = filter(cB, cA, subjectData(s).post(r).eeg);
        end
    end
end
