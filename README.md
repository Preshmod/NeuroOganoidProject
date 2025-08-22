# NeuroOganoidProject


### Overview
This project focuses on the development and evaluation of machine learning models to classify nuclei in brain organoid images into three biologically relevant categories: dividing, interphase, and miscellaneous. Using morphological features extracted from DAPI-stained images, four classification models—Random Forest, Logistic Regression, k-Nearest Neighbours (KNN), and Convolutional Neural Network (CNN)—were trained and compared in terms of accuracy, precision, recall, and F1-score.

The motivation for this study stems from the need to characterise mitotic activity better within organoids, as abnormal cell proliferation is often implicated in the early development of neurodevelopmental disorders. By focusing on early-stage brain development, the project aims to contribute to the understanding of cellular organisation and mitotic regulation in organoid models, with potential implications for disease diagnosis and drug discovery.
This work further addresses key methodological challenges, such as feature selection, dataset imbalance, and model interpretability. Through a robust and reproducible pipeline, the project demonstrates how integrating classical machine learning with deep learning techniques can enhance the scalability and biological relevance of image-based analyses in organoid research.



### Clone the project
```bash
 git clone https://github.com/Preshmod/NeuroOganoidProject/tree/mainAnalysis
```
 
### Running the Pipeline
The main script to execute the entire pipeline is mainAnalysis.m. Ensure that your directory structure and input files are organised as follows within the cloned GitHub folder named NeuroOrganoidProject:


### Input Files and Directory Structure
- **`Image Analysis/`**: Contains all organoid and nuclei images to be analysed (both raw images and masks).
- **`Organoid_masks/`**: Contains the corresponding organoid masks for the organoid images.
- **`Nuclei_masks/`**: Contains the corresponding masks for nuclei within the organoids.
- **`trainedRandomForestModel.mat`**: The pre-trained model used to classify mitotic nuclei, interphase, and miscellaneous.
- **`trainedKNNModel.mat`**: The pre-trained model used to classify mitotic nuclei, interphase, and miscellaneous.
- **`trainedLogisticRegressionModel.mat`**: The pre-trained model used to classify mitotic nuclei, interphase, and miscellaneous.
- **`trainedNetwork.mat`**: The pre-trained model used to classify mitotic nuclei, interphase, and miscellaneous.


## Pipeline Workflow
The analysis follows a step-by-step coding pipeline:

### 1. removeBorder
- Cleans raw images by removing boundary artefacts to ensure accurate segmentation.

### 2. dataRetrieval
- Retrieves image and mask data from /Image_Analysis/.
- Ensures correct mapping between raw images and their corresponding segmentation masks.

### 3. dataCombining
- Merges extracted features (e.g., intensity, nuclear area, solidity etc) into a unified dataset.
- Saves results in /Regionprops_results/.

### 4. nucleiClasses
- Labels nuclei into predefined classes (e.g., mitotic, interphase, miscellaneous).
- Generates the structured dataset saved in /Training_Dataset/.

### 5. Training models
- Uses the processed dataset to train classification models (e.g., Logistic Regression, Random Forest, KNN, CNN).
- Outputs evaluation metrics (accuracy, precision, recall, F1-score) and visualisations (confusion matrix, ROC curves).

### Output Files and Directory Structure
- **`Regionprops_results`**: Morphological feature sets extracted from masks (e.g., area, eccentricity, mean intensity).
- **`Training_Dataset`**: Final merged dataset with labelled nuclei classes.
- **`Model Results`**: Confusion matrices, classification reports, ROC curve.


## Training Your Own Model
If you wish to train your own model to classify mitotic nuclei and non-mitotic nuclei, follow these steps:

- Ensure you have the `images/` and `nuclei_masks/` directories set up with your organoid images and corresponding nuclei masks. 

1. **Nuclei Extraction**: 
   - Run the `nucleiExtraction.m` script.
   - The script will display images with pop-up prompts, asking you to select mitotic nuclei, interphase, and miscellaneous.
   - Selected nuclei will be saved to a directory named `Training_dataset`, organised into subdirectories: `mitotic_nuclei`, `interphase_nuclei`, and `miscellaneous`.

2. **Model Training**:
   - Run the `RandomForestModel.m` script to train the Random Forest model using the images saved during the nuclei extraction process.
   - The trained model will be saved as `trainedRandomForestModel.mat`.
   - Run the `LogisticRegressionModel.m` script to train the Logistic Regression model using the images saved during the nuclei extraction process.
   - The trained model will be saved as `trainedLogisticRegression.mat`.
   - Run the `KNNModel.m` script to train the K-Nearest Neighbour model using the images saved during the nuclei extraction process.
   - The trained model will be saved as `trainedKNNModel.mat`.
   - Run the `CNNModel.m` script to train the Convolutional neural network model using the images saved during the nuclei extraction process.
   - The trained model will be saved as `trainedNetwork.mat`.




## Reproducibility Notes
- Ensure consistent image resolution and scaling before segmentation.
- Masks must align with raw images (nuclei and organoid masks generated from the same field).
  
