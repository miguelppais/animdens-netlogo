# Model Validation & Sensitivity Analysis

> Fill in this document during and after the Data Scientist phase. CoMSES requires evidence of rigorous evaluation before a model can be peer-reviewed.  
> Reference: [CoMSES Guides to Good Practice — ABM Development](https://www.comses.net/resources/guides-to-good-practice/)

---

## 1. Model Identity

| Field | Value |
|---|---|
| **Model name** | |
| **Version** | |
| **NetLogo version** | |
| **Date** | YYYY-MM-DD |
| **Author(s)** | |

---

## 2. Verification

*Verification answers: "Did we build the model right?" — does the code do what the ODD says?*

| Check | Status | Notes |
|---|---|---|
| All ODD submodels implemented | ☐ | |
| Info Tab synchronized with ODD | ☐ | |
| No runtime errors across parameter space | ☐ | |
| Extreme-value tests pass (min/max sliders) | ☐ | |
| Unit-level behavior matches ODD description | ☐ | |

---

## 3. Validation

*Validation answers: "Did we build the right model?" — does model output match real-world patterns?*

### 3.1 Pattern-Oriented Validation (POV)

List empirical patterns the model must reproduce. For each, state what BehaviorSpace experiment tests it.

| Empirical Pattern | Source (citation) | BehaviorSpace Experiment | Result |
|---|---|---|---|
| | | | |

### 3.2 Quantitative Comparison

| Metric | Empirical Value | Model Output (mean ± SD) | Acceptable? |
|---|---|---|---|
| | | | |

### 3.3 Face Validity

Narrative description of whether the model's emergent behavior is qualitatively plausible to domain experts.

> [Write here]

---

## 4. Sensitivity Analysis

*Identifies which parameters drive model outcomes most strongly.*

### 4.1 One-at-a-Time (OAT) Analysis

For each parameter, vary it across its full range while holding others at baseline. Record the effect on the primary output metric.

| Parameter | Baseline | Range tested | Output metric | Effect size | Notes |
|---|---|---|---|---|---|
| | | | | | |

### 4.2 Global Sensitivity Analysis (if applicable)

Method used (e.g., Sobol indices, Morris screening, Latin Hypercube Sampling):

> [Describe method and results, or link to analysis script in `results/`]

---

## 5. Uncertainty Quantification

| Source of uncertainty | How handled | Remaining risk |
|---|---|---|
| Stochasticity (random seed) | Run N replicates per parameter set (N = ?) | |
| Parameter uncertainty | Prior ranges sourced from: | |
| Structural uncertainty | Alternative submodels considered: | |

---

## 6. BehaviorSpace Experiments

List all BehaviorSpace XML experiments, their purpose, and where output files are stored.

| Experiment name | Purpose | Output file(s) in `results/` | Replicates | Status |
|---|---|---|---|---|
| | | | | |

---

## 7. Calibration Record

If parameters were calibrated to empirical data, document the procedure here.

| Parameter | Calibrated value | Calibration method | Empirical target | Source |
|---|---|---|---|---|
| | | | | |

---

## 8. Known Limitations

List any assumptions, simplifications, or unvalidated aspects that future work should address.

1.
2.
3.
