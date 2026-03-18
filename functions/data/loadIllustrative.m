function network = loadIllustrative()
    
    % Initialize metadata
    numNodes = 6;
    numLinks = 7;
    
    % Initialize edge lists
    fromNodes = [1;1;3;4;5;4;5];
    toNodes = [2;3;4;2;3;6;6];
    capacities = [2e3;2e3;100;100;2e3;1e3;2e3];
    lengths = nan(numLinks, 1);
    freeFlowTimes = [5/2;1;1/4;1/4;1;1;3];

    % Create directed graph
    nodeIDs = string(unique([fromNodes(:); toNodes(:)]));
    G = digraph(fromNodes, toNodes, freeFlowTimes,nodeIDs);  % Using free flow time as weight   

    % Initialize storage
    nodeIDs = (1:numNodes)';
    xCoords = [0;3;0.75;2.25;0;3];
    yCoords = [2;2;1;1;0;0];

    % Ensure node order matches coordinates
    % (digraph nodes may be reordered internally)
    nodeNames = str2double(G.Nodes.Name);  % Convert node names to numeric IDs

    % Get matching coordinates for current graph nodes
    [~, idx] = ismember(nodeNames, nodeIDs);
    x = xCoords(idx);
    y = yCoords(idx);

    OD = zeros(numNodes, numNodes);  % OD(i, j): demand from i to j
    OD(1,2) = 600/3;
    OD(5,6) = 2*600/3;
    [origins, destinations, demands] = find(OD);  % Find non-zero entries
    demand = [origins, destinations, round(demands)];

    %% Output struct
    % Number of nodes and edges
    network.Nnodes = numnodes(G);
    network.Nedges = numedges(G);
    % Define edges
    network.edgeList = [fromNodes' toNodes'];
    % Matlab graph w/ free flow travel time as weights
    network.graph = G;
    % Characterize nodes
    network.nodePos = [xCoords yCoords];
    % Characterize edges
    network.edgeCapacity = capacities';
    network.edgeLength = lengths';
    network.edgeFFTime = freeFlowTimes';
    % Characterize demand
    network.demand = demand;
end