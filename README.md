# NeuroOrganoidAnalysis

To address the rising prevalence of neurological disorders, gaining a deeper understanding of early brain development is essential for uncovering underlying causes and developing effective treatments. Brain organoids have emerged as an invaluable tool for modeling early human brain development with greater accuracy than traditional methods. To quantify the organoids, a pipeline was developed that integrates traditional descriptors with deep learning techniques to quantify organoid architecture and behavior. This pipeline extracts parameters including: area, eccentricity, circularity, solidity, and mean intensity for both whole organoids and nuclei. It also captures the number of nuclei within each organoid and the distance of nuclei from the organoid's centre. Following data extraction, the pipeline conducts extensive statistical analyses.

Initially, a pairwise correlation analysis is performed to reveal significant relationships among the organoid and nuclei metrics. This is followed by a comparative analysis of these metrics in organoids with and without lumens. Additionally, a principal component analysis (PCA) is utilised to reduce the dimensionality of the metrics. Moreover, the pipeline explores cell proliferation within the organoids by employing a convolutional neural network (CNN) to identify mitotic nuclei, non-mitotic nuclei, and artefacts—hypothesised to be apoptotic cells. These classifications are then used to compare the metrics associated with mitotic and non-mitotic nuclei, as well as the recognised artefacts.

## Getting Started

### Clone the project

```bash
  git clone https://github.com/TomBennett2202/NeuroOrganoidAnalysis/tree/main
```

### Running the Pipeline

The main script to execute the entire pipeline is `main.m`. Ensure that your directory structure and input files are organised as follows within the cloned GitHub folder named `NeuroOrganoidAnalysis`:

### Input Files and Directory Structure

- **`images/`**: Contains all organoid images to be analysed.
- **`organoid_masks/`**: Contains the corresponding organoid masks for the organoid images.
- **`nuclei_masks/`**: Contains the corresponding masks for nuclei within the organoids.
- **`magnifications.csv`**: A CSV file that lists the image filenames along with their corresponding magnification levels.
- **`trainedNetwork.mat`**: The pre-trained model used to classify mitotic nuclei, non-mitotic nuclei, and artefacts.

### Output Files and Directory Structure

Upon running the pipeline, the following directories and files will be generated:

- **`correlated/`**: Contains graphs for significantly correlated (p-value > 0.05) pairwise comparisons among the extracted metrics.
- **`uncorrelated/`**: Contains graphs for uncorrelated (p-value < 0.05) pairwise comparisons.
- **`lumen_graphs/`**: Contains graphs comparing metrics for organoids and nuclei, distinguishing between organoids with and without lumens in the z-slice images.
- **`mitotic_graphs/`**: Contains graphs comparing metrics for nuclei classified as mitotic, non-mitotic, or artefacts. This directory also includes the results, saved as a CSVs, of the ad-hoc tests for each metric comparison.
- **`pca_graphs/`**: Contains the results of principal component analysis (PCA) performed on the extracted metrics, visualising the dimensionality reduction.

## Training Your Own Model

If you wish to train your own model to classify mitotic nuclei, non-mitotic nuclei, and artefacts, follow these steps:

- Ensure you have the `images/` and `nuclei_masks/` directories set up with your organoid images and corresponding nuclei masks. 

1. **Nuclei Extraction**: 
   - Run the `nucleiExtraction.m` script.
   - The script will display images with pop-up prompts, asking you to manually select mitotic nuclei, non-mitotic nuclei, and artefacts.
   - Selected nuclei will be saved to a directory named `nuclei_training`, organised into subdirectories: `mitotic_nuclei`, `non_mitotic_nuclei`, and `miscellaneous`.

2. **Model Training**:
   - Run the `mitoticTraining.m` script to train the model using the images saved during the nuclei extraction process.
   - The trained model will be saved as `trainedNetwork.mat`.

## Notes

- Matching filenames across the `images/`, `organoid_masks/`, and `nuclei_masks/` directories is crucial for the accurate execution of the pipeline.
