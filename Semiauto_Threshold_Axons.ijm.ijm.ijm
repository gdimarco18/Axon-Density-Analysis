//user select directory
dir = getDirectory("Select Animal Folder");

//create output folders

	//create z-projected output folder
	z_output_dir = dir + File.separator + "Z-Projected Images" + File.separator ; 
	File.makeDirectory(z_output_dir);

	//create Hessain filter output folder
	Hes_output_dir = dir + File.separator + "Hessain Filter Images" + File.separator ; 
	File.makeDirectory(Hes_output_dir);
	
	//create threshold output folder
	thresh_output_dir = dir + File.separator + "Thresholded Images" + File.separator ; 
	File.makeDirectory(thresh_output_dir);
	
//open the OIB folder & get file list
OIBdir = dir + File.separator + "Original OIBs" + File.separator;
fileList = getFileList(OIBdir);

//start batch mode
setBatchMode(true);

//Threshold Loop
for (i = 0; i < lengthOf(fileList); i++) {
	current_imagePath = OIBdir+fileList[i];
	if (!File.isDirectory(current_imagePath)){
		open(current_imagePath);
		getDimensions(width, height, channels, slices, frames);

		//split channels & select channel 1
		run("Split Channels");
		currentImgName = getTitle();
		if (startsWith(currentImgName, "C2-")) {
			close();
		}
		
		//create a z-projected image no threshold
		run("Green");
		run("RGB Color");
		run("Z Project...", "projection=[Sum Slices]");
		run("RGB Color");
		zImgName = getTitle();
		saveAs("Tiff", z_output_dir+zImgName);

		//apply FeatureJ Hessian filter
		run("8-bit");
		run("Invert LUT");
		run("FeatureJ Hessian", "smallest smoothing=1.0");
		setOption("ScaleConversions", true);
		HesImgName = getTitle();
		saveAs("Tiff", Hes_output_dir+HesImgName);

		//user defined set image threshold
		open(Hes_output_dir+HesImgName+".tif");
		run("8-bit");
		setAutoThreshold("Default");
		//run("Threshold...");
		//setThreshold(0, 167);
		setOption("BlackBackground", false);
		run("Convert to Mask");
		ThreshImgName = getTitle();
		saveAs("Tiff", thresh_output_dir+ThreshImgName);
	
		 //close all open images before starting the next one
		run("Close All");
	}
}			

setBatchMode(false);