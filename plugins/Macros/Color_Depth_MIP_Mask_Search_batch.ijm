#@ String (visibility=MESSAGE, value="<html><div style='text-align: center; font-size: 18pt; font-weight: bold;'>Batch ColorDepth MIP Mask Search (combined LM/EM)</div>", required=false) header

#@ File (label = "Folder of query mask CDM", style = "directory") input
#@ File (label = "Folder of CDM dataset to be searched", style = "directory") CDM_dataset
#@ File (label = "[EM] Folder of CDM gradient files", style = "directory") gradient_dataset 
#@ String (label = "Dataset type", choices = {"EM hemibrain", "EM others", "LM (or EM without gradient search)"}, style = "radioButtonHorizontal") dataset_type
#@ Boolean (label = "[LM] Horizontal CDM", value=false) horizontal
#@ Integer (label = "[LM] Threshold for dataset", style="slider", min=0, max=255, value=30) dataset_threshold
//#@ String (label = "File suffix", value = ".tif") suffix
//#@ String (visibility=MESSAGE, value="Currently supports .tif and .png formats.",required=false) formats
//#@ File (label = "Output directory", style = "directory") output
//#@ String (label = "Result file name", value = "") task_name
#@ File (label = "Path to save the result Log file",style = "save") log_file 
#@ Integer (label = "Max number of the hits", value=100) max_hits
#@ Boolean (label = "Save results as a CDM stack for each mask",value=false) save_CDM
#@ File (label="Folder to save the CDM stack(s)",style = "directory",value="") save_CDM_path
#@ String (label = "[EM] Show special matching", choices = {"Show hits on a same side (Not for commissure)","Show Commissure matching (Bothside commissure)", "None"}, style = "radioButtonHorizontal") showFlip
#@ Integer (label = "Threshold for mask", style="slider", min=0, max=255, value=30) mask_threshold
#@ Boolean (label = "Add mirror search", value=true) add_mirror_search
#@ Integer (label = "[LM] Duplicated line numbers (only for R & VT lines); 0 = no check", style="list", min=0, max=10, value=0) check_duplicate
#@ String (label = "[EM] Negative score region radius (px)", choices={"10","5"},value="5", style="radioButtonHorizontal") negative_score_radius
#@ Double (label = "Positive pixel (PX) % Threshold (LM: 3-10; EM: 0.5-1.5)", value=1.0, stepSize=0.1, style="format:#.0") px_threshold
#@ String (label = "XY shift", choices={"0px","2px","4px"}, style="radioButtonHorizontal") xy_shift
#@ Integer (label = "Z shift (pixel color fluctuation)", min=0, max=20, value=1) z_shift
#@ String (label = "[LM] Scoring method", choices = {"%","absolute value"}, style = "radioButtonHorizontal") score_method
#@ Double (label = "Percentage of CPU thread (%)", value=100) thread_percent


// Main
setBatchMode(true);
print("\\Clear");

//Open Dataset CDM
File.openSequence(CDM_dataset, "virtual");
datasetTitle = "[" + getTitle() +  "  (" + nSlices + ") slices]"

// Build search parameters
n_cores = parseInt(call( "ij.util.ThreadUtil.getNbCpus" ));
thread_count = round(n_cores * (thread_percent/100));
search_parameters = para_builder();

// process folder
processFolder(input);

Search_Results = getInfo("log");
File.saveString(Search_Results, log_file);

Dialog.create("Batch CDM Mask Search");
Dialog.addMessage("Search Complete. Result is saved in " + log_file + ".");
Dialog.show();


// Function to build search parameters
function para_builder(){
	if (startsWith(dataset_type, "LM")) {
		search_parameters = ""+
		"1.threshold=" + mask_threshold + " ";
		if (add_mirror_search==true) {
			search_parameters += "1.add ";
		}
		search_parameters += "" +
		"negative=none "+
		"2.threshold=50 "+
		"data=" + datasetTitle + " "+
		"3.threshold=" + dataset_threshold + " "+
		"positive=" + px_threshold + " "+
		"pix=" + z_shift + " "+
		"max=" + max_hits + " "+
		"duplicated=" + check_duplicate + " "+
		"thread=" + thread_count + " "+
		"xy=[" + xy_shift + "    ] ";
		if (score_method == "%") {
			search_parameters += "" +
			"scoring=% "+
			"clear";
		}
		else {
			search_parameters += "" +
			"scoring=[absolute value] "+
			"clear";
		}
	}
	else{
		search_parameters = "" +
		"1.threshold=" + mask_threshold + " ";
		if (add_mirror_search==true) {
			search_parameters += "1.add ";
		}
		search_parameters += "" +
		"show=[" + showFlip + "] "+
		"negative=none "+
		"2.threshold=50 "+
		"em_color_mip=" + datasetTitle + " ";
		if (dataset_type == "EM hemibrain") {
			search_parameters += "this ";
		}
		search_parameters += "" +
		"negative_0=" + negative_score_radius + " "+
		"positive=" + px_threshold + " "+
		"pix=" + z_shift + " "+
		"gradient=" + gradient_dataset + File.separator + " "+
		"max=" + max_hits + " "+
		"thread=" + thread_count + " "+
		"xy=[" + xy_shift + "    ] "+
		"clear";
	}
	
	print(search_parameters);
	return search_parameters;
} 

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
    list = getFileList(input);
    list = Array.sort(list);
    for (i = 0; i < list.length; i++) {
        if (File.isDirectory(input + File.separator + list[i])) {
            processFolder(input + File.separator + list[i]);
        }
        // Check for both extensions
        if (endsWith(list[i], ".png") || endsWith(list[i], ".tif")) {
            processFile(input, list[i]);
        }
    }
}

// Open mask, do search, print result in Log, close mask
function processFile(input, file) {
    // LM Mask search
    // EM Mask search
    open(input + File.separator + file);
	
	// Run Mask Search
	if (startsWith(dataset_type,"EM")) {
		run("EM MIP Mask Search silentNoHit","mask=[" + file + "  (1) slice] "+ search_parameters);
	}
	else if (horizontal==true){
		run("Color MIP Mask Search","horizontal  mask=[" + file + "  (1) slice] "+ search_parameters);
	}
	else{
		run("Color MIP Mask Search","  mask=[" + file + "  (1) slice] "+ search_parameters);
	}

    stackname = getTitle();
    print(stackname);
    for (i = 1; i <= nSlices; i++) {
        setSlice(i);
        slicename = getInfo("slice.label");
        print(slicename);
    }
    
    if (save_CDM==true) {
    	saveAs("Tiff", save_CDM_path + File.separator + stackname);
    }
    //close MASK and Result
    close(file);
    close("Search_Result"+file);
}