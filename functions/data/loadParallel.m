function network = loadParallel(R,N)
    
    % Initialize metadata
    numNodes = 2;
    numLinks = R;
    
    % Initialize edge lists
    fromNodes = ones(R,1);
    toNodes = 2*ones(R,1);
    capacities = rand(R,1)*N/3;
    lengths = nan(numLinks,1);
    freeFlowTimes = rand(R,1).*(N./(3*capacities));

    % Create directed graph
    nodeIDs = string(unique([fromNodes(:); toNodes(:)]));
    G = digraph(fromNodes, toNodes, freeFlowTimes,nodeIDs);  % Using free flow time as weight   

    % Initialize storage
    nodeIDs = (1:numNodes)';
    xCoords = [0;1];
    yCoords = [0;0];

    % Ensure node order matches coordinates
    % (digraph nodes may be reordered internally)
    nodeNames = str2double(G.Nodes.Name);  % Convert node names to numeric IDs

    % Get matching coordinates for current graph nodes
    [~, idx] = ismember(nodeNames, nodeIDs);
    x = xCoords(idx);
    y = yCoords(idx);

    OD = zeros(numNodes, numNodes);  % OD(i, j): demand from i to j
    OD(1,2) = N;
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
    network.nodePos = [x y];
    % Characterize edges
    network.edgeCapacity = capacities';
    network.edgeLength = lengths';
    network.edgeFFTime = freeFlowTimes';
    % Characterize demand
    network.demand = demand;
end