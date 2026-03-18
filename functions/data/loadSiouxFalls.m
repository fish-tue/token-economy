function network = loadSiouxFalls()
    % Parameters
    demand_thr = 1e3;


    % File paths
    filename_net = 'data/SiouxFalls/SiouxFalls_net.tntp';  % Replace with actual filename
    filename_coord = 'data/SiouxFalls/SiouxFalls_node.tntp';  % Replace with actual filename
    filename_od = 'data/SiouxFalls/SiouxFalls_trips.tntp';
    
    % Open file
    fid = fopen(filename_net);
    if fid == -1
        error('Failed to open file.');
    end
    
    % Initialize metadata
    numNodes = NaN;
    numLinks = NaN;
    
    % Read lines until metadata ends
    line = fgetl(fid);
    while ischar(line)
        % Try to capture number of nodes
        if contains(line, '<NUMBER OF NODES>')
            numNodes = sscanf(line, '%*s %d');
        elseif contains(line, '<NUMBER OF LINKS>')
            numLinks = sscanf(line, '%*s %d');
        elseif contains(line, '<END OF METADATA>')
            break;
        end
        line = fgetl(fid);
    end
    
    % Skip lines until data table starts
    while ischar(line) && ~startsWith(strtrim(line), '~')
        line = fgetl(fid);
    end
    line = fgetl(fid);  % Skip column header line
    
    % Initialize edge lists
    fromNodes = zeros(numLinks, 1);
    toNodes = zeros(numLinks, 1);
    capacities = zeros(numLinks, 1);
    lengths = zeros(numLinks, 1);
    freeFlowTimes = zeros(numLinks, 1);
    
    % Read link data
    linkIdx = 0;
    while ischar(line)
        line = strtrim(line);
        if isempty(line) || startsWith(line, '~') || startsWith(line, '<')
            line = fgetl(fid);
            continue;
        end
    
        data = sscanf(line, '%f');
        if numel(data) >= 5
            linkIdx = linkIdx + 1;
            fromNodes(linkIdx) = data(1);
            toNodes(linkIdx) = data(2);
            capacities(linkIdx) = data(3);
            lengths(linkIdx) = data(4);
            freeFlowTimes(linkIdx) = data(5);
        end
        line = fgetl(fid);
    end
    
    % Close file
    fclose(fid);
    
    % Adjust vector sizes in case actual number of links is less than metadata
    fromNodes = fromNodes(1:linkIdx);
    toNodes = toNodes(1:linkIdx);
    capacities = capacities(1:linkIdx);
    lengths = lengths(1:linkIdx);
    freeFlowTimes = freeFlowTimes(1:linkIdx);
    
    % Create directed graph
    nodeIDs = string(unique([fromNodes(:); toNodes(:)]));
    G = digraph(fromNodes, toNodes, freeFlowTimes,nodeIDs);  % Using free flow time as weight
    
    % Open the file
    fid = fopen(filename_coord);
    if fid == -1
        error('Failed to open coordinate file.');
    end
    
    % Skip header lines until we reach data
    line = fgetl(fid);
    while ischar(line)
        if contains(line, 'Node') && contains(line, 'X') && contains(line, 'Y')
            break;
        end
        line = fgetl(fid);
    end
    
    % Initialize storage
    nodeIDs = [];
    xCoords = [];
    yCoords = [];
    
    % Read coordinate lines
    line = fgetl(fid);
    while ischar(line)
        line = strtrim(line);
        if isempty(line) || startsWith(line, '~') || startsWith(line, '<')
            line = fgetl(fid);
            continue;
        end
        data = sscanf(line, '%f');
        if numel(data) >= 3
            nodeIDs(end+1,1) = data(1);
            xCoords(end+1,1) = data(2);
            yCoords(end+1,1) = data(3);
        end
        line = fgetl(fid);
    end

    fclose(fid);
    
    % Ensure node order matches coordinates
    % (digraph nodes may be reordered internally)
    nodeNames = str2double(G.Nodes.Name);  % Convert node names to numeric IDs

    % Get matching coordinates for current graph nodes
    [~, idx] = ismember(nodeNames, nodeIDs);
    x = xCoords(idx);
    y = yCoords(idx);
    

    
    % Open file
    fid = fopen(filename_od);
    if fid == -1
        error('Could not open OD demand file.');
    end
    
    % Skip metadata until <END OF METADATA>
    line = fgetl(fid);
    while ischar(line)
        if contains(line, '<END OF METADATA>')
            break;
        end
        line = fgetl(fid);
    end
    
    % Initialize storage
    numZones = 24;  % Or extract from metadata earlier if needed
    OD = zeros(numZones, numZones);  % OD(i, j): demand from i to j
    
    % Read demands
    origin = 0;

    while ischar(line)
        line = strtrim(line);
        
        % Check for "Origin" line
        if startsWith(line, 'Origin')
            tokens = regexp(line, 'Origin\s+(\d+)', 'tokens');
            if ~isempty(tokens)
                origin = str2double(tokens{1});
            end
        elseif contains(line, ':')
            % Read destination-demand pairs
            entries = regexp(line, '(\d+)\s*:\s*([\d\.]+)', 'tokens');
            for k = 1:length(entries)
                dest = str2double(entries{k}{1});
                demand = str2double(entries{k}{2});
                if demand >= demand_thr
                    OD(origin, dest) = demand;
                end
            end
        end
        
        line = fgetl(fid);
    end

    
    
    fclose(fid);
    [origins, destinations, demands] = find(OD);  % Find non-zero entries
    demand = [origins, destinations, round(demands)];
    
    % Scale this down
    demand(:,3) = round(demand(:,3)/10);
    capacities = capacities/20;
    
    %% Lite version :)
    % rng(0);
    % demand(:,3) = demand(:,3)/10;
    % capacities = capacities/10;
    % idx_demand = randperm(size(demand,1), 100);
    % demand = demand(idx_demand,:,:);


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