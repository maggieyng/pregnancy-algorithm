#' Construct outcome-specific prenatal windows
#'
#' Initial windows are based on the maximum term for each outcome.
#' Overlapping windows are truncated using the minimum interval between
#' the preceding outcome and the beginning of a subsequent pregnancy.
#'
#' @param timeline Plausible pregnancy endpoint timeline.
#' @param rules Outcome-specific pregnancy window rules.
#' @return One row per retained pregnancy episode.

construct_prenatal_windows <- function(
    timeline,
    rules = window_rules
) {
  timeline |>
    dplyr::left_join(rules, by = "outcome") |>
    dplyr::group_by(.data$patient_id) |>
    dplyr::arrange(.data$outcome_date, .by_group = TRUE) |>
    dplyr::mutate(
      prenatal_end = .data$outcome_date,
      prenatal_start = .data$outcome_date - .data$max_term_days,
      minimum_start = dplyr::lag(.data$outcome_date) +
        dplyr::lag(.data$min_gap_to_next_days),
      prenatal_start = dplyr::if_else(
        !is.na(.data$minimum_start) &
          .data$prenatal_start < .data$minimum_start,
        .data$minimum_start,
        .data$prenatal_start
      ),
      estimated_duration_days = as.integer(
        .data$prenatal_end - .data$prenatal_start
      )
    ) |>
    dplyr::filter(
      .data$estimated_duration_days >= .data$min_term_days
    ) |>
    dplyr::ungroup() |>
    dplyr::select(
      "patient_id",
      "outcome",
      "outcome_date",
      "prenatal_start",
      "prenatal_end"
    )
}