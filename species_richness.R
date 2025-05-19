library(tidyverse)
library(broom)

# ---- Functions ----

species_by_individuals <- function(df){
  result <- df %>%
    mutate(n_species = cumsum(!duplicated(species))) %>%
    mutate(n_inds = row_number())
  return(result)
}


# ---- Load data ----

# Organize data form checklist
df <- read_csv("/Users/gatesdupont/Downloads/S239673953_observations.csv") %>%
  # Select just species and count
  # ... should fix this to combine subspecies
  select(species = Species, count = Count) %>%
  # Expand the data to list out all the individuals of species
  group_by(species, count) %>%
  mutate(data = list(tibble(species = species, id = 1:count))) %>%
  ungroup() %>%
  select(data) %>%
  unnest(cols = data) %>%
  select(-id)


# ---- Permutation-based SAR analysis ----

# This analysis can be used to estimate
# total number of species in a patch,
# based on an eBird checklist.

# Set the number of permutations
n_sims <- 500

# Use the tidyr map framework to carry out
# bootstrap/permutation analysis
# where we scramble the order of appearance
# of species and keep re-fitting the SAR
# to estimate the three parameters, including
# the equilibrium species richness.
estimates_tbl <- tibble(sim = 1:n_sims) %>%
  # Add the checklist data, scrambling order-of-appearance
  mutate(data = map(sim, ~ slice_sample(df, prop = 1, replace = FALSE))) %>%
  # Record the accumulation of species on each permutation 
  mutate(data = map(data, ~ species_by_individuals(.x))) %>%
  # Fit the Weibull-based Species-Area Relationship
  mutate(
    fit = map(data, ~ nls(
      formula = n_species ~ exp(log_c) * (1 - exp(-exp(log_k) * n_inds^exp(log_z))),
      data    = .x,
      start   = list(
        log_c = log(max(.x$n_species)+1),
        log_k = log(0.02),
        log_z = log(0.75)),
      control = nls.control(maxiter = 100, warnOnly = TRUE)))) %>%
  # Organize the estimated parameters and keep the eq species estimate
  mutate(params = map(fit, tidy),
         log_hat_S = map_dbl(params, ~ .x %>% filter(term == "log_c") %>% pull(estimate)),
         hat_S = exp(log_hat_S)) %>%
  select(sim, hat_S)
  

# ---- Plot the results ----

hist(estimates_tbl$hat_S, breaks = 100) # Distirbution of estimates
quantile(estimates_tbl$hat_S, c(0.1, 0.5, 0.9)) # 80% quantile of estimates
quantile(n_distinct(df$species)/estimates_tbl$hat_S, c(0.1, 0.5, 0.9)) # Percent observed

