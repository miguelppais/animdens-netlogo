# Data Provenance

This directory holds all empirical and external input data used by the model. Following [CoMSES data management best practices](https://www.comses.net/resources/guides-to-good-practice/) and the [Cornell README metadata guidance](https://data.research.cornell.edu/data-management/sharing/readme/).

## Directory Structure

```
data/
├── raw/          # Original, unmodified source data — treat as read-only
└── processed/    # Cleaned or derived inputs ready for model consumption
```

## Dataset Registry

For each dataset used, fill in one entry below.

---

### Dataset: [NAME]

| Field | Value |
|---|---|
| **File(s)** | `raw/[filename.csv]` |
| **Description** | What the data represents |
| **Source** | Original source (URL, publication, instrument) |
| **Date acquired** | YYYY-MM-DD |
| **License** | e.g., CC-BY 4.0, public domain |
| **DOI / Citation** | Full citation or DOI of the source dataset |
| **Processing steps** | Describe any cleaning or transformation applied to produce `processed/` files; or link to a script in `code/` |
| **Missing values** | How missing or null values are coded (e.g., NA, -9999) |
| **Units** | Units for numeric columns |

---

## FAIR Compliance Notes

- **Findable**: Each dataset must have a DOI or persistent identifier in the registry above.
- **Accessible**: Raw data should be archived in a DOI-issuing repository (e.g., [Zenodo](https://zenodo.org/), [Dryad](https://datadryad.org/)). Large files (>100 MB) should not be committed to git — link to the archive instead.
- **Interoperable**: Prefer open formats (CSV, JSON, GeoJSON, HDF5) over proprietary formats (XLSX, SHP).
- **Reusable**: Include license information and sufficient metadata so others can replicate the data acquisition.
