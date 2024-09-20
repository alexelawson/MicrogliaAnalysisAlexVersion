// Color-by-cluster morphology script
// Jenn Kim
// July 25, 2024
 
// FUNCTIONS

// find ROIs by name
// function adapted from:
// https://forum.image.sc/t/selecting-roi-based-on-name/3809 
function findRoiWithName(roiName) { 
	nR = roiManager("Count"); 
 
	for (i=0; i<nR; i++) { 
		roiManager("Select", i); 
		rName = Roi.getName(); 
		if (matches(rName, roiName)) { 
			return i; 
		} 
	} 
} 

// Function to open the file
function openFile(filePath) {
    if (File.exists(filePath)) {
        open(filePath);
    } 
}

// Function to list files and search for matching filenames
function listFiles(dir, numFiles, fileList, searchString) {
    //dir = File.openDirectory(directory);
    //dir = directory;
    //numFiles = dir.getFileCount();
    for (i = 0; i < (numFiles); i++) {
        fileName = fileList[i];
        if (substring(fileName, 0, lengthOf(searchString)) == searchString){
        	openFile(dir + fileName);
            print(dir + fileName);
        }
        }
    }


// MACRO STARTS HERE

//Welcome message
		Dialog.create("MicrogliaMorphology");
		Dialog.addMessage("Welcome to MicrogliaMorphology's ColorByCluster feature!");
		Dialog.addMessage("The complimentary ColorByCluster features within MicrogliaMorphology and MicrogliaMorphologyR allow you to color your microglia cells by their morphological cluster IDs.");
		Dialog.addMessage("This allows for visual verification of hypothesized cluster characterizations.");
		Dialog.addMessage("Please make sure to use the complimentary MicrogliaMorphologyR package to generate your ColorByCluster.csv file prior to this step.");
		Dialog.addMessage("If you have not done this yet, please do so first and come back to MicrogliaMorphology's ColorByCluster feature. If you are ready, continue on:");
		Dialog.show();

		Dialog.create("MicrogliaMorphology");
		Dialog.addMessage("If you want to batch process your images for ColorByCluster, please make sure that your original input images, thresholded images,"); 
		Dialog.addMessage("and ColorByCluster csv files all have the same starting string (see Github page for examples).");
		Dialog.addCheckbox("Do you want to use batch mode for a set of images?", true);
		Dialog.show();
		
		batchmodechoice = Dialog.getCheckbox();

//use file browser to choose path and files to run plugin on

// if batch mode = yes
	if(batchmodechoice){
		setOption("JFileChooser",true);
		
		// original input .tiff images
		ColorByCluster_originalimages_dir = getDirectory("Choose parent folder containing original .tiff images that you used as input for MicrogliaMorphology");
		ColorByCluster_originalimages = getFileList(ColorByCluster_originalimages_dir);
		ColorByCluster_originalimages_count = ColorByCluster_originalimages.length;
		
		// thresholded .tiff images
		ColorByCluster_thresholdedimages_dir = getDirectory("Choose parent folder containing thresholded .tiff images that were generated by MicrogliaMorphology from your original input images.");
		ColorByCluster_thresholdedimages = getFileList(ColorByCluster_thresholdedimages_dir);
		ColorByCluster_thresholdedimages_count = ColorByCluster_thresholdedimages.length;
		
		// ColorByCluster .csv files
		ColorByCluster_clusters_dir = getDirectory("Select the .csv files generated from MicrogliaMorphologyR which contain the cluster labels for the final microglia cells from your images.");
		ColorByCluster_clusters = getFileList(ColorByCluster_clusters_dir);
		ColorByCluster_clusters_count = ColorByCluster_clusters.length;
		
		// Directory to save final ColorByCluster images to 
		ColorByCluster_output = getDirectory("Select the directory you want to save your final ColorByCluster images to");
		
		// customize colors for up to 10 cluster labels
		Dialog.create("MicrogliaMorphology");
		Dialog.addMessage("In the sections below, specify what colors you want your morphological clusters to be in the image.");
		Dialog.addMessage("You can format your color choices as HEX code (e.g., BBCC33)");
		Dialog.addMessage("or any of the following colors: black, white, cyan, magenta, yellow, red, green, blue, and orange");
		Dialog.addString("Cluster 1:", "BBCC33");
		Dialog.addString("Cluster 2:", "44BB99");
		Dialog.addString("Cluster 3:", "EEDD88");
		Dialog.addString("Cluster 4:", "EE8866");
		Dialog.addString("Cluster 5:", "red");
		Dialog.addString("Cluster 6:", "green");
		Dialog.addString("Cluster 7:", "blue");
		Dialog.addString("Cluster 8:", "yellow");
		Dialog.addString("Cluster 9:", "orange");
		Dialog.addString("Cluster 10:", "cyan");
		Dialog.show();	
		
		Cluster1 = Dialog.getString();
		Cluster2 = Dialog.getString();
		Cluster3 = Dialog.getString();
		Cluster4 = Dialog.getString();
		Cluster5 = Dialog.getString();
		Cluster6 = Dialog.getString();
		Cluster7 = Dialog.getString();
		Cluster8 = Dialog.getString();
		Cluster9 = Dialog.getString();
		Cluster10 = Dialog.getString();
		
		// loop through original images
		for(i=0; i<(ColorByCluster_originalimages_count); i++){
			
			// extract out common string to search for across folders from original .tiff files
			ColorByCluster_originalimage = ColorByCluster_originalimages[i];
			subStringArray = split(ColorByCluster_originalimage, "(\.tif)");
			StringToSearchFor = subStringArray[0]; 
			print(StringToSearchFor);
			
			// loop through thresholded folder, find the file with matching string, open, and print file name
			listFiles(ColorByCluster_thresholdedimages_dir, ColorByCluster_thresholdedimages_count, ColorByCluster_thresholdedimages, StringToSearchFor);
			
			run("ROI Manager...");
			roiManager("Show All");
			roiManager("Show None");
			run("Analyze Particles...", "pixel add");
			close();
				
			// open original .tiff file and print file name
			open(ColorByCluster_originalimages_dir + ColorByCluster_originalimage);
			print(ColorByCluster_originalimages_dir + ColorByCluster_originalimage);
			
			// loop through ColorByCluster csv files folder, find the file with matching string, open, and print file name
			listFiles(ColorByCluster_clusters_dir, ColorByCluster_clusters_count, ColorByCluster_clusters, StringToSearchFor);
			
			x = File.openAsString(ColorByCluster_clusters_dir + ColorByCluster_clusters[i]);
			rows = split(x,"\n");	
		
			roiManager("Show All without labels");
			roiManager("Set Color", "black");
			
			// ColorByCluster
			for(n=0; n<rows.length-1; n++) {
				cluster = Table.getString("Cluster",n);
			
					if(cluster==1){
						label2 = Table.getString("ID",n);
						roi_idx = findRoiWithName(label2);
						roiManager("Select", roi_idx);
						Roi.setFillColor(Cluster1);
				}
				
					if(cluster==2){
						label2 = Table.getString("ID",n);
						roi_idx = findRoiWithName(label2);
						roiManager("Select", roi_idx);
						Roi.setFillColor(Cluster2);
				}
				
					if(cluster==3){
						label2 = Table.getString("ID",n);
						roi_idx = findRoiWithName(label2);
						roiManager("Select", roi_idx);
						Roi.setFillColor(Cluster3);
				}
				
					if(cluster==4){
						label2 = Table.getString("ID",n);
						roi_idx = findRoiWithName(label2);
						roiManager("Select", roi_idx);
						Roi.setFillColor(Cluster4);
				}
				
					if(cluster==5){
						label2 = Table.getString("ID",n);
						roi_idx = findRoiWithName(label2);
						roiManager("Select", roi_idx);
						Roi.setFillColor(Cluster5);
				}
				
					if(cluster==6){
						label2 = Table.getString("ID",n);
						roi_idx = findRoiWithName(label2);
						roiManager("Select", roi_idx);
						Roi.setFillColor(Cluster6);
				}
				
					if(cluster==7){
						label2 = Table.getString("ID",n);
						roi_idx = findRoiWithName(label2);
						roiManager("Select", roi_idx);
						Roi.setFillColor(Cluster7);
				}
				
					if(cluster==8){
						label2 = Table.getString("ID",n);
						roi_idx = findRoiWithName(label2);
						roiManager("Select", roi_idx);
						Roi.setFillColor(Cluster8);
				}
				
					if(cluster==9){
						label2 = Table.getString("ID",n);
						roi_idx = findRoiWithName(label2);
						roiManager("Select", roi_idx);
						Roi.setFillColor(Cluster9);
				}
				
					if(cluster==10){
						label2 = Table.getString("ID",n);
						roi_idx = findRoiWithName(label2);
						roiManager("Select", roi_idx);
						Roi.setFillColor(Cluster10);
				}
			
			}
			
			run("Flatten");
			
			// save into ColorByCluster images
			saveAs("Tiff", ColorByCluster_output + ColorByCluster_originalimage + "_ColorByCluster");
			
			// close everything
			close();
			close();
			selectWindow("ROI Manager");
			run("Close");
			selectWindow(ColorByCluster_clusters[i]);
			run("Close");
		}
		print("done!");
	}

// if batch mode = no
else {
		setOption("JFileChooser",true);
		
		ColorByCluster_originalimage = File.openDialog("Select the original .tiff image that you used as input for MicrogliaMorphology.");
		ColorByCluster_thresholdedimage = File.openDialog("Select the thresholded .tiff image that was generated by MicrogliaMorphology from your original input image.");
		ColorByCluster_clusters = File.openDialog("Select the .csv file generated from MicrogliaMorphologyR which contains the cluster labels for the final microglia cells.");
		
		open(ColorByCluster_thresholdedimage);
		print(ColorByCluster_thresholdedimage);
		run("ROI Manager...");
		roiManager("Show All");
		roiManager("Show None");
		run("Analyze Particles...", "pixel add");
		close();
		
		open(ColorByCluster_originalimage);
		print(ColorByCluster_originalimage);
		
		open(ColorByCluster_clusters);
		print(ColorByCluster_clusters);
		
		x = File.openAsString(ColorByCluster_clusters);
		rows = split(x,"\n");	
		
		roiManager("Show All without labels");
		roiManager("Set Color", "black");

// customize colors for up to 10 cluster labels
		//dialog box
		Dialog.create("MicrogliaMorphology");
		Dialog.addMessage("In the sections below, specify what colors you want your morphological clusters to be in the image.");
		Dialog.addMessage("You can format your color choices as HEX code (e.g., BBCC33)");
		Dialog.addMessage("or any of the following colors: black, white, cyan, magenta, yellow, red, green, blue, and orange");
		Dialog.addString("Cluster 1:", "BBCC33");
		Dialog.addString("Cluster 2:", "44BB99");
		Dialog.addString("Cluster 3:", "EEDD88");
		Dialog.addString("Cluster 4:", "EE8866");
		Dialog.addString("Cluster 5:", "red");
		Dialog.addString("Cluster 6:", "green");
		Dialog.addString("Cluster 7:", "blue");
		Dialog.addString("Cluster 8:", "yellow");
		Dialog.addString("Cluster 9:", "orange");
		Dialog.addString("Cluster 10:", "cyan");
		Dialog.show();	
		
		Cluster1 = Dialog.getString();
		Cluster2 = Dialog.getString();
		Cluster3 = Dialog.getString();
		Cluster4 = Dialog.getString();
		Cluster5 = Dialog.getString();
		Cluster6 = Dialog.getString();
		Cluster7 = Dialog.getString();
		Cluster8 = Dialog.getString();
		Cluster9 = Dialog.getString();
		Cluster10 = Dialog.getString();


// ColorByCluster
for(n=0; n<rows.length-1; n++) {
	cluster = Table.getString("Cluster",n);

		if(cluster==1){
			label2 = Table.getString("ID",n);
			roi_idx = findRoiWithName(label2);
			roiManager("Select", roi_idx);
			Roi.setFillColor(Cluster1);
	}
	
		if(cluster==2){
			label2 = Table.getString("ID",n);
			roi_idx = findRoiWithName(label2);
			roiManager("Select", roi_idx);
			Roi.setFillColor(Cluster2);
	}
	
		if(cluster==3){
			label2 = Table.getString("ID",n);
			roi_idx = findRoiWithName(label2);
			roiManager("Select", roi_idx);
			Roi.setFillColor(Cluster3);
	}
	
		if(cluster==4){
			label2 = Table.getString("ID",n);
			roi_idx = findRoiWithName(label2);
			roiManager("Select", roi_idx);
			Roi.setFillColor(Cluster4);
	}
	
		if(cluster==5){
			label2 = Table.getString("ID",n);
			roi_idx = findRoiWithName(label2);
			roiManager("Select", roi_idx);
			Roi.setFillColor(Cluster5);
	}
	
		if(cluster==6){
			label2 = Table.getString("ID",n);
			roi_idx = findRoiWithName(label2);
			roiManager("Select", roi_idx);
			Roi.setFillColor(Cluster6);
	}
	
		if(cluster==7){
			label2 = Table.getString("ID",n);
			roi_idx = findRoiWithName(label2);
			roiManager("Select", roi_idx);
			Roi.setFillColor(Cluster7);
	}
	
		if(cluster==8){
			label2 = Table.getString("ID",n);
			roi_idx = findRoiWithName(label2);
			roiManager("Select", roi_idx);
			Roi.setFillColor(Cluster8);
	}
	
		if(cluster==9){
			label2 = Table.getString("ID",n);
			roi_idx = findRoiWithName(label2);
			roiManager("Select", roi_idx);
			Roi.setFillColor(Cluster9);
	}
	
		if(cluster==10){
			label2 = Table.getString("ID",n);
			roi_idx = findRoiWithName(label2);
			roiManager("Select", roi_idx);
			Roi.setFillColor(Cluster10);
	}

}

run("Flatten");
print("done!");
)
}