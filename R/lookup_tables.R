# Pregnancy endpoint hierarchy and temporal rules adapted from Moll et al. (2021)
# https://doi.org/10.1007/s40264-021-01113-8

endpoint_hierarchy <- c(
  "livebirth",
  "stillbirth",
  "delivery",
  "hydatidiform_mole",
  "ectopic",
  "induced_abortion",
  "spontaneous_abortion"
)

window_rules <- tibble::tribble(
  ~outcome, ~max_term_days, ~min_term_days,
  "livebirth",             301, 154,
  "stillbirth",            301, 140,
  "delivery",              301, 140,
  "hydatidiform_mole",     112,  42,
  "ectopic",                84,  42,
  "induced_abortion",      168,  42,
  "spontaneous_abortion",  133,  28
)

spacing_rules <- tibble::tribble(
  ~preceding, ~livebirth, ~stillbirth, ~delivery, ~hydatidiform_mole, ~ectopic, ~induced_abortion, ~spontaneous_abortion,
  "livebirth",             182, 168, 168, 70, 70, 70, 56,
  "stillbirth",            182, 168, 168, 70, 70, 70, 56,
  "delivery",              182, 168, 168, 70, 70, 70, 56,
  "hydatidiform_mole",     168, 154, 154, 56, 56, 56, 42,
  "ectopic",               168, 154, 154, 56, 56, 56, 42,
  "induced_abortion",      168, 154, 154, 56, 56, 56, 42,
  "spontaneous_abortion",  168, 154, 154, 56, 56, 56, 42
) |>
  tidyr::pivot_longer(
    -preceding,
    names_to = "following",
    values_to = "gap_days"
  )