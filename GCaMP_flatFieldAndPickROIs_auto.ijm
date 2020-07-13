//flat fielding script to correct for unevent background illumation
//made 141009 by Jason Pitt, PhD
//distribute freely

function flatField() {
	name = getTitle();
	run("Duplicate...", " ");
	rename("flat");
	run("Gaussian Blur...", "sigma=50");
	imageCalculator("Divide create 32-bit", name, "flat");
	rename(name + " flat field");
	for (loop=0; loop<5; loop++) {
		run("Smooth"); 
	}
	close("flat");
}

function renameAndSaveROIs() {
	n = roiManager("count"); 
	path = getInfo("image.directory");
	for (loop=0; loop<n; loop++) {
		m = loop+1;
		name = "cell "+m;
		file = path+name+".roi";
		roiManager("Select",loop);
		roiManager("Rename",name);
		saveAs("Selection",file);
	}
}
img = getImageID();
run("Select All");
flatField();
trash = getImageID();
setTool("wand");
run("Threshold...");
waitForUser("Pick Cell Bodies", "Add cell bodies to the ROI manager, then press 'OK'.");
selectImage(trash);
run("Close");
renameAndSaveROIs();
selectWindow("ROI Manager"); 
run("Close");
wait(50);
selectImage(img);
wait(50);
run("Close");