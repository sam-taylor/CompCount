%%Wrangling the image analysis data

%%first, load the summary.txt file into MATLAB, using the first row as
%%varnames
PCCount = summary;

%%slice name cleanup
for n=1:length(PCCount.Slice)
   PCCount.Slice(n) = strrep(strrep(strrep(strrep(strrep(PCCount.Slice(n), ' ', ''), '__', '_'), '.tif', ''), 'rfp_', ''), 'RFP_RFP_', 'RFP_');
end

%%parsing the slice name for contextual data
chrs = cellfun(@char, PCCount.Slice(:), 'Uni',0);
splits = regexp(chrs, "_", 'split');
splits = vertcat( splits{:} );

%add these new variables to the original table
T = cell2table(splits,'VariableNames',{'Channel' 'Well' 'Frame' 'Date' 'Time'})
T = [PCCount T];

%T2 = mergevars(T, {'Date','Time'},'NewVariableName','Date_Time');

%consolidate the timestamp into a single variable
T.DateTime = strcat(T.Date, T.Time);

%this stat array counts the total cells in each well
statarray = grpstats(T,{'Channel','Well', 'DateTime'},{'sum'},...
                     'DataVars','Count');

%this stat array calculates the average cell size in each well--useful for
%quality control
statarray2 = grpstats(T,{'Channel','Well', 'DateTime'},{'mean'},...
                     'DataVars','AverageSize',);                 
%change your output filename to whatever you want. File will be written to
%the directory in which this script resides.
writetable(statarray2,'2020_05_16_TestOutput.csv');