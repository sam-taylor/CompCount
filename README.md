# CompCount
A tool to count total and RFP-labeled cells from Incucyte Zoom images

## Requirements
<ul>
  <li>Fiji - https://fiji.sc/</li>
  <li>BioVoxxel Toolbox - https://imagej.net/BioVoxxel_Toolbox</li>
  <li>IncuCyte ZOOM exported phase contrast (PC) and fluoro channel images</li>
</ul>

## Usage
The script operates on input folders containing PC and the corresponding RFP
images respectively. The script relies on consistent naming of the files in order
to match the PC image with its respective RFP image. RFP signal not contained in 
the area defined by the corresponding PC mask is ignored.

Phase contrast and fluoro channel TIFF images must have the following naming 
 convention: "XXXX_A1_1_2019y12m27d_13h00m.tif" 
	where:
<ul>
  <li>XXXX - file name text that does not contain "_"</li>
  <li>_A1 - well number from multi-well plate</li>
  <li>_1 - image number within the well</li>
  <li>_2019y12m27d_13h00m - timestamp</li>

</ul>

The code is optimized for the IncucyteZOOM machine using the PC3 cell line.
Individual applications may require optimization of the various parameters.

The cell counts as well as other summary statistics are exported to summary.txt
in the specified output folder. This can be imported into MATLAB to aggregate
the cell counts by well and timepoint.

## Description
This tool takes raw phase contrast (PC) and RFP images taken by the 
IncuCyte ZOOM system and applies a series of operations in ImageJ to identify 
and quantify individual cells in each channel. The script then saves the summary 
information and masks for each counted image in the output folder.

