# NeuroOganoidProject

## Overview
This project aims to develop and refine computational methods to accurately quantify the architecture and behaviour of complex 3D tissues, using human brain organoids as a model of developing neuroepithelia. Unlike traditional 2D cultures, these organoids better represent real tissue structures. Using MATLAB and machine learning to study features such as cell and nucleus shapes, division positioning, and tissue patterns. Starting with 2D Z-sections and progressing to 3D reconstructions, the project will compare normal organoids with genetically edited or drug-treated ones to assess the method’s effectiveness in detecting structural and phenotypic changes.

## Key Findings

## Getting Started

### Clone the project
```bash
 git clone https://github.com/Preshmod/NeuroOganoidProject/tree/mainAnalysis
```
 
### Running the Pipeline
The main script to execute the entire pipeline is mainAnalysis.m. Ensure that your directory structure and input files are organised as follows within the cloned GitHub folder named NeuroOrganoidProject:

### Input Files and Directory Structure
- **`Image Analysis/`**: Contains all organoid images to be analysed.
- **`Organoid_masks/`**: Contains the corresponding organoid masks for the organoid images.
- **`Nuclei_masks/`**: Contains the corresponding masks for nuclei within the organoids.

### Output Files and Directory Structure
Upon running the pipeline, the following directories and files will be generated:

## Training Your Own Model
