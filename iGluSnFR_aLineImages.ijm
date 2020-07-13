//This macro is designed to align images within a stack that drift linearly across time.

//Made by Jason Pitt, PhD. Version 1.0, February 22, 2014. Distribute freely.

function aLineImage(image, slices) {
	getLine(x1,y1,x2,y2,lineWidth);
	filename = getInfo("image.filename");
	newImage(filename+"_aligned.tif", "16-bit Black", width, height, slices);
	image2 = getImageID();
	xdiff = (x1-x2)/slices;
	ydiff = (y1-y2)/slices;
	nslices = slices+1;
	for (z=1; z<nslices; z++) {
		selectImage(image);
		setSlice(z);
		run("Copy");
		selectImage(image2);
		setSlice(z);
		xoff = xdiff*z;
		yoff = ydiff*z;
		makeRectangle(xoff,yoff,width,height);
		run("Paste");
	}
	
}

//waitForUser("Select Image","Select the image or image stack to align, then press 'OK'.");
Stack.getDimensions(width, height, channels, slices, frames);
getPixelSize(unit, pixelWidth, pixelHeight);
//waitForUser("Draw a Line","Draw a line that starts at point X in the first slice and ends at point X in the last slice., then press 'OK'.");

image=getImageID();
setBatchMode(true);
aLineImage(image,slices);
setBatchMode(false);
pix = pixelWidth*10000;
run("Set Scale...", "distance=1 known=" + pix + " pixel=1 unit=um");