// Ask the user to choose a folder
setOption("JFileChooser",true);
dir=getDirectory("Choose parent folder containing thresholded images")


// Option for string replacement or appending
option = getString("Choose action: (1) Replace string or (2) Append string to end of filename", "");

// Get user inputs based on the option selected
if (option == "1") {
    stringToReplace = getString("String to replace", "");
    newString = getString("New string", "");
} else if (option == "2") {
    appendString = getString("String to append", "");
} else {
    exit("Invalid option selected.");
}

// Get a list of all files in the folder
list = getFileList(dir);

// Loop through each file
for (i = 0; i < list.length; i++) {
    filePath = dir + list[i];
    
    // Only proceed if it's a file (not a folder)
    if (File.isFile(filePath)) {
        originalName = list[i];
        newName = originalName; // Initialize newName

        if (option == "1") {
            // Replace the string in the filename if selected
            if (indexOf(originalName, stringToReplace) >= 0) {
                newName = replace(originalName, stringToReplace, newString);
            }
        } else if (option == "2") {
            // Append string to the filename without extension
            dotIndex = lastIndexOf(originalName, ".");
            if (dotIndex == -1) {
                newName = originalName + appendString; // No file extension
            } else {
                baseName = substring(originalName, 0, dotIndex);
                extension = substring(originalName, dotIndex);
                newName = baseName + appendString + extension;
            }
        }

        // Rename the file if the name has changed
        if (newName != originalName) {
            File.rename(filePath, dir + newName);
            print("Renamed: " + originalName + " -> " + newName);
        }
    }
}

print("Batch renaming complete.");