//This macro is designed to calculate delta F over F for preselected ROIs.

//Made by Jason Pitt, PhD. Version 1.0, February 7, 2014. Distribute freely.

function divideStack(img) {
	selectImage(img);
	x = getTitle();
	Stack.getDimensions(width, height, channels, slices, frames);
	rename("original");
	run("Z Project...", "start=1 stop="+slices+" projection=[Average Intensity]");
	rename("average");
	newImage("delta F", "32-bit black", width, height, slices);
	setMinAndMax(1.05,1.25);
	setBatchMode(true);
	for (z=1; z<slices+1; z++) {
		selectImage("original");
		setSlice(z);
		imageCalculator("Divide create 32-bit", "original", "average");
		wait(50);
		rename("temp");
		run("Copy");
		selectImage("delta F");
		setSlice(z);
		run("Paste");
		selectImage("temp");
		close();
	}
	selectImage("average");
	close();
	setBatchMode(false);
	selectImage("original");
	rename(x);
}

function zProfile(img) {
	selectImage(img);
	x = getTitle();
	for (R=0; R<roiManager("count"); R++) {
		selectImage("delta F");
		roiManager("Select", R);
		ROI = call("ij.plugin.frame.RoiManager.getName", R);
		run("Plot Z-axis Profile");
		rename(x+" "+ROI+" z profile");
		//rename("Zprofile");
		//rename(ROI+" z profile");
	}
}

//function getValues(zprofile) {
//	selectImage(zprofile);
//	for (P=0; P<roiManager("count"); P++) {
//		selectImage("Zprofile");
//		Plot.getValue(X, Y);
		//selectImage("Zprofile"); close();
//	}
//}

function loadROIs() {
	if (nImages>0) {
		input_dir = getInfo("image.directory");
	}
	else {
		input_dir = getDirectory("Choose the directory with ROIs.");
	}
	list = getFileList(input_dir);
	
	for (i=0; i<list.length; i++) {
		showProgress(i+1, list.length);
		if (endsWith(list[i], ".roi")){
			roi = input_dir+list[i];
			roiManager("Open",roi);
		}
	}
	while (roiManager("count")==0) {
		input_dir = getDirectory("Choose the directory with ROIs.");
		list = getFileList(input_dir);
		for (i=0; i<list.length; i++) {
			showProgress(i+1, list.length);
			if (endsWith(list[i], ".roi")){
				roi = input_dir+list[i];
				roiManager("Open",roi);
			}
		}
	}
}

//select calcium time lapse
calcium = getTitle();

//remove first minute, as this typically bleaches
Stack.getDimensions(width, height, channels, slices, frames);
if (slices==660) {
	run("Slice Remover", "first=1 last=60 increment=1");
}

//load ROIs from same directory as calcium time lapse
if (roiManager("Count")==0) {
	selectImage(calcium);
	loadROIs();
}

divideStack(calcium);
zProfile(calcium);
//getValues(Zprofile);

selectWindow("Results"); run("Close"); 
selectWindow("ROI Manager"); run("Close");
selectImage(calcium); close();
selectImage("delta F"); close();