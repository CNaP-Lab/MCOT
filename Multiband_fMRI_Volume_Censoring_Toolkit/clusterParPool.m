function [completedParPool] = clusterParPool(varargin)
    datetime; pause(1); drawnow;
    maxRandomWaitTime = 15; % seconds - try to prevent parpool initialization collisions
    distcomp.feature('LocalUseMpiexec', false );  pause(1); drawnow;
    parPoolTest = gcp('nocreate'); pause(1); drawnow;
    if (~isempty(parPoolTest))
        completedParPool = true;
    else
        completedParPool = false;
    end
    while(~completedParPool)
        try
            distcomp.feature('LocalUseMpiexec', false ); pause(1); drawnow;
            if (nargin > 0)
                numWorkers = varargin{1};
            else
                numWorkers = 40;  % CHANGE THIS TO CHANGE THE DEFAULT NUMBER OF WORKERS!  Should usually be 40...
            end
            pauseTime = randi(maxRandomWaitTime);
            disp(['Waiting to initialize parallel pool: ' num2str(pauseTime)]); pause(1); drawnow;
            delete(gcp('nocreate')); pause(1); drawnow;
            pause(pauseTime); drawnow;
            disp('Initializing parallel pool'); pause(1); drawnow;
            delete(gcp('nocreate')); pause(1); drawnow;
            parpool(numWorkers); pause(1); drawnow;
            parPoolTest = gcp('nocreate'); pause(1); drawnow;
            if (~isempty(parPoolTest))
                completedParPool = true;
            end
        catch parPoolError
            try
                completedParPool = false;
                disp(parPoolError); pause(1); drawnow;
                delete(gcp('nocreate')); pause(1); drawnow;
                disp('Waiting before retrying to initialize parallel pool.'); pause(1); drawnow;
                pauseTime = randi(maxRandomWaitTime);
                pause(pauseTime); drawnow;
            catch weirdUnexpectedError
                disp(weirdUnexpectedError); pause(1); drawnow;
            end
        end
    end
    datetime; pause(1); drawnow;
end
