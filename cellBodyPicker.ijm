//script to select cell bodies from 2d images
//if working with stacks, make a max projection before running
//made 141009 by Jason Pitt, PhD
//distribute freely

function flatField() {
	name = getTitle();
	run("Duplicate...", " ");
	rename("flat");
	run("Gaussian Blur...", "sigma=50");
	imageCalculator("Divide create 32-bit", name, "flat");
	rename(name + " flat field");
	for (loop=0; loop<3; loop++) {
		run("Smooth"); 
	}
	close("flat");
}

function removeExtensions(nloop) {
	run("Threshold...");
	waitForUser("Set Threshold","Set the threshold that picks up your cell body and minimal processes.");
	run("Convert to Mask");
	for (loop=0; loop<nloop; loop++) {
		run("Erode");
	}
	for (loop=0; loop<nloop; loop++) {
		run("Dilate");
	}
}

function measureCellBody() {
	run("Set Scale...", "distance=4.4925 known=1 pixel=1 unit=um");
	setTool("wand");
	waitForUser("Pick Cell Body", "Click on the cell, then press 'OK'.");
	run("Set Measurements...", "area mean perimeter shape feret's integrated median redirect=None decimal=3");
	run("Analyze Particles...", "clear summarize");
//	run("Measure");
}
run("Select All");
flatField();
removeExtensions(2);
measureCellBody();