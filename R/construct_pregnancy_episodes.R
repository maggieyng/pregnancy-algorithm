#' Construct pregnancy episodes from standardized endpoint records
#'
#' @param endpoint_events A data frame containing patient_id, service_date,
#'   and outcome.
#' @return A tibble with one row per identified pregnancy episode.
#' @export

construct_pregnancy_episodes <- function(endpoint_events) {
  required_columns <- c("patient_id", "service_date", "outcome")
  missing_columns <- setdiff(required_columns, names(endpoint_events))
  
  if (!is.data.frame(endpoint_events)) {
    stop("`endpoint_events` must be a data frame.")
  }
  
  if (length(missing_columns) > 0L) {
    stop(
      "Missing required columns: ",
      paste(missing_columns, collapse = ", ")
    )
  }
  
  events <- endpoint_events |>
    dplyr::select(dplyr::all_of(required_columns)) |>
    dplyr::mutate(
      patient_id = as.character(.data$patient_id),
      service_date = as.Date(.data$service_date),
      outcome = as.character(.data$outcome)
    )
  
  if (anyNA(events)) {
    stop("Required input columns cannot contain missing values.")
  }
  
  invalid_outcomes <- setdiff(
    unique(events$outcome),
    endpoint_hierarchy
  )
  
  if (length(invalid_outcomes) > 0L) {
    stop(
      "Unrecognized outcomes: ",
      paste(invalid_outcomes, collapse = ", ")
    )
  }
  
  events |>
    resolve_endpoint_days() |>
    create_event_candidates() |>
    place_endpoint_events() |>
    construct_prenatal_windows()
}