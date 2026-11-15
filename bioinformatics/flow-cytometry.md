- [Resources](#resources)
- [Background](#background)
- [Experimental design](#experimental-design)
- [Compensation](#compensation)
- [Data formats](#data-formats)
- [Packages](#packages)
  - [R / Bioconductor](#r--bioconductor)
- [Other tools](#other-tools)


# Resources

Comprehensive references
- Books
  - Shapiro HM. *Practical Flow Cytometry*. 4th ed. Wiley-Liss; 2003. doi:[10.1002/0471722731](https://doi.org/10.1002/0471722731)
    - Known as the "Bible" of flow cytometry [[Leclerc](https://voices.uchicago.edu/ucflow/2021/12/03/practical-flow-cytometry/)]
    - Available from the Internet Archive: https://archive.org/details/PracticalFlowCytometryShapiro
    - The first two editions of the book (1985, 1988) "included more or less complete instructions for building a flow cytometer with performance comparable to that of a then-current commercial instrument." In the 3rd and 4th editions, "the emphasis \[was\] shifted, expanding the explanations of the chemistry, physics, optics, electronics, statistics, computer science, and even a little of the biology that makes flow cytometers work - or not work, and surveying a wide range of applications. The do-it-yourself flow cytometer portion of the book disappeared." \[Preface to the 4th edition\]
  - Hawley TS, Hawley RG, eds. *Flow Cytometry Protocols*. Vol 2779. 5th ed. Springer US; 2024. doi:[10.1007/978-1-0716-3738-8](https://doi.org/10.1007/978-1-0716-3738-8)
    - Written in the *Methods in Molecular Biology* series format
  - Ortolani, Claudio. *Flow Cytometry Today*. Springer Cham; 2022. doi:[10.1007/978-3-031-10836-5](https://doi.org/10.1007/978-3-031-10836-5)
    - Recommended by the UChicago flow cytometry core as a reference for modern flow cytometry technologies [[Leclerc](https://voices.uchicago.edu/ucflow/2023/08/09/online-flow-training-for-beginners/)]
- Guidelines for the use of flow cytometry and cell sorting in immunological studies, published in the European Journal of Immunology
  - First edition (Cossarizza et al., 2017): https://doi.org/10.1002/eji.201646632
  - Second edition (Cossarizza et al., 2019): https://doi.org/10.1002/eji.201970107
  - Third edition (Cossarizza et al., 2021): https://doi.org/10.1002/eji.202170126
    - New: focus on assays for function and phenotypes; enumerate key differences between human vs. murine cell analysis
    - Excludes certain sections covered in the 2nd edition: on principles of flow cytometry and cell sorting; advanced flow cytometry techniques

International Society for Advancement of Cytometry (ISAC): https://isac-net.org/

Make Your Own Flow Cytometer: https://www.cytometryworks.com/

Manufacturer resources
- [Beckman Coulter: Accessible Flow Cytometry Learning Center](https://www.beckman.com/resources/technologies/accessible-flow-cytometry-learning-center)
- [Bio-Rad: Flow Cytometry Explained](https://www.bio-rad-antibodies.com/flow-cytometry-explained.html)
- [BD Biosciences: Flow Cytometry Basics Training](https://www.bdbiosciences.com/en-us/learn/training/basic)
- [Thermo Fisher Scientific: Flow Cytometry Learning Center](https://www.thermofisher.com/us/en/home/life-science/cell-analysis/flow-cytometry/flow-cytometry-learning-center.html)

# Background

Miscellaneous
- > "FACS" (fluorescence activated cell sorting) should only be used for Becton Dickinson (BD) technologies as it is a BD trademark (FACS<sup>TM</sup>); the more general term "flow cytometry cell sorting" should be used to be company agnostic [[Cossarizza et al., 2017](https://doi.org/10.1002/eji.201646632)]
- > CD mAbs and not anti-CD mAbs (in other words CD1 mAb and not anti-CD1 mAb, for example) should be used. This is because the CD nomenclature is primarily a system to cluster/characterize mAbs and it was only later accepted to use this system to also describe the respective CD molecules. [[Cossarizza et al., 2017](https://doi.org/10.1002/eji.201646632)]

# Experimental design

**Isotype controls** are "antibodies raised against an antigen not found on the cell type or sample analyzed." [[Bio-Rad](https://www.bio-rad-antibodies.com/flow-cytometry-guide-isotype-controls.html)]
- Purpose: measure non-specific binding or staining of an antibody
  - This is especially important when analyzing blood cells that express Fc receptors
  - "They should not to [sic] be used to determine positive versus negative cells or to set gates, and may not be suitable for intracellular staining."
- An isotype control ideally matches the host species, Ig subclass, fluorophore, and fluorophore:antibody conjugation ratio of the primary antibody.
- Limitations [[Maecker & Trotter, 2006](https://doi.org/10.1002/cyto.a.20333)]
  - Background staining varies between antibodies even of the same isotype, so an isotype control may not match the test antibody's background.
  - They do not account for spillover from other channels.

**Fluorescence-minus-one (FMO) controls** are stained with every antibody in the panel except one; they serve as the gating control for the missing antibody's channel. [[Roederer, 2001](https://doi.org/10.1002/1097-0320(20011101)45:3%3C194::AID-CYTO1163%3E3.0.CO;2-C)]
- Purpose: measure spillover into that channel. Compensation does not remove the spread that spillover adds, so the negative population can be wider than in an unstained sample. [[Roederer, 2001](https://doi.org/10.1002/1097-0320(20011101)45:3%3C194::AID-CYTO1163%3E3.0.CO;2-C)]
- Limitation: they do not measure nonspecific binding of the omitted antibody. [[Maecker & Trotter, 2006](https://doi.org/10.1002/cyto.a.20333)]

Choosing gating controls [[Maecker & Trotter, 2006](https://doi.org/10.1002/cyto.a.20333)]
- Only needed for markers without clearly separated positive and negative populations (e.g., CD25, CD69, cytokines).
- FMO controls are generally more relevant in multicolor (>4 colors) experiments, where spillover is the main source of background.
- A biological comparison control (e.g., an unstimulated sample stained with the same antibodies) is usually best when available, since it accounts for both spillover and nonspecific binding.

# Compensation

- https://www.drmr.com/compensation/index.html
- https://www.youtube.com/watch?v=PbJXMBpaoQk
- https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3133696/
- https://www.cytometry.uzh.ch/dam/jcr:8f991d12-ef7c-4827-a312-2d65d89b9099/FCSS%202017%20Compensation%20Fundamental%20Principles.pdf
- https://extranet.fredhutch.org/content/dam/extranet/u/shared-resources/flow-cytometry/FC-Ed-Compensation-and-Spectral-Unmixing-Mathematics.pdf

# Data formats

Flow cytometry file formats and standards are developed and maintained by the ISAC - see https://isac-net.org/page/Data-Standards.

Flow Cytometry Standard (FCS): data file
- Latest version = 3.2 (released 2020)
  - Publication: Spidlen J, Moore W, Brinkman RR; ISAC Data Standards Task Force. ISAC's new FCS 3.2 standard. *Cytometry A*. 2021;99(1):100-102. doi:[10.1002/cyto.a.24225](https://doi.org/10.1002/cyto.a.24225)
- Previous version = 3.1 (ISAC copyright 2008-2009)
  - Publication: Spidlen J, Moore W, Parks D, et al. Data File Standard for Flow Cytometry, version FCS 3.1. *Cytometry A*. 2010;77(1):97-100. doi:[10.1002/cyto.a.20825](https://doi.org/10.1002/cyto.a.20825)
- Format: ASCII HEADER and TEXT (keyword-value metadata) segments, followed by a DATA segment (typically binary)

Gating Markup Language (Gating-ML): encoding of gating, data transformations and compensation
- Latest version = 2.0
  - Publication: Spidlen J, Moore W; ISAC Data Standards Task Force, Brinkman RR. ISAC's Gating-ML 2.0 data exchange standard for gating description. *Cytometry A*. 2015;87(7):683-687. doi:[10.1002/cyto.a.22690](https://doi.org/10.1002/cyto.a.22690)
  - Supports Boolean collections of the following gate types: rectangle (including 1-D range), quadrant, polygon, and ellipsoid gates
- Format: XML

# Packages

| Package | Language | GUI / Interactive | Release Date | Links | Notes |
| ------- | -------- | ----------------- | ------------ | ----- | ----- |
| Cytoverse (flowCore, flowWorkspace, ggcyto, CytoML, openCyto) | R | none | 2007 (flowCore; Bioconductor 2.0) | [Homepage](https://cytoverse.org), [flowCore Paper (2009)](https://doi.org/10.1186/1471-2105-10-106), [openCyto Paper (2014)](https://doi.org/10.1371%2Fjournal.pcbi.1003806), [CytoML Paper (2018)](https://doi.org/10.1002/cyto.a.23663), [ggCyto Paper (2018)](https://doi.org/10.1093/bioinformatics/bty441), [GitHub](https://github.com/RGLab/cytoverse) | |
| FlowCytometryTools | Python | draw gates interactively | [2013 (v0.3.0)](https://github.com/eyurtsev/FlowCytometryTools/blob/70edbd6a7f0d5ae882492d56dd4629c5a49a38fe/README.rst?plain=1#L154) | [Homepage](https://eyurtsev.github.io/FlowCytometryTools/), [GitHub](https://github.com/eyurtsev/FlowCytometryTools) | last release in 2021 |
| Cytoflow | Python | GUI | [2015 (first public release)](https://github.com/cytoflow/cytoflow/releases/tag/0.1.2), 2019 (v1.0) | [Homepage](https://cytoflow.github.io/), [Documentation](https://cytoflow.readthedocs.io), [Preprint (2022)](https://doi.org/10.1101/2022.07.22.501078), [GitHub](https://github.com/cytoflow/cytoflow) | |
| FlowCal | Python | Excel UI | [2015 (first release)](https://github.com/taborlab/FlowCal/releases/tag/v0.5) | [Paper (2016)](https://doi.org/10.1021/acssynbio.5b00284), [GitHub](https://github.com/taborlab/FlowCal) | |
| CytoExploreR | R | draw gates interactively | 2018 (initial commit to GitHub as cytoTools), 2020 (v1.0.0 as CytoExploreR) | [Homepage](https://dillonhammill.github.io/CytoExploreR/index.html), [GitHub](https://github.com/DillonHammill/CytoExploreR) | |
| FlowKit | Python | none | [2019 (first release)](https://github.com/whitews/FlowKit/releases/tag/0.0.9) | [Documentation](https://flowkit.readthedocs.io/en/latest/), [Paper (2021)](https://doi.org/10.3389%2Ffimmu.2021.768541), [GitHub](https://github.com/whitews/FlowKit) | |
| CytoPy | Python | none | [2020 (v1.0.0)](https://github.com/burtonrj/CytoPy/releases/tag/v1.0.0) | [Documentation](https://cytopy.readthedocs.io/), [Paper (2021)](https://doi.org/10.1371/journal.pcbi.1009071), [GitHub](https://github.com/burtonrj/CytoPy) | last release in 2021 |
| EasyFlow | Matlab | GUI | [2020](https://github.com/AntebiLab/easyflow/releases) | [Preprint (2023)](https://doi.org/10.1101/2023.08.07.552387), [Paper (2024)](https://doi.org/10.1371/journal.pone.0308873), [GitHub](https://github.com/AntebiLab/easyflow) | |
| EasyFlowQ | Python | GUI | [2022](https://github.com/ym3141/EasyFlowQ/releases) | [Documentation](https://ym3141.github.io/EasyFlowQ/), [Preprint (2023)](https://doi.org/10.1101/2023.08.07.552387), [Paper (2024)](https://doi.org/10.1371/journal.pone.0308873), [GitHub](https://github.com/ym3141/EasyFlowQ) | written by Yitong Ma, a former Caltech PhD student from the Elowitz lab |
| pytometry | Python | none | [2022](https://github.com/scverse/pytometry/releases) | [Homepage](https://pytometry.netlify.app/), [Preprint (2022)](https://doi.org/10.1101/2022.10.10.511546), [GitHub](https://github.com/scverse/pytometry) | |

Unmaintained: [fcm (Python)](https://github.com/jfrelinger/fcm)

See also Table 1 from the [FlowKit paper (2021)](https://doi.org/10.3389/fimmu.2021.768541) for a features comparison of open source flow cytometry software.

## R / Bioconductor

Cytoverse

Resources
- Bioconductor 2023 conference (BioC2023) workshop: https://cdn.ozetteai.com/cytoverse-bioc-2023/index.html
  - Video tutorial: https://www.youtube.com/watch?v=_8x-prIxJgw

# Other tools

- FlowJo (BD)
- Cytobank (Beckman Coulter)
- Free web-based program: [Floreada.io](https://floreada.io/)