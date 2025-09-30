# Momentum and real space data analysis

> [!WARNING]
> Script still at development/testing stage. Keep in mind that code is not thoroughly tested yet and error handling will be added. Therefore all comments, suggestions and bug reports are welcome.

MATLAB® live script for basic analysis of dispersion (k-space) and real-space energy profile (r-space) data in .spe files. Created for the usage of the Quantum Fluids in Photonic Devices research group of Wrocław University of Science and Technology. Mainly for analyzing exciton-polariton dispersion.

## Instalation

1. Download repository and unpack compressed folder.
2. Open **`Momentum_and_real_space_data_analysis.mlx`** in MATLAB®.
3. Go to HOME, then Set Path. Click Add Folder with Subfolders and add folder that you unpacked.
4. Add necessery add-ons listed below.
5. Script should be ready to run.

### Necessary MATLAB® Add-Ons

- Image Processing Toolbox by MathWorks
- Curve Fitting Toolbox by MathWorks
- Signal Processing Toolbox by MathWorks
- cmocean perceptually-uniform colormaps by Chad Greene

## Usage

Script can be used for:
- Reading data in .spe files and correction it by taking into account background data, used ND filters and measurement conditions
- Transforming data from pixel domain to wavevector/position domain
- Plotting data and saving plotted figures
- Extracting points of high intensity for futher analysis in another softwear such as OriginPro®

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
- The MATLAB® function **`loadSPE.m`** authored by **Zhaorong Wang (2016)**, distributed under the BSD 2-Clause License.  
  It has been used in this repository.

## Acknowledgments

- Special thanks to members of the Quantum Fluids in Photonic Devices research group at WUST for parts of their code, helpful suggestions and comments, and substantive support!

