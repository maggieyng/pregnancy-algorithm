# Pregnancy Episode Construction Algorithm

An R implementation adapted from the pregnancy episode construction approach described by Moll et al. (2021).

The algorithm identifies distinct pregnancy episodes from longitudinal pregnancy endpoint records using an outcome hierarchy, minimum spacing requirements, and outcome-specific prenatal windows.

## Overview

The algorithm:

1. Resolves pregnancy endpoints recorded on the same day
2. Groups endpoint records occurring on adjacent dates
3. Assigns outcomes according to a reliability hierarchy
4. Applies minimum allowable intervals between pregnancy outcomes
5. Constructs outcome-specific prenatal windows
6. Adjusts overlapping windows based on the preceding pregnancy outcome
7. Excludes episodes that do not meet minimum duration requirements

## Input

The input must contain:

| Variable | Description |
|---|---|
| `patient_id` | Unique patient identifier |
| `service_date` | Date of the pregnancy endpoint record |
| `outcome` | Standardized pregnancy endpoint category |

Accepted outcomes are:

- `livebirth`
- `stillbirth`
- `delivery`
- `hydatidiform_mole`
- `ectopic`
- `induced_abortion`
- `spontaneous_abortion`

Diagnosis and procedure codes must be mapped to these categories before applying the algorithm.

## Requirements

The algorithm requires:

- R
- `dplyr`
- `tidyr`
- `tibble`

The optional `testthat` package is required only to run the automated tests.

## Usage

```r
invisible(
  lapply(
    list.files("R", pattern = "\\.R$", full.names = TRUE),
    source
  )
)

pregnancy_episodes <- construct_pregnancy_episodes(endpoint_events)
```

See `examples/example_usage.R` for a reproducible example using synthetic data.

## Output

The function returns one row per identified pregnancy episode:

| Variable | Description |
|---|---|
| `patient_id` | Unique patient identifier |
| `outcome` | Assigned pregnancy outcome |
| `outcome_date` | Estimated pregnancy end date |
| `prenatal_start` | Beginning of the estimated prenatal window |
| `prenatal_end` | End of the estimated prenatal window |

## Testing

Run the automated tests from the repository root:

```r
source("tests/testthat.R")
```

## Scope

This repository implements the pregnancy episode construction component of the approach described by Moll et al. It does not reproduce the complete published algorithm for pregnancy outcome classification or gestational-age estimation.

The implementation has not been independently validated and may require adaptation for different databases, coding systems, or study populations.

## Reference

Moll K, Wong HL, Fingar K, et al. Validating claims-based algorithms determining pregnancy outcomes and gestational age using a linked claims-electronic medical record database. *Drug Safety*. 2021;44:1151–1164.

https://doi.org/10.1007/s40264-021-01113-8
