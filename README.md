# Momentum and real space data analysis

> [!WARNING]
> Script still at development/testing stage.
> Keep in mind that the code is not thoroughly tested yet and error handling will be added. Therefore, all comments,  suggestions, and bug reports are welcome.

MATLAB® live script for basic analysis of dispersion (k-space) and real-space energy profile (r-space) data in .spe files. 
Created for the usage of the Quantum Fluids in Photonic Devices research group of Wrocław University of Science and Technology. 
Mainly for analyzing exciton-polariton dispersion.

## Instalation

> [!NOTE]
> The script was written in MATLAB® R2025a version, so it should be compatible with it and with future versions.

Instalation process:
1. Download the repository and unpack the compressed folder.
2. Open **`Momentum_and_real_space_data_analysis.mlx`** in MATLAB®.
3. Go to 'HOME', then 'Set Path'. Click 'Add Folder with Subfolders' and add the folder that you unpacked.
4. Add necessary add-ons listed below to MATLAB®.
5. The script should be ready to run.

### Necessary MATLAB® Add-Ons

- Image Processing Toolbox by MathWorks
- Curve Fitting Toolbox by MathWorks
- Signal Processing Toolbox by MathWorks
- cmocean perceptually-uniform colormaps by Chad Greene

## Usage

Whole functionality is avaliable from **`Momentum_and_real_space_data_analysis.mlx`** live script. 
There files for analysis can be picked, options set, and actions picked.
Both the main script and all of the functions are discribed in their files.
Functions can be used separately from the script for other scripts of your own.

The live script can be used for:
- Reading data in .spe files and correcting it by taking into account background data, using ND filters, and measurement conditions
- Transforming data from pixel domain to wavevector/position domain
- Plotting data and saving plotted figures
- Extracting points of high intensity for further analysis in another software such as OriginPro®

### File naming standard

> [!IMPORTANT]
> Correct file names are necessary for script to function correctly.

This is how different files should be named, # indicates number:

Files with data for analysis (.spe):
- First 3 characters: "##_" - for numbering
- Somewhere in the name: "kspace" | "k-space" | "k_space" | "rspace" | "r-space" | "r_space" - indicating measured space
- If neutral density filter was used somewhere in the name: "OD#" | "#OD" | "ND#" | "#ND" - optical density value
- All strings should be separated by: "_"
- Example: 05_kspace_2,2mW_l766nm_1200_c810nm_15s_longpass800_FES800_up7,05mm_lr22,7mm_OD4.spe

FIles with background data (.spe):
- First string: "bg" | "bck" | "background" - background file indicator
- Somewhere in the name: "#...#s" | "#...#ms" | "#...#us" | - exposure time
- All strings should be separated by: "_" or "-"
- Time should be written with "," | "p", not "."
- Example: bg_10s.spe

Files with neutral density filter transmission data from [Thorlabs®](https://www.thorlabs.com) (.xlsx):
- Forth character is a single number indicationg optical density value
- Example: NE530B-B.xlsx


### Things to implement

- [ ] R-space and k-space image (openslit) visualization
- [ ] Generating animation of plotted graphs
- [ ] Plotting extracted points onto the figures
- [ ] Plotting dispersion fit results onto the figures
- [ ] Power series analysis

## Authors

- **Piotr Sieradzki** - [Kombuss](https://github.com/Kombuss)

## License

This project is licensed under the terms of the **BSD 3-Clause License**.  
See the [LICENSE](./LICENSE) file for details.

## Third-Party Licenses

This project uses third-party components distributed under other licenses.  
See [LICENSE_THIRD_PARTY](./LICENSE_THIRD_PARTY) for details.

### In particular:
- The MATLAB® function **`loadSPE.m`** authored by **Zhaorong Wang (2016)**, distributed under the BSD 2-Clause License. It has been used in this repository.

## Acknowledgments

- Special thanks to members of the Quantum Fluids in Photonic Devices research group at WUST for parts of their code, helpful suggestions and comments, and substantive support!

