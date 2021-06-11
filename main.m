clearvars -except
close all;
clc;
% Script description

% Change the configuration in Config class
config = Config.getInstance;
delete(config); % Delete previous instance of Config
config = Config.getInstance;

datasetResults = [];
iDataset = 0;

tic
switch config.EVALUATE_DATASETS
    case 'single'
        [ref, result, ~] = evaluateDataset();
        disp('Plotting results...')
        plotResults(ref, result);
    case 'all'
        campaignNames = getValidDir(config.obsDataPath);
        for iCampaign = 1:length(campaignNames)
            config.campaignName = campaignNames{iCampaign};
            campaignPath = [config.obsDataPath campaignNames{iCampaign} filesep];
            phoneNames = getValidDir(campaignPath);
            for iPhone = 1:length(phoneNames)
                config.phoneName = phoneNames{iPhone};
                fprintf('Evaluating %s/%s \n', config.campaignName, config.phoneName)
                iDataset = iDataset + 1;
                [datasetResults(iDataset).ref, datasetResults(iDataset).result, resultsFilePath] ...
                    = evaluateDataset();
                datasetResults(iDataset).campaignName = campaignNames{iCampaign};
                datasetResults(iDataset).phoneName = phoneNames{iPhone};
                % RTK and WLS estimations to Geodetic
                idxStatePos = PVTUtils.getStateIndex(PVTUtils.ID_POS);
                datasetResults(iDataset).result.estPosLla = ...
                    ecef2geodeticVector(datasetResults(iDataset).result.xEst(idxStatePos, :)');
                datasetResults(iDataset).result.estPosWLSLla = ...
                    ecef2geodeticVector(datasetResults(iDataset).result.xWLS(1:3, :)');
            end
        end
        % Compare output file with sample submission
        if strcmp(config.DATASET_TYPE, 'test')
            checkOutputFile(resultsFilePath);
        end
        % Save all results in a mat file
        resMatPath = [workspacePath 'data' filesep 'results' filesep config.DATASET_TYPE filesep 'all' filesep];
        resMatName = [config.RES_FILENAME '_' config.resFileTimestamp '.mat'];
        save([resMatPath resMatName], 'datasetResults');
    otherwise
        error('Invalid field for Config.EVALUATE_DATASETS, choose among ''single'' and ''all''');
end
toc