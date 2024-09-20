//// Microglia Morphology ImageJ macro
//// Created by Jenn Kim on September 18, 2022
//// Updated July 24, 2024
//// Updated again September 19th by Alex Lawson to finetune it for our project. 

// Helper Functions 

// Auto thresholding 
function thresholding(input, output, filename) {
		print(input + filename);
		open(input + filename);
	
		// MEASURE AREA
		run("Set Measurements...", "area display redirect=None decimal=9");
		run("Measure");
		
		// THRESHOLD IMAGE AND CLEAN UP FOR DOWNSTREAM PROCESSING IN ANALYZESKELETON
		run("8-bit");
		// convert to grayscale to best visualize all positive staining
		run("Grays");
		// adjust the brighness and contrast to make sure you can visualize all microglia processes
		// in ImageJ, B&C are changed by updating the image's lookup table, so pixel values are unchanged
		run("Brightness/Contrast...");
		run("Enhance Contrast", "saturated=0.35");
		// run Unsharp Mask filter to further increase contrast of image using default settings
		// this mask does not create details, but rather clarifies existing detail in image
		run("Unsharp Mask...", "radius=3 mask=0.60");
		// use despeckle function to remove salt&pepper noise generated by unsharp mask filter
		run("Despeckle");
		run("Auto Threshold", "method=&auto_method ignore_black white");
		if (roichoice){
			// exclude anything not within roi
			setBackgroundColor(0, 0, 0); 
			run("Clear Outside"); 
		}
		// use despeckle function to remove remaining single-pixel noise generated by thresholding
		run("Despeckle");
		// apply close function to connect any disconnected cell processes back to the rest of the cell
		// this function connects two dark pixels if they are separated by up to 2 pixels
		run("Close-");
		// after closing up cells, remove any outliers
		// replaces a bright or dark outlier pixel by the median pixels in the surrounding area if it deviates by more than the threshold value specified
		// here, bright outliers are targeted with pixel radius 2 and threshold of 50
		run("Remove Outliers...", "radius=2 threshold=50 which=Bright");
		// save thresholded + cleaned image -- this is the input for skeleton analysis below
		saveAs("Tiff", output + filename + "_thresholded");
		
		close();
	}
	
// Auto local thresholding 
function thresholding2(input, output, filename) {
		print(input + filename);
		open(input + filename);
		
		// MEASURE AREA
		run("Set Measurements...", "area display redirect=None decimal=9");
		run("Measure");
	
		// THRESHOLD IMAGE AND CLEAN UP FOR DOWNSTREAM PROCESSING IN ANALYZESKELETON
		run("8-bit");
		// convert to grayscale to best visualize all positive staining
		run("Grays");
		// adjust the brighness and contrast to make sure you can visualize all microglia processes
		// in ImageJ, B&C are changed by updating the image's lookup table, so pixel values are unchanged
		run("Brightness/Contrast...");
		run("Enhance Contrast", "saturated=0.35");
		// run Unsharp Mask filter to further increase contrast of image using default settings
		// this mask does not create details, but rather clarifies existing detail in image
		run("Unsharp Mask...", "radius=3 mask=0.60");
		// use despeckle function to remove salt&pepper noise generated by unsharp mask filter
		run("Despeckle");		
		run("Auto Local Threshold", "method=&autolocal_method radius=&autolocal_radius parameter_1=0 parameter_2=0 white");
		if (roichoice){
			// exclude anything not within roi
			setBackgroundColor(0, 0, 0); 
			run("Clear Outside"); 
		}
		// use despeckle function to remove remaining single-pixel noise generated by thresholding
		run("Despeckle");
		// apply close function to connect any disconnected cell processes back to the rest of the cell
		// this function connects two dark pixels if they are separated by up to 2 pixels
		run("Close-");
		// after closing up cells, remove any outliers
		// replaces a bright or dark outlier pixel by the median pixels in the surrounding area if it deviates by more than the threshold value specified
		// here, bright outliers are targeted with pixel radius 2 and threshold of 50
		run("Remove Outliers...", "radius=2 threshold=50 which=Bright");
		// save thresholded + cleaned image -- this is the input for skeleton analysis below
		saveAs("Tiff", output + filename + "_thresholded");
		
		close();
	}

//Generating Single Cell ROIs from thresholded images
function cellROI(input, output, filename){
		print(input + filename);
    	open(input + filename);
    	
    	mainTitle=getTitle();
		dirCropOutput=output;
		
	    run("ROI Manager...");
	    roiManager("Show All");
		roiManager("Deselect");
		run("Set Measurements...", "area display redirect=None decimal=3");

		run("Analyze Particles...", "pixel add");
		roiManager("Show All");
		roiManager("Measure");	
				
		for (i = 0; i < nResults(); i++) {
			selectWindow("Results");
				selectWindow("Results");
				label = getResultString("Label", i);
				label = label.replace(':','_');
				roiManager("Select", i);
				run("Duplicate...", "title=&label");
				setBackgroundColor(0, 0, 0);
				run("Clear Outside");
				saveAs("Tiff", dirCropOutput+File.separator+label+".tif");
				print(label);
				selectWindow(label+".tif");
				run("Close");				
		}
		selectWindow(mainTitle);
		run("Close");
		selectWindow("Results");
	   	run("Close");
	    selectWindow("ROI Manager");
	    run("Close");
    }


// Skeletonize/AnalyzeSkeleton
function skeleton(input, output, output2, filename) {
        print(input + filename);
        open(input + filename);

	      // SKELETON ANALYSIS !!
	      // Skeletonize your thresholded image
	      // this process basically systematically cuts down your thresholded processes from all sides into one single trace
	      run("Skeletonize (2D/3D)");
	      // run the AnalyzeSkeleton(2D/3D) plugin 
	      // this plugin will take your skeletonized cells and tag them with useful information (junctions, length, triple/quadruple points, etc.)
	      run("Analyze Skeleton (2D/3D)", "prune=none");
	      // summarize output across all cells and append to end of output data file
	      run("Summarize");
	      // save results
	      saveAs("Results", output + filename + "_results.csv");
	      // save tagged skeleton 
	      saveAs("Tiff", output2 + filename + "_taggedskeleton");
	      //close open windows
	      close();
	      close();
    }

// MACRO STARTS HERE

//Welcome message
		Dialog.create("MicrogliaMorphology");
		Dialog.addMessage("Welcome to Microglia Morphology (Alex's Edited Version, taken from Ciernia Lab)!");
		Dialog.addMessage("We will first specify some dataset-specific parameters before running MicrogliaMorphology.");
		Dialog.addMessage("Please make sure to use the BioVoxxel ImageJ plugin to determine your thresholding parameters prior to this step.");
		Dialog.addMessage("If you have not done this yet, please do so first and come back to MicrogliaMorphology. If you have, continue on :");
		Dialog.show();
		
//STEP 1. Deleted. For this protocol we thresholded images prior to importing them, this is because we wanted to perform manual edits (separating cells, etc)
//before generating single-cell ROIs


// STEP 2. Generating single-cell ROIs command
		Dialog.create("Single Cells.");
		Dialog.addMessage("We will now generate single cells from the thresholded image.");
		Dialog.show();

  		//use file browser to choose path and files to run plugin on
		setOption("JFileChooser",true);
		thresholded_dir=getDirectory("Choose parent folder containing thresholded images");
		thresholded_input=getFileList(thresholded_dir);
		count=thresholded_input.length;
	
		//use file browser to choose path and files to run plugin on
		setOption("JFileChooser",true);
		cellROI_output=getDirectory("Choose output folder to write single cell images to");
		
		//dialog box
		Dialog.create("MicrogliaMorphology");
		Dialog.addMessage("Processing files from directory:");
		parentname=split(thresholded_dir,"/");
		Dialog.addMessage(parentname[(parentname.length)-1]);
		Dialog.addMessage("which has this many images:");
		Dialog.addMessage(count);
		Dialog.addMessage("Select range of images you'd like to analyze");
		Dialog.addNumber("Start at Image:", 1);
		Dialog.addNumber("Stop at Image:", 1);
		Dialog.show();
		
		startAt=Dialog.getNumber();
		endAt=Dialog.getNumber();
		setBatchMode("show");
		for (i=(startAt-1); i<(endAt); i++){
				cellROI(thresholded_dir, cellROI_output, thresholded_input[i]);
		}
	    print("Finished generating single cell ROIs");

// Progress message
		Dialog.create("MicrogliaMorphology");
		Dialog.addMessage("Now that we are done generating single-cell ROIs,");
		Dialog.addMessage("we will analyze their skeletons");
		Dialog.show();

// STEP 3. Skeletonize/AnalyzeSkeleton
        
        //use file browser to choose path and files to run plugin on
		setOption("JFileChooser",true);
		cell_dir=getDirectory("Choose parent folder containing single-cell images");
		cell_input=getFileList(cell_dir);
		cell_count=cell_input.length;
	
		//use file browser to choose path and files to run plugin on
		setOption("JFileChooser",true);
		skeleton_output=getDirectory("Choose output folder to write skeleton results to");
		
		//use file browser to choose path and files to run plugin on
		setOption("JFileChooser",true);
		skeleton2_output=getDirectory("Choose output folder to write skeletonized images to");
		
		//dialog box
		Dialog.create("MicrogliaMorphology");
		Dialog.addMessage("Processing files from directory:");
		parentname=split(cell_dir,"/");
		Dialog.addMessage(parentname[(parentname.length)-1]);
		Dialog.addMessage("which has this many images:");
		Dialog.addMessage(cell_count);
		Dialog.addMessage("Select range of cell images you'd like to analyze");
		Dialog.addNumber("Start at Image:", 1);
		Dialog.addNumber("Stop at Image:", 1);
		Dialog.show();
		
		startAt=Dialog.getNumber();
		endAt=Dialog.getNumber();
       
    	setBatchMode("show");
		for (i=(startAt-1); i<(endAt); i++){
				skeleton(cell_dir, skeleton_output, skeleton2_output, cell_input[i]);
		}
		
		Dialog.create("Congrats.");
		Dialog.addMessage("You did it. Check the folders to make sure the output all worked.");
		print("Finished Analyzing Skeletons");