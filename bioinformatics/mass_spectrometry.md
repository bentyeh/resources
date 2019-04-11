# Mass Spectrometry

Abbreviations
- MSI: mass spectrometry imaging

## Software

http://ms-utils.org/

### File formats

| Format              | Extension(s)   | Data type          | Notes
| ------------------- | -------------- | ------------------ | ----------
| Analyze 7.5         | `.img`, `.hdr` | MSI voxels         | [Specification](https://rportal.mayo.edu/bir/ANALYZE75.pdf), [MATLAB](https://www.mathworks.com/help/images/working-with-mayo-analyze-7-5-files.html)
| ABI/Sciex 4700/4800 | `.t2d`         | mass spectrum      | The only converter I found that does not require the original libraries that come with the ABI/Sciex Data Explorer software is [t2d2mzxml](http://www.pepchem.org/download/converter.html). [MSight](https://web.expasy.org/MSight/) appears to be able to open  `.t2d` files, but it cannot convert them to mzML or mzXML files.

References
- [Wikipedia: Mass spectrometry data format](https://en.wikipedia.org/wiki/Mass_spectrometry_data_format)
- Deutsch, Eric W. "File formats commonly used in mass spectrometry proteomics." *Molecular & Cellular Proteomics* 11.12 (2012): 1612-1621. doi: https://dx.doi.org/10.1074%2Fmcp.R112.019695

Software packages and toolkits
- [proteowizard](http://proteowizard.sourceforge.net/index.html)

MSI visualization
- Biomap
- [Datacube Explorer](https://amolf.nl/download/datacubeexplorer)

Resources
- [UCSD Center for Computational Mass Spectrometry](http://proteomics.ucsd.edu/)
  - [Global Natural Products Social Molecular Networking (GNPS)](https://ccms-ucsd.github.io/GNPSDocumentation/): a web-based mass spectrometry ecosystem that aims to be an open-access knowledge base for community-wide organization and sharing of raw, processed or identified tandem mass (MS/MS) spectrometry data
- [MS Imaging](https://ms-imaging.org/wp/): a site dedicated to sharing knowledge on mass spectrometry imaging