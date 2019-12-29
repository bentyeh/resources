# Mass Spectrometry

Abbreviations
- MSI: mass spectrometry imaging

## Software

http://ms-utils.org/

Spectra viewers
- [mMass](http://www.mmass.org/)
  - No longer supported, but still powerful and easy to use.

Software packages and toolkits
- [proteowizard](http://proteowizard.sourceforge.net/index.html)

MSI visualization
- [Biomap](https://ms-imaging.org/wp/biomap/)
  - IDL package
- [Datacube Explorer](https://amolf.nl/download/datacubeexplorer)
- [MSiReader](https://msireader.wordpress.ncsu.edu)
  - MATLAB package

R packages
- Cardinal
- MALDIquant
  - estimateBaseline: background signal intensity
  - estimateNoise: variation in background signal intensity (deviance from median)
- mzR

Resources
- [UCSD Center for Computational Mass Spectrometry](http://proteomics.ucsd.edu/)
  - [Global Natural Products Social Molecular Networking (GNPS)](https://ccms-ucsd.github.io/GNPSDocumentation/): a web-based mass spectrometry ecosystem that aims to be an open-access knowledge base for community-wide organization and sharing of raw, processed or identified tandem mass (MS/MS) spectrometry data
- [MS Imaging](https://ms-imaging.org/wp/): a site dedicated to sharing knowledge on mass spectrometry imaging

## File formats

| Format              | Extension(s)   | Data type          | Notes
| ------------------- | -------------- | ------------------ | ----------
| Analyze 7.5         | `.img`, `.hdr` | MSI voxels         | [Specification](https://rportal.mayo.edu/bir/ANALYZE75.pdf), [MATLAB](https://www.mathworks.com/help/images/working-with-mayo-analyze-7-5-files.html)
| ABI/Sciex 4700/4800 | `.t2d`         | mass spectrum      | The only converter I found that does not require the original libraries that come with the ABI/Sciex Data Explorer software is [t2d2mzxml](http://www.pepchem.org/download/converter.html). [MSight](https://web.expasy.org/MSight/) appears to be able to open  `.t2d` files, but it cannot convert them to mzML or mzXML files.

References
- [Wikipedia: Mass spectrometry data format](https://en.wikipedia.org/wiki/Mass_spectrometry_data_format)
- Deutsch, Eric W. "File formats commonly used in mass spectrometry proteomics." *Molecular & Cellular Proteomics* 11.12 (2012): 1612-1621. doi: https://dx.doi.org/10.1074%2Fmcp.R112.019695

## Databases

[Scripps METLIN](https://metlin.scripps.edu/)
- Can restrict to known biological metabolites (i.e., annotated in the KEGG database)
- Automatically searches common adducts

[Spectral Database for Organic Compounds (SDBS)](https://sdbs.db.aist.go.jp/sdbs/cgi-bin/direct_frame_top.cgi)
- National Institute of Advanced Industrial Science and Technology (AIST), Japan

[MassBank](http://www.massbank.jp/Search)
- Mass Spectrometry Society of Japan

[Mass Bank of North America (MoNA)](http://mona.fiehnlab.ucdavis.edu/)
- Common MS adducts: https://fiehnlab.ucdavis.edu/staff/kind/Metabolomics/MS-Adduct-Calculator/

[Human Metabolome Database](http://hmdb.ca)
- MS/MS spectra matching
  - Scoring
    - Fit: "degree of inclusion of a database spectrum in the target spectrum" (think: # shared peaks / # peaks in the database spectrum)
    - Reverse Fit (RFit): "degree of inclusion of the target spectrum in a database spectrum" (think: # shared peaks / # peaks in the target spectrum)
    - Purity: combined measure (think: # shared peaks / # of unique peaks across database and target spectra)
    - Source: Bouchonnet, Stéphane. *Introduction to GC-MS coupling.* CRC Press, 2013. [Google Books](https://books.google.com/books?id=QU48NWHfiAAC&pg=PA145)

## Software notes

### Cardinal

Methods for downsampling data
- `peakBin`
- `reduceDimension`
  - Explored in the legacy Cardinal guide rather than the Cardinal 2 User Guide.
  - `method="bin"`: mean of `width` m/z values
  - `method="resample"`: linear interpolation
  - Source code: https://github.com/kuwisdelu/Cardinal/blob/master/R/process-reduceDimension.R
- `peakAlign`