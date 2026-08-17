# Load all algorithm functions and lookup tables
invisible(
  lapply(
    list.files("R", pattern = "\\.R$", full.names = TRUE),
    source
  )
)

# Create synthetic pregnancy endpoint records
endpoint_events <- tibble::tribble(
  ~patient_id, ~service_date, ~outcome,
  
  # Delivery and live birth on the same day resolve to live birth
  "001", "2021-01-10", "delivery",
  "001", "2021-01-10", "livebirth",
  
  # Adjacent live-birth record is grouped with the previous day
  "001", "2021-01-11", "livebirth",
  
  # A later spontaneous abortion is retained as a separate pregnancy
  "001", "2023-04-15", "spontaneous_abortion",
  
  # Conflicting specific outcomes on the same day are excluded
  "002", "2022-06-20", "livebirth",
  "002", "2022-06-20", "stillbirth",
  
  # Standalone delivery with unknown outcome
  "002", "2024-01-12", "delivery",
  
  # The induced abortion occurs too soon after the ectopic pregnancy
  # and is excluded by the spacing rules
  "003", "2020-03-05", "ectopic",
  "003", "2020-03-25", "induced_abortion",
  
  # A later live birth is retained
  "003", "2022-09-12", "livebirth",
  
  # The second live birth is valid, but its initial maximum prenatal
  # window overlaps the minimum post-outcome interval from the first
  "004", "2021-01-01", "livebirth",
  "004", "2021-07-10", "livebirth"
) |>
  dplyr::mutate(service_date = as.Date(.data$service_date))

# Construct pregnancy episodes
pregnancy_episodes <- construct_pregnancy_episodes(
  endpoint_events
)

print(pregnancy_episodes)

source("examples/example_usage.R")
