#' Group nearby endpoint records into candidate pregnancy events
#'
#' Endpoint records on the same or consecutive days are treated as one
#' candidate event. The highest-ranked outcome is retained.
#'
#' @param events Resolved patient-day endpoint records.
#' @param hierarchy Character vector ordered from highest to lowest priority.
#' @return A tibble containing candidate pregnancy events.

create_event_candidates <- function(
    events,
    hierarchy = endpoint_hierarchy
) {
  events |>
    dplyr::arrange(.data$patient_id, .data$service_date) |>
    dplyr::group_by(.data$patient_id) |>
    dplyr::mutate(
      gap_days = as.integer(.data$service_date - dplyr::lag(.data$service_date)),
      new_event = is.na(.data$gap_days) | .data$gap_days > 1L,
      event_id = cumsum(.data$new_event)
    ) |>
    dplyr::ungroup() |>
    dplyr::group_by(.data$patient_id, .data$event_id) |>
    dplyr::summarise(
      outcome_date = min(.data$service_date),
      outcome = {
        observed <- unique(.data$outcome)
        hierarchy[hierarchy %in% observed][1]
      },
      .groups = "drop"
    ) |>
    dplyr::select(
      .data$patient_id,
      .data$event_id,
      .data$outcome_date,
      .data$outcome
    )
}