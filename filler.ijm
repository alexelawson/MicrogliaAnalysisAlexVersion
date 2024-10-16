macro "Fill ROI [f]" {
    if (selectionType != -1) {  // Check if there is a selection (ROI) active
        setForegroundColor(0, 0, 0);  // Set the fill color to black (RGB: 0, 0, 0)
        run("Fill");  // Fill the current ROI
    } else {
        print("No ROI selected");     // Inform the user if no ROI is selected
    }
}