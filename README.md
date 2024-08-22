# NeuroOrganoidAnalysis

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
- **`pca_graphs/`**: Contains the results of principal component analysis (PCA) performed on the extracted metrics, visualizing the dimensionality reduction.

## Training Your Own Model

If you wish to train your own model to classify mitotic nuclei, non-mitotic nuclei, and artefacts, follow these steps:

1. **Nuclei Extraction**: 
   - Run the `nucleiExtraction.m` script.
   - The script will display images with pop-up prompts, asking you to manually select mitotic nuclei, non-mitotic nuclei, and artefacts.
   - Selected nuclei will be saved to a directory named `nuclei_training`, organized into subdirectories: `mitotic_nuclei`, `non_mitotic_nuclei`, and `miscellaneous`.

2. **Model Training**:
   - Run the `mitoticTraining.m` script to train the model using the images saved during the nuclei extraction process.
   - The trained model will be saved as `trainedNetwork.mat`.

## Notes

- Matching filenames across the `images/`, `organoid_masks/`, and `nuclei_masks/` directories is crucial for the accurate execution of the pipeline.
