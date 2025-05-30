# 🎨 Art Genre Classification Using Neural Networks

## Overview

This project explores the classification of paintings into art genres using machine learning, with a focus on visual style. By leveraging pretrained convolutional features and neural network-based classifiers, we aim to assist digital curation and art education through accurate genre predictions.

We compare three model architectures:

* **Simple Neural Network (SNN)**
* **Boosted Neural Network (BNN)** using ensemble learning
* **SNN with Adam Optimizer**

Each model is evaluated in terms of accuracy, training time, and robustness on imbalanced genre data.

## 📁 Dataset

* **Size**: 8,355 paintings
* **Labels**: One-hot encoded genre labels (multi-label classification)
* **Source**: WikiArt dataset (via `artists.csv`)
* **Features**: 1D vectors extracted from images using ResNet50 + PCA

## 🧪 Pipeline

1. **Image Preprocessing**

   * Resize to 224×224
   * Normalize for ResNet50 input

2. **Feature Extraction**

   * Use **pretrained ResNet50** to extract deep features

3. **Dimensionality Reduction**

   * Apply **PCA** to reduce features to 100 components

4. **Model Training**

   * Train three different models using the preprocessed data

## 🧠 Models

### 1. Simple Neural Network (SNN)

* Multi-layer perceptron with two hidden layers
* Forward/backward propagation with ReLU + Sigmoid
* Optimized using **vanilla gradient descent**

### 2. Boosted Neural Network (BNN)

* Ensemble of neural networks trained sequentially
* Residual-based boosting with **gradient clipping** for stability
* Prediction = average output across base learners

### 3. SNN with Adam Optimizer

* Uses Adam's adaptive moment estimation for weight updates
* Faster convergence but slightly lower test accuracy

## 📊 Results

| Model            | Test Accuracy | Training Time |
| ---------------- | ------------- | ------------- |
| SNN              | 71.04%        | 8 sec         |
| Boosted NN (BNN) | 73.43%        | 44 sec        |
| Adam Optimizer   | 66.01%        | 22 sec        |

* **BNN** achieved the best accuracy through ensemble learning.
* **SNN** provided a good trade-off between performance and efficiency.
* **Adam Optimizer** showed rapid convergence but lower generalization.

## 📉 Limitations

* **Dataset Imbalance**: Dominant genres like Impressionism affect minority class performance.
* **Feature Mismatch**: ResNet50 is trained on ImageNet, not stylistic art data, possibly missing nuanced genre signals.

## 🛠️ Future Work

* Fine-tune feature extraction on genre-specific datasets
* Apply data augmentation or class-balancing techniques
* Explore transformer-based or attention-driven models

## 📚 References

* Joshi et al. (2020): *Art style classification with self-trained ensemble* ([arXiv:2012.03377](https://arxiv.org/abs/2012.03377))
* Menis-Mastromichalakis et al. (2024): *Deep ensemble art style recognition* ([arXiv:2405.11675](https://arxiv.org/abs/2405.11675))
* Rambhatla et al. (2021): *To boost or not to boost* ([arXiv:2107.13600](https://arxiv.org/abs/2107.13600))
* Kingma & Ba (2017): *Adam Optimizer* ([arXiv:1412.6980](https://arxiv.org/abs/1412.6980))

## 👨‍💻 Contributors

* Hoon Han (518370990019)
* Joonhyung Lee (519370990008)
* Stephen Yeap Weller (521370990028)
