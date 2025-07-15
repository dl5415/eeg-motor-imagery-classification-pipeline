%% Function that spatially filters data

function subjectData = spatial_filter(subjectData)
    for s = 1:2
        for r = 1:2
            subjectData(s).pre(r).alpha = car(subjectData(s).pre(r).alpha);
            subjectData(s).pre(r).beta = car(subjectData(s).pre(r).beta);
            subjectData(s).pre(r).pre_raw = car(subjectData(s).pre(r).pre_raw);
            subjectData(s).post(r).alpha = car(subjectData(s).post(r).alpha);
            subjectData(s).post(r).beta = car(subjectData(s).post(r).beta);
            subjectData(s).post(r).pre_raw = car(subjectData(s).post(r).pre_raw);
        end
    end
end

%% Helper functions

function filtered = car(signal)
    filtered = signal - mean(signal, 2);
end
