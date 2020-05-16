/*
 * Macro template to process multiple images in a folder
 */

#@ File (label = "Input PC directory", style = "directory") input
#@ File (label = "Input Red directory", style = "directory") inputRed
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tif") suffix

// See also Process_Folder.py for a version of this code
// in the Python scripting language.

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
			processFolder(inputRed + File.separator + list[i]);
		if(endsWith(list[i], image))
			processRedFile(inputRed, output, list[i]);
	}
}

function processRedFile(inputRed, output, file) {
	print(file);
	image = substring(file, indexOf(file, "_"), lengthOf(file));
	open(inputRed + File.separator + file);
		
	run("8-bit");
	
	run("Bandpass Filter...", "filter_large=1000 filter_small=5 suppress=None tolerance=5 autoscale saturate");
	
	run("Auto Threshold", "method=Default white");
	
	roiManager("deselect")
	
	run("Select All");
	
	roiManager("Combine");
	
	run("Clear Outside");
	
	run("Select None");

	rename("RFP" + image);
	run("Analyze Particles...", "size=50-1500 pixel circularity=0.25-1.00 show=Overlay exclude clear include summarize add");
}

function processFile(input, output, file) {
	// Do the processing here by adding your own code.
	// Leave the print statements until things work, then remove them.
	
	print(file);
	image = substring(file, indexOf(file, "_"), lengthOf(file));
	open(input + File.separator + file);
	
	run("8-bit");

	run("Directional Filtering", "type=Max operation=Opening line=10 direction=32");
	
	setOption("ScaleConversions", true);
	
	setThreshold(0, 104);
	
	setOption("BlackBackground", true);
	
	run("Convert to Mask");
	
	run("Bandpass Filter...", "filter_large=1000 filter_small=5 suppress=None tolerance=5 autoscale saturate");

	run("H_Watershed", "impin=[123119-directional] hmin=69.0 thresh=119.0 peakflooding=100.0 outputmask=true allowsplitting=true");

    close();
	rename("PC" + image);
	run("Analyze Particles...", "size=50-1500 pixel circularity=0.25-1.00 show=Overlay exclude clear include summarize add");
	
	processRedFolder(inputRed, image);

	print("Processing: " + input + File.separator + file);
	print("Saving to: " + output);
}

	
function saveTable () {
	if (! isOpen("Summary")) {exit ("Summary Table")}
	selectWindow("Summary");
	saveAs("Text", output + File.separator + "summary" + ".txt");
}

