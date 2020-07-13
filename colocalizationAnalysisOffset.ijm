//IMAGEJ COLOCALIZATION ANALYSIS
//written by Jason Pitt, PhD. Distribute freely.
//version 1.0

 //This macro is used to calculate corrlation between two single planes or z stacks.

//built-in user-defined functions
//CHANGE AT YOUR OWN RISK
function closeROI() {
	if (isOpen("ROI Manager")) { 
		selectWindow("ROI Manager"); 
		run("Close"); 
	}
}

function makeROI(position,num) {
	selectImage(firstChannel);
	xPos=arrayX[position];
	yPos=arrayY[position];
	makeRectangle(xPos,yPos,length,length);
	run("Add to Manager");
	roiManager("Select",num);
	roiManager("Rename", "P"+num);
}

function offsetROI() {
	roiManager("Select",0);
	getSelectionBounds(X1,Y1,trash,trash);
	for (loop=1; loop<21; loop++) { //X positive ROIs//
		selectImage(secondChannel);
		x = X1 + loop;
		makeRectangle(x,Y1,length,length);
		roiManager("Add");
		roiManager("Select", loop);
		roiManager("Rename", "P1x+"+loop);
	}
	for (loop=1; loop<21; loop++) { //X negative ROIs//
		selectImage(secondChannel);
		x = X1 - loop;
		makeRectangle(x,Y1,length,length);
		roiManager("Add");
		ROI = loop + 20;
		roiManager("Select", ROI);
		roiManager("Rename", "P1x-"+loop);
	}
	for (loop=1; loop<21; loop++) { //Y positive ROIs//
		selectImage(secondChannel);
		y = Y1 + loop;
		makeRectangle(X1,y,length,length);
		roiManager("Add");
		ROI = loop + 40;
		roiManager("Select", ROI);
		roiManager("Rename", "P1y+"+loop);
	}
	for (loop=1; loop<21; loop++) { //Y negative ROIs//
		selectImage(secondChannel);
		y = Y1 - loop;
		makeRectangle(X1,y,length,length);
		roiManager("Add");
		ROI = loop + 60;
		roiManager("Select", ROI);
		roiManager("Rename", "P1y-"+loop);
	}
}

function doPearson() {
	XY=0;
	X2=0;
	Y2=0;
	selectImage("A1");
	Stack.getDimensions(width, height, channels, slices, frames);
	run("Z Project...", "start=1 stop=slices projection=[Average Intensity]");
	getRawStatistics(nPixels, mean1, min, max, std, histogram);
	close();
	selectImage("A2");
	run("Z Project...", "start=1 stop=slices projection=[Average Intensity]");
	getRawStatistics(nPixels, mean2, min, max, std, histogram);
	close();
	slices = slices+1;
	for (z=1; z<slices; z++) {
		selectImage("A1");
		setSlice(z);
		selectImage("A2");
		setSlice(z);
		for (x=0; x<width; x++) {
			for (y=0; y<height; y++) {
				selectImage("A1");
				diff1 = getPixel(x,y)-mean1;
				selectImage("A2");
				diff2 = getPixel(x,y)-mean2;
				diff1diff2 = diff1*diff2;
				diff1sq = diff1*diff1;
				diff2sq = diff2*diff2;
				XY = XY + diff1diff2;
				X2 = X2 + diff1sq;
				Y2 = Y2 + diff2sq;
			}
		}
	}
	X2Y2 = X2 * Y2;
	sqrtX2Y2 = sqrt(X2Y2);
	Pearson = XY / sqrtX2Y2;
	print(Pearson);
	run("Collect Garbage");
}

//image selection
waitForUser("Select First Channel","Select the image or image stack to use as the first channel, then press 'OK'.");
firstChannel=getImageID();
getDimensions(width, height, channels, slices, frames);
waitForUser("Select Second Channel","Select the image or image stack to use as the second channel, then press 'OK'.");
secondChannel=getImageID();


//ROI locations and size based on image size
if (width==512) {
	length = 100; //determines the dimension of ROIS; set for ~20 microns
	arrayX = newArray(50,350,200,50,350); //each coordinate (Cx) is used to define ROI locations
	arrayY = newArray(50,50,200,350,350); //coordinates are based on 512 x 512 images
}
if (width==1024) {
	length = 200; //determines the dimension of ROIS; set for ~20 microns
	arrayX = newArray(100,700,400,100,700); //each coordinate (Cx) is used to define ROI locations
	arrayY = newArray(100,100,400,700,700); //coordinates are based on 1024 x 1024 images
}
nAreas = arrayX.length;


setBatchMode(true);

//CALCULATE CORRELATION WITH OFFSET
for (globalLoop=0; globalLoop<nAreas; globalLoop++) {
	closeROI();
	makeROI(globalLoop,0);
	offsetROI();
	selectImage(firstChannel);
	roiManager("Select", 0);
	run("Duplicate...", "title=A1 duplicate range=1-slices");
	selectImage(secondChannel);
	roiManager("Select", 0);
	run("Duplicate...", "title=A2 duplicate range=1-slices");
	doPearson();
	//run("Colocalization Threshold", "channel_1=A1 channel_2=A2 use=None channel=[Red : Green] set pearson's");
	selectImage("A2");
	close();
	for (coloop=1; coloop<81; coloop++) {
		selectImage(secondChannel);
		roiManager("Select", 1);
		run("Duplicate...", "title=A2 duplicate range=1-slices");
		doPearson();
		//run("Colocalization Threshold", "channel_1=A1 channel_2=A2 use=None channel=[Red : Green] set pearson's");
		selectImage("A2");
		close();
		roiManager("Select", 1);
		roiManager("Delete");
	}
	selectImage("A1");
	close();
	closeROI();
	run("Collect Garbage");
}

//CALCULATE BACKGROUND
for (background=0; background<nAreas; background++) { //generates ROIs.
	makeROI(background,background);
}

for (primaryLoop=0; primaryLoop<nAreas; primaryLoop++) { //colocalization analysis.
	selectImage(firstChannel);
	roiManager("Select", primaryLoop);
	run("Duplicate...", "title=A1 duplicate range=1-slices");
	for (secondaryLoop=0; secondaryLoop<nAreas; secondaryLoop++) {
		if (secondaryLoop == primaryLoop) {
		} else {
			selectImage(secondChannel);
			roiManager("Select", secondaryLoop);
			run("Duplicate...", "title=A2 duplicate range=1-slices");
			doPearson();
			selectImage("A2");
			close();
		}
	}
	selectImage("A1");
	close();
}
run("Collect Garbage");
closeROI();
setBatchMode(false);