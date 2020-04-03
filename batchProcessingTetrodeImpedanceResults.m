function batchProcessingTetrodeImpedanceResults
%% Import data from text file.
% Script for importing data from the following text file:
%
dataFolder = [];
fileName = [];

% The WHILE loop below prompts the user to select the folder containing the
% files to be batch processed for average power estimates in each of the
% previously user-defined frequency bands.
while isempty(dataFolder)
    dataFolder = uigetdir;
    fileName = ls(fullfile(dataFolder, '*.dta'));
    
    % This IF loop checks to see if there are files with the .DTA extension
    % in the selected folder. If there are no files in the selected folder,
    % the user will be prompted again to select a folder.
    if isempty(fileName)
        msgbox('No DTA data files exist in the selected folder. Please select a different folder.');
        dataFolder = [];
    end
end

[numberOfDataFiles,~] = size(fileName); % Finds the number of data files in the selected folder.

% The FOR loop below extracts impedance and phase data from DTA files one at a time
% and calculates the mean and standard deviation for each frequency band at
% each recording site in the user-defined bin size.
for i = 1:numberOfDataFiles
    % Import the data:
    delimiter = '\t';
    startRow = 98;
    % Format string for each line of text:
    %   column8: double (%f)
    %	column9: double (%f)
    formatSpec = '%*s%*s%*s%*s%*s%*s%*s%f%f%*s%*s%*s%[^\n\r]';
    % Open the text file.
    fileID = fopen(fullfile(dataFolder,fileName(i,:)),'r'); %Opens the file so that its content can be accessed

    % Read columns of data according to format string.
    % This call is based on the structure of the file used to generate this
    % code. If an error occurs for a different file, try regenerating the code
    % from the Import Tool.
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);

    % Close the text file.
    fclose(fileID);

    %% Allocate imported array to column variable names
    Zmod(i,:) = dataArray{:, 1}';
    Zphz(i,:) = dataArray{:, 2}';

    %% Clear temporary variables
    clearvars delimiter startRow formatSpec fileID dataArray;
end
prompt={'Enter batch processed results file name:'};
dlgTitle='Input for file management';
lineNo=1;
answer = inputdlg(prompt,dlgTitle,lineNo);
resultsFilename=char(answer(1,:));
save(fullfile(dataFolder,[resultsFilename '.mat']), 'Zmod', 'Zphz', 'dataFolder', 'fileName');
clear all
end