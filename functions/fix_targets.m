%% Fix target format because matlab is fucking dumb

function fixed = fix_targets(targets)
    fixed = zeros(3, length(targets));
    for i = 1:length(targets)
        fixed(targets(i),i) = 1;
    end
end
