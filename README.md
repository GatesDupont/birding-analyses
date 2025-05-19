# Species Richness Estimation from a Single eBird Checklist

This repository contains an **R script** that uses permutation‐based species‐accumulation curves and a Weibull‐type Species–Area Relationship (SAR) model to estimate the *equilibrium* (true) number of species that likely occur in a patch, given a single eBird checklist.

---

## 1. Overview of the Workflow

1. **Load & tidy the checklist**

   * Reads a CSV exported from eBird (`*_observations.csv`).
   * Keeps only *Species* and *Count*.
   * Expands counts so that each individual bird becomes one row.
2. **Permutation loop (`n_sims`)**

   * Randomly shuffles the order of individuals.
   * Tracks cumulative *unique* species vs individuals.
   * Fits a three‐parameter Weibull SAR via nonlinear least squares (`nls`).
3. **Summarise results**

   * Collects the fitted equilibrium richness ($\hat S$) for every permutation.
   * Provides a histogram and quantiles of $\hat S$.
   * Calculates the proportion of the true assemblage that was *actually* observed in the checklist.

---

## 2. Dependencies

| Package       | Tested version | Purpose                               |
| ------------- | -------------- | ------------------------------------- |
| **tidyverse** | ≥ 2.0.0        | Data wrangling & plotting             |
| **broom**     | ≥ 1.0.5        | Tidy extraction of `nls` coefficients |

> **Installation**
>
> ```r
> install.packages(c("tidyverse", "broom"))
> ```

---

## 3. Input Data

* **File**: A single eBird export such as `S239673953_observations.csv`
* **Required columns** (exact names):

  * `Species` – common or scientific name
  * `Count`   – integer number of individuals

> The script currently assumes no subspecies aggregation; edit the *Load data* block if you wish to combine subspecies/groups.

---

## 4. Quick Start

1. **Clone / download** this repo and open `species_richness.R` in RStudio (or another IDE).
2. **Edit** the *Load data* section:

   ```r
   df <- read_csv("/path/to/your/observations.csv")
   ```
3. (Optional) **Change** the number of permutations:

   ```r
   n_sims <- 1000   # for tighter confidence bands
   ```
4. **Source** the script (`Ctrl + Shift + S` in RStudio) or run it line‑by‑line.
5. Inspect the console and plots pane for:

   * A histogram of $\hat S$ estimates.
   * 10th, 50th, and 90th percentiles of $\hat S$ and of *% observed*.

---

## 5. Output Objects & Files

* **`estimates_tbl`** – `tibble` with columns:

  * `sim` – permutation id
  * `hat_S` – equilibrium richness estimate
* **Histogram** – distribution of $\hat S$ (viewed interactively; save with `ggsave()` if desired).
* **Quantiles** – printed to console.

To persist results:

```r
write_csv(estimates_tbl, "sar_estimates.csv")
```

---

## 6. Customization Tips

* **Model start values** – tweak the `start = list(...)` entries if `nls` fails to converge for your checklist.
* **Alternative SAR forms** – swap in a power or Lomolino model by changing the formula inside `nls()`.
* **Visualisation** – use `ggplot(estimates_tbl, aes(hat_S)) + geom_histogram()` for publication‑quality plots.

---

## 7. References & Further Reading

* Fattorini L. (2010) *A general framework for estimating species richness*. **Ecology**, 91(12):3440–3450.
* Smith AO et al. (2022) *Estimating unseen biodiversity from single‑visit checklists using accumulation curves*. **Methods Ecol Evol**.

---

## 8. License

Apache License 2.0
