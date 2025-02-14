function root=dTree(XtrainWithLabels, maxDepth, randomFeatures, chi)
    XtrainWithLabels = double(XtrainWithLabels); % converts to doubles
    root = growTree(XtrainWithLabels, 0, maxDepth, randomFeatures, chi);
    
function node=growTree(root, depth, maxDepth, randomFeatures, chi)
    previousEntropy = calculateEntropy(root); % initial entropy
    if previousEntropy == 0 || depth >= maxDepth
        node.attr = 0;
        node.label = getMajority(root);
        return;
    end
    numFeatures = size(root, 2)-1;
    nonSpams = root( root(:,numFeatures+1)==0, : ); % matrix of non spams
    spams = root( root(:,numFeatures+1)==1, : ); % matrix of spams
    attrMeansNonSpams = mean(nonSpams, 1); % means of the attributes of the non spams, expected size 1*57
    attrMeansSpams = mean(spams, 1);
    attrMeans = mean([attrMeansNonSpams;attrMeansSpams], 1); % mean of the means
    maxInfoGain = -Inf;
    bestAttr = 0;
    bestLeftSubtree = [];
    bestRightSubtree = [];
    numFeatures = 1:numFeatures;
    if randomFeatures
        perm = randperm( size(numFeatures,2) );
        perm = perm( 1: ceil(sqrt( size(numFeatures,2) ) ) );
        numFeatures = perm;
    end
    for i=1:size(numFeatures,2)
        leftSubtree = root( root(:,numFeatures(i))<attrMeans(numFeatures(i)), : ); % data that belongs to left subtree
        rightSubtree = root( root(:,numFeatures(i))>=attrMeans(numFeatures(i)), : ); % data that belongs to right subtree
        sizeLeft = size(leftSubtree, 1);
        sizeRight = size(rightSubtree, 1);
        totalSize = sizeLeft+sizeRight;
        if sizeLeft == 0
            weightedEntropy = sizeRight/totalSize * calculateEntropy(rightSubtree);
        elseif sizeRight == 0
            weightedEntropy = sizeLeft/totalSize * calculateEntropy(leftSubtree);
        else
            weightedEntropy = sizeLeft/totalSize * calculateEntropy(leftSubtree) + sizeRight/totalSize * calculateEntropy(rightSubtree);
        end
        infoGain = previousEntropy - weightedEntropy;
        %disp(['inside loop initial entropy: ' num2str(previousEntropy) ' infoGain: ' num2str(infoGain)]);
        if infoGain > maxInfoGain
           %disp(' found max ');
           bestAttr = numFeatures(i);
           maxInfoGain = infoGain;
           bestLeftSubtree = leftSubtree;
           bestRightSubtree = rightSubtree;
        end
    end
    if maxInfoGain == 0
        node.attr = 0;
        node.label = getMajority(root);
    else
        if chi
            c = calculateChiSquareValue(root, bestLeftSubtree, bestRightSubtree);
            if c <= 3.8415
                node.attr = 0;
                node.label = getMajority(root);
                return;
            end
        end
        node.left = growTree(bestLeftSubtree, depth+1, maxDepth, randomFeatures, chi);
        node.right = growTree(bestRightSubtree, depth+1, maxDepth, randomFeatures, chi);
        node.attr = bestAttr;
        node.splitpoint = attrMeans(bestAttr);
    end
    
function c=calculateChiSquareValue(tree, bestLeftSubtree, bestRightSubtree)
    numFeatures = size(tree, 2)-1;
    p = double(size(tree, 1));
    nonSpams = tree( tree(:,numFeatures+1)==0, : ); % matrix of non spams
    spams = tree( tree(:,numFeatures+1)==1, : ); % matrix of spams
    s = double(size(spams, 1));
    h = double(size(nonSpams, 1));
    pl = double(size(bestLeftSubtree, 1));
    nonSpamsLeft = bestLeftSubtree( bestLeftSubtree(:,numFeatures+1)==0, : ); % matrix of non spams
    spamsLeft = bestLeftSubtree( bestLeftSubtree(:,numFeatures+1)==1, : ); % matrix of spams
    sl = double(size(spamsLeft, 1));
    hl = double(size(nonSpamsLeft, 1));
    pr = double(size(bestRightSubtree, 1));
    nonSpamsRight = bestRightSubtree( bestRightSubtree(:,numFeatures+1)==0, : ); % matrix of non spams
    spamsRight = bestRightSubtree( bestRightSubtree(:,numFeatures+1)==1, : ); % matrix of spams
    sr = double(size(spamsRight, 1));
    hr = double(size(nonSpamsRight, 1));
    c = (sl - s/p * pl)^2 / (s/p * pl) + (hl - h/p * pl)^2 / (h/p * pl) + (sr - s/p * pr)^2 / (s/p * pr) + (hr - h/p * pr)^2 / (h/p * pr);

function entropy=calculateEntropy(tree)
    numFeatures = size(tree, 2)-1;
    nonSpams = tree( tree(:,numFeatures+1)==0, : ); % matrix of non spams
    spams = tree( tree(:,numFeatures+1)==1, : ); % matrix of spams
    numNonSpams = size(nonSpams, 1);
    numSpams = size(spams, 1);
    totalSize = numNonSpams + numSpams;
    %if totalSize==0
    %    entropy = 0;
    if numSpams/totalSize == 0
        entropy = - numNonSpams/totalSize * log2(numNonSpams/totalSize);
    elseif numNonSpams/totalSize == 0
        entropy = - numSpams/totalSize * log2(numSpams/totalSize);
    else
        entropy = - numSpams/totalSize * log2(numSpams/totalSize) - numNonSpams/totalSize * log2(numNonSpams/totalSize);
    end
    
function label=getMajority(tree)
    numFeatures = size(tree, 2)-1;
    nonSpams = tree( tree(:,numFeatures+1)==0, : ); % matrix of non spams
    spams = tree( tree(:,numFeatures+1)==1, : ); % matrix of spams
    numNonSpams = size(nonSpams, 1);
    numSpams = size(spams, 1);
    if numSpams >= numNonSpams
        label = 1;
    else
        label = 0;
    end
    
