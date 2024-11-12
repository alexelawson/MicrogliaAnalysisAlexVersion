/*
 * ImageJ Macro to take a parent folder with subfolders of RGB images, convert each image to binary, 
 * and save the result in a corresponding output folder structure.
 * Created by Alex Lawson and modified to handle nested folder structures.
 */
 
Dialog.create("Choice");
Dialog.addMessage("Open the parent folder containing subfolders of images you want to convert to binary.");
Dialog.show();

// Opens the file browser for user to choose the parent directory with subfolders of images 
setOption("JFileChooser", true);
parent_input_dir = getDirectory("Choose parent folder containing subfolders of images");
parent_output_dir = getDirectory("Choose parent output folder for saving binary images");

// Recursively process each folder and image
processFolder(parent_input_dir, parent_output_dir);

Dialog.create("End of Program");
Dialog.addMessage("Program completed. The binary images have been saved in the output folder with the same folder structure as the input.");
Dialog.show();

/*
 * Recursive function to process each folder and convert images to binary
 * Args: input_folder - the current input folder path
 *       output_folder - the current output folder path
 */
function processFolder(input_folder, output_folder) {
    // Get a list of all files and folders in the current input folder
    items = getFileList(input_folder);
    
    for (i = 0; i < items.length; i++) {
        item = items[i];
        input_path = input_folder + item;
        output_path = output_folder + item;

        if (File.isDirectory(input_path)) {
            // If the item is a subfolder, create a corresponding folder in the output and process it recursively
            File.makeDirectory(output_path);
            processFolder(input_path + "/", output_path + "/");
        } else if (endsWith(item, ".tif")) {
            // If the item is an image file, convert and save it to the output folder
            multipleBinaryConversion(input_folder, output_folder, item);
        }
    }
}

/*
 * Function to convert an image into binary
 * Args: img_name - string, name of the image to process
 */
function imageConversion(img_name) {
    img_namenoext = replace(img_name, ".tif", "");
    run("Make Composite");
    run("Split Channels");
    selectWindow("C2-" + img_name);
    run("Duplicate...", " ");
    selectWindow("C3-" + img_name); 
    run("Close");
    selectWindow("C1-" + img_name); 
    run("Close");
    selectWindow("C2-" + img_name); 
    run("Close");
    selectWindow("C2-" + img_namenoext + "-1.tif");
    run("8-bit");
    run("Grays");
    run("Brightness/Contrast...");
    run("Enhance Contrast", "saturated=0.35");
    run("Apply LUT");
    setThreshold(68, 255);    
    run("Despeckle");
    setOption("BlackBackground", true);
    run("Convert to Mask", "method=Default background=Dark dark");
    run("Remove Outliers...", "radius=2 threshold=50 which=Bright");
    run("Analyze Particles...", "size=600-Infinity pixel show=[Masks]");
    run("Invert LUTs");
    selectWindow("C2-" + img_namenoext + "-1.tif");
    run("Close");
}

/*
 * Function to convert multiple images to binary 
 * Args: input - directory with images to convert, output - directory to save images, filename - image to process  
 */
function multipleBinaryConversion(input, output, filename) {
    print(input + filename);
    open(input + filename);
    img_name = getTitle();
    dirCropOutput = output;
    imageConversion(img_name);
    notiff = replace(img_name, ".tif", "");
    saveAs("Tiff", dirCropOutput + notiff);
    selectWindow(img_name);
    run("Close");
}
