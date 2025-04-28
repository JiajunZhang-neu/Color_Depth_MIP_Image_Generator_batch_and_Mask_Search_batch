A wrapper combining [ColorDepth MIP mask Search for LM](https://github.com/JaneliaSciComp/ColorMIP_Mask_Search) and [ColorDepth MIP mask search for EM](https://github.com/JaneliaSciComp/EM_MIP_search). (Color_Depth_MIP_Mask_Search_batch.ijm)  
Search results will be saved as image stacks (each slice is the CDM of one match) and a text file which can be directly read by [MADI](https://github.com/sandorbx/MADI) for 3D visualization.

Modified ColorDepth MIP generator that automatically scales the input image stacks to match the dimension of CDM datasets. (Color_Depth_MIP_Image_Generator_batch.ijm)

**Installation**  
- Download the latest release here
- Unzip the file
- Close FIJI if it is running
- Copy all contents to your FIJI folder (something like "C:\Program Files\Fiji.app\")
- Choose "Replace existing file [OK]" if asked (in Windows this will add new files to the existing folders, behavior may different in other operating system)
- Restart FIJI, the three installed macros should appear in Plugin --> Macros

***Downloading the Color Depth MIPs from [here](https://open.quiltdata.com/b/janelia-flylight-color-depth/tree/Color_Depth_MIPs_For_Download/)


***The unisex brain template for the CDM resolution can be found [here](https://open.quiltdata.com/b/janelia-flylight-color-depth/tree/alignment_templates/JRC2018_UNISEX_20x_HR.nrrd)
