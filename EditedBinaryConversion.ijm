Dialog.create("Choice");
Dialog.addMessage("Open the folder with images you want to convert to binary.");
Dialog.addCheckbox("Check here if only interested in processing 1 image", false);
Dialog.show();
userInputChoice = Dialog.getCheckbox();

if (userInputChoice==true){
	singleBinaryConversion();
}
else{
	Dialog.create("ImageOpener");
	Dialog.addMessage("Open the folder with images you want to convert to binary.");
	Dialog.show();
	
	//use file browser to choose path and files to run plugin on
	setOption("JFileChooser",true);
	image_dir=getDirectory("Choose parent folder containing images");
	image_input=getFileList(image_dir);
	count=image_input.length;
		
	//use file browser to choose path and files to run plugin on
	setOption("JFileChooser",true);
	binary_output=getDirectory("Choose output folder to write binary images to");
	
	for (i=(0); i<(count); i++){
		binaryConversion(image_dir, binary_output, image_input[i]);
	}
}

//Converting a RGB image into binary
function binaryConversion(input, output, filename){
	print(input + filename);
    open(input + filename);
    img_name=getTitle();
	dirCropOutput=output;
		
	img_namenoext = replace(img_name , ".tif" , "" );
	run("Make Composite");
	run("Split Channels");
	selectWindow("C2-"+img_name);
	run("Duplicate...", " ");
	selectWindow("C3-"+img_name);
	run("Close");
	selectWindow("C1-"+img_name);
	run("Close");
	selectWindow("C2-"+img_name);
	run("Close");
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
	saveAs("Tiff", dirCropOutput+ img_name);			
	selectWindow(img_name);
	run("Close");
    }
    
function singleBinaryConversion(){
	Dialog.create("ImageOpener");
	Dialog.addMessage("Open your original image");
	Dialog.show();
	originalImage = File.openDialog("Open your original test image");
	open(originalImage);
	originalImageID = getImageID();
	img_name = getTitle();
	img_namenoext = replace(img_name , ".tif" , "" );
	run("Make Composite");
	run("Split Channels");
	selectWindow("C2-"+img_name);
	run("Duplicate...", " ");
	selectWindow("C3-"+img_name);
	run("Close");
	selectWindow("C1-"+img_name);
	run("Close");
	selectWindow("C2-"+img_name);
	run("Close");
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
}
