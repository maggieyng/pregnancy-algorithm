#' Check whether two pregnancy endpoints meet the required spacing
meets_spacing_rule <- function(date1, outcome1, date2, outcome2, rules) {
  if (date1 <= date2) {
    preceding_value <- outcome1
    following_value <- outcome2
    observed_gap <- as.integer(date2 - date1)
  } else {
    preceding_value <- outcome2
    following_value <- outcome1
    observed_gap <- as.integer(date1 - date2)
  }
  
  required_gap <- rules |>
    dplyr::filter(
      .data$preceding == .env$preceding_value,
      .data$following == .env$following_value
    ) |>
    dplyr::pull("gap_days")
  
  if (length(required_gap) != 1L) {
    stop(
      "Expected one spacing rule for `",
      preceding_value,
      "` followed by `",
      following_value,
      "`, but found ",
      length(required_gap),
      "."
    )
  }
  
  observed_gap >= required_gap
}
#' Place one patient's candidate endpoints on a plausible timeline
place_events_one_patient <- function(
    events,
    hierarchy,
    spacing_rules
) {
  placed <- events[0, , drop = FALSE]
  
  for (current_outcome in hierarchy) {
    candidates <- events |>
      dplyr::filter(.data$outcome == current_outcome) |>
      dplyr::arrange(.data$outcome_date)
    
    if (nrow(candidates) == 0L) next
    
    for (i in seq_len(nrow(candidates))) {
      if (nrow(placed) == 0L) {
        placed <- dplyr::bind_rows(placed, candidates[i, ])
        next
      }
      
      spacing_ok <- vapply(
        seq_len(nrow(placed)),
        function(j) {
          meets_spacing_rule(
            candidates$outcome_date[i],
            candidates$outcome[i],
            placed$outcome_date[j],
            placed$outcome[j],
            spacing_rules
          )
        },
        logical(1)
      )
      
      if (all(spacing_ok)) {
        placed <- dplyr::bind_rows(placed, candidates[i, ])
      }
    }
  }
  
  placed |>
    dplyr::arrange(.data$outcome_date)
}

#' Construct plausible pregnancy endpoint timelines
place_endpoint_events <- function(
    candidates,
    hierarchy = endpoint_hierarchy,
    rules = spacing_rules
) {
  candidates |>
    dplyr::group_by(.data$patient_id) |>
    dplyr::group_modify(
      ~ place_events_one_patient(.x, hierarchy, rules)
    ) |>
    dplyr::ungroup() |>
    dplyr::arrange(.data$patient_id, .data$outcome_date)
}