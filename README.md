# Momentum and real space data analysis

MATLAB® live script for bacis analysis of dispersion (k-space) and real-space energy profile (r-space) data in .spe files. Created for usage of Quantum fluids in photonic devices research group of Wrocław University of Science and Technology.

## Instalation

To be completed.

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

- [ ] R-space and K-space image (openslit) visualization
- [ ] Generating animation of plotted graphs
- [ ] Plotting extracted points onto the figures
- [ ] Plotting fit results from OriginPro® onto the figures
- [ ] Power series analysis

## License

This project is licensed under the terms of the **BSD 3-Clause License**.  
See the [LICENSE](./LICENSE) file for details.

## Third-Party Licenses

This project uses third-party components distributed under other licenses.  
See [LICENSE_THIRD_PARTY](./LICENSE_THIRD_PARTY) for details.

### In particular:
- The MATLAB® function **`loadSPE.m`** authored by **Zhaorong Wang (2016)**, distributed under the BSD 2-Clause License.  
  It has been used in this repository.

