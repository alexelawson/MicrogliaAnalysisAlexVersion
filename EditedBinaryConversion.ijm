Dialog.create("ImageOpener");
Dialog.addMessage("Open your original image");
Dialog.show();
originalImage = File.openDialog("Open your original test image");
open(originalImage);
originalImageID = getImageID();
img_name = getTitle();
/*
if (roiManager("count") != 0){
	roiManager("show all");
	roiManager("delete");
}
doneWithROI = false;
while (doneWithROI == false) {
	Dialog.createNonBlocking("ROI Creation");
	Dialog.addMessage("Trace your ROI. Press OK when done.");
	Dialog.addCheckbox("Are you done tracing all your ROI's", false);
	Dialog.show();
	roiManager("add");
	doneWithROI = Dialog.getCheckbox();
}
count = roiManager("count");
roiManager("combine");
roiManager("add");
for (i=0; i<count-2; i++){
	roiManager("deselect");
	roiManager("select", i);
	roiManager("delete");	
}
roiManager("delete");
waitForUser;
*/


img_namenoext = replace(img_name , ".tif" , "" );
run("Make Composite");
run("Split Channels");
selectWindow("C2-"+img_name);
run("Duplicate...", " ");
selectWindow("C3-"+img_name);
run("Close")
selectWindow("C1-"+img_name);
run("Close")
selectWindow("C2-"+img_name);
run("Close")
selectWindow("C2-"+img_namenoext+"-1.tif");
run("8-bit");
//convert to grayscale 
run("Grays");
run("Brightness/Contrast...");
run("Enhance Contrast", "saturated=0.35");
run("Unsharp Mask...", "radius=3 mask=0.60");
run("Despeckle");
//running the auto threshold method we determined to be the best fit
//run("Auto Threshold", "method=MaxEntropy ignore_black white"); 
setThreshold(40, 255, "raw");
setOption("BlackBackground", true);
run("Convert to Mask");
//replaces a bright or dark outlier pixel by the median of the pixels in the surrounding area
//area is set as a radius of 2, threshold set to define an outlier as anything >50% different
run("Remove Outliers...", "radius=2 threshold=50 which=Bright");
//Removes any cells below 600pix area using the white cell mask we created earlier
run("Analyze Particles...", "size=600-Infinity pixel show=[Masks]");
run("Invert LUTs");
selectWindow("C2-"+img_namenoext+"-1.tif");
run("Close");