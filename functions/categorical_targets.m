%% I. Hate. Matlab.

function cat = categorical_targets(targets, labels)
    precat = cell(1,length(targets));
    for i = 1:length(targets)
        precat{i} = labels{targets(i)};
    end
    cat = categorical(precat);
end
