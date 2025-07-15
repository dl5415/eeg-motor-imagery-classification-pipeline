%A function that computes chance level result for input true labels

function [Chance_level] = chance_compute (Input_labels)
    temp_storage = zeros(1,10000);
    for z = 1 : 10000
        %shuffle Y_test, keep the distribution the same.
        random_labels = Input_labels(randperm(length(Input_labels)));
        temp_storage(z) = mean(double(random_labels == Input_labels));
    end
    Chance_level = mean(temp_storage);
end