importPackage(Packages.ij);
importPackage(Packages.ij.io);
importPackage(Packages.ij.plugin);
importPackage(Packages.ij.process);
importPackage(Packages.java.io);

// Select the folder containing the images
dir = IJ.getDirectory("Choose a Directory");

// Get the list of files in the directory
fileList = new File(dir).listFiles();

// Loop through each file in the directory
for (var i = 0; i < fileList.length; i++) {
    file = fileList[i];

    // Check if it's a valid image file
    if (file.isFile() && file.getName().endsWith(".tif")) {
        // Open the image
        imp = IJ.openImage(file.getAbsolutePath());
        
        if (imp != null) {
            // Split the channels into RGB
            IJ.run(imp, "RGB Stack", "");

            // Save the result, replacing the original image
            IJ.save(imp, file.getAbsolutePath());
            
            // Close the image to free memory
            imp.close();
        }
    }
}