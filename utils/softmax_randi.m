% Softmax
function n = softmax_randi(scores)
    % Compute softmax probabilities
    exp_scores = exp(scores-max(scores));  % For numerical stability
    prob = exp_scores/sum(exp_scores);
    % Choose outcome
    cutoffs = [0; cumsum(prob)];
    r = rand;
    n = find(r >= cutoffs(1:end-1) & r < cutoffs(2:end), 1);
end