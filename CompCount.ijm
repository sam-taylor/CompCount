/*
 * CompCount: A tool for live cell image analysis.
 * 
 * Requirements: 
 * -Fiji - https://fiji.sc/
 * -BioVoxxel Toolbox - https://imagej.net/BioVoxxel_Toolbox
 * -IncuCyte ZOOM exported phase contrast (PC) and fluoro channel images
 * 
 * Description:
 * This tool takes raw phase contrast (PC) and RFP images taken by the 
 * IncuCyte ZOOM system and applies a series of operations in ImageJ to identify 
 * and quantify individual cells in each channel. The script then saves the summary
 * information and masks for each counted image in the output folder.
 * 
 * Usage:
 * 
 * The script operates on input folders containing PC and the corresponding RFP
 * images respectively. The script relies on consistent naming of the files in order
 * to match the PC image with its respective RFP image. RFP signal not contained in 
 * the area defined by the corresponding PC mask is ignored.
 * 
 * Phase contrast and fluoro channel TIFF images must have the following naming 
 * convention: "XXXX_A1_1_2019y12m27d_13h00m.tif" 
 * 		where:
 * 			XXXX - file name text that does not contain "_"
 * 			_A1 - well number from multi-well plate
 * 			_1 - image number within the well
 * 			_2019y12m27d_13h00m - timestamp
 * 
 * The code below is optimized for the IncucyteZOOM machine using the PC3 cell line.
 * Individual applications may require optimization of the various parameters.
 * 
 */

#@ File (label = "Input PC directory", style = "directory") input
#@ File (label = "Input Red directory", style = "directory") inputRed
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tif") suffix

setBatchMode(true); //batch mode on
processFolder(input);
saveTable();
setBatchMode(false); //exit batch mode

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}

function processRedFolder(inputRed, image) {
	list = getFileList(inputRed);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(inputRed + File.separator + list[i]))
			processRedFolder(inputRed + File.separator + list[i], image);
		if(endsWith(list[i], image))
			processRedFile(inputRed, output, list[i]);
	}
}

function processFile(input, output, file) {
	
	image = substring(file, indexOf(file, "_"), lengthOf(file));
	open(input + File.separator + file);
	run("8-bit");

	//Here a bandpass filter is applied to sharpen the cell edges.
	run("Bandpass Filter...", "filter_large=1000 filter_small=5 suppress=None tolerance=5 autoscale saturate");
	run("Auto Threshold", "method=Default white show");

	//Depending on the camera and acquisition settings the ideal threshold may differ.
	//in place of the automatic threshold below, the user may wish to provide a constant
	//threshold that best separates the cells:
	
	//setOption("ScaleConversions", true);
	//setThreshold(0, 104);
	//setOption("BlackBackground", true);
	
	run("Convert to Mask");

	//This is a feature of the Biovoxxel Toolset that separates the cells.
	run("Watershed Irregular Features", "erosion=3 convexity_threshold=0 separator_size=0-5");

	//Here the binary image is analyzed for particle count. 
	rename("PC" + image);
	run("Analyze Particles...", "size=25-1500 pixel circularity=0.25-1.00 show=Overlay exclude clear include summarize add");
	saveAs("PNG",  output + File.separator + file + "_PCparts.png");

	//Here the folder with the RFP images is scanned for the matching image
	processRedFolder(inputRed, image);

	//The status of the script is reported to the log
	print("Processing: " + input + File.separator + file);
	print("Saving to: " + output);
	closeAllWindows();
}

function processRedFile(inputRed, output, file) {
	
	image = substring(file, indexOf(file, "_"), lengthOf(file));
	open(inputRed + File.separator + file);
	run("8-bit");

	//As with the PC image, a bandpass filter is used to sharpen the cell edges
	run("Bandpass Filter...", "filter_large=1000 filter_small=5 suppress=None tolerance=5 autoscale saturate");
	
	//The cells are threholded
	run("Auto Threshold", "method=Default white show");
	
	//These commands apply the mask of the PC image to the RFP image such that
	//RFP signal outside the PC mask is ignored
	roiManager("deselect")
	run("Select All");
	roiManager("Combine");
	run("Clear Outside");
	run("Select None");

	//Particles are analyzed and the RFP mask is saved
	rename("RFP" + image);
	run("Analyze Particles...", "size=25-1500 pixel circularity=0.25-1.00 show=Overlay exclude clear include summarize add");
	saveAs("PNG",  output + File.separator + file + "_RFPparts.png");
}

 function closeAllWindows () { 
      while (nImages>0) {
          selectImage(nImages);
          close(); 
      } 
  } 

function saveTable () {
	if (! isOpen("Summary")) {exit ("Summary Table")}
	selectWindow("Summary");
	saveAs("Text", output + File.separator + "summary" + ".txt");
}
