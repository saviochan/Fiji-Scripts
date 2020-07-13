
function zProfile() {
	image = getImageID();
	for (R=0; R<roiManager("count"); R++) {
		selectImage(image);
		roiManager("Select", R);
		ROI = call("ij.plugin.frame.RoiManager.getName", R);
		run("Plot Z-axis Profile");
		rename(x+" "+ROI+" z profile");
	}
}

//Select the calcium channel and generate delta F.//
//waitForUser("Select Calcium Channel","Select the image stack to use, then press 'OK'.");
x = getTitle();
divideStack();

//Select ROIs.//
//waitForUser("Select ROIs","Select of open ROIs and add them to the ROI manager. When you are finished, press 'OK'.");
zProfile();

selectWindow("Results"); 
run("Close"); 