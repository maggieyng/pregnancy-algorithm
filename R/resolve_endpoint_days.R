#' Resolve pregnancy endpoints recorded on the same day
#'
#' A specific endpoint takes precedence over an unspecified delivery.
#' Patient-days containing multiple specific outcomes are excluded.
#'
#' @param events A data frame containing patient_id, service_date, and outcome.
#' @return A tibble with one resolved outcome per patient-day.

resolve_endpoint_days <- function(events) {
  day_summary <- events |>
    dplyr::distinct(.data$patient_id, .data$service_date, .data$outcome) |>
    dplyr::group_by(.data$patient_id, .data$service_date) |>
    dplyr::summarise(
      specific_outcomes = list(unique(.data$outcome[.data$outcome != "delivery"])),
      n_specific = lengths(.data$specific_outcomes),
      .groups = "drop"
    )
  
  day_summary |>
    dplyr::filter(.data$n_specific <= 1L) |>
    dplyr::mutate(
      outcome = vapply(
        .data$specific_outcomes,
        function(x) if (length(x) == 1L) x else "delivery",
        character(1)
      )
    ) |>
    dplyr::select("patient_id", "service_date", "outcome")
}