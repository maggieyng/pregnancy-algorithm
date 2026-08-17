testthat::test_that("same-day delivery resolves to the specific outcome", {
  events <- tibble::tribble(
    ~patient_id, ~service_date, ~outcome,
    "001", as.Date("2021-01-10"), "delivery",
    "001", as.Date("2021-01-10"), "livebirth"
  )
  
  result <- construct_pregnancy_episodes(events)
  
  testthat::expect_equal(nrow(result), 1L)
  testthat::expect_equal(result$outcome, "livebirth")
  testthat::expect_equal(result$outcome_date, as.Date("2021-01-10"))
})

testthat::test_that("conflicting specific outcomes are excluded", {
  events <- tibble::tribble(
    ~patient_id, ~service_date, ~outcome,
    "001", as.Date("2021-01-10"), "livebirth",
    "001", as.Date("2021-01-10"), "stillbirth"
  )
  
  result <- resolve_endpoint_days(events)
  
  testthat::expect_equal(nrow(result), 0L)
})

testthat::test_that("adjacent endpoint dates form one event", {
  events <- tibble::tribble(
    ~patient_id, ~service_date, ~outcome,
    "001", as.Date("2021-01-10"), "livebirth",
    "001", as.Date("2021-01-11"), "livebirth"
  )
  
  result <- construct_pregnancy_episodes(events)
  
  testthat::expect_equal(nrow(result), 1L)
  testthat::expect_equal(result$outcome_date, as.Date("2021-01-10"))
})

testthat::test_that("implausibly close outcomes are not both retained", {
  events <- tibble::tribble(
    ~patient_id, ~service_date, ~outcome,
    "001", as.Date("2020-03-05"), "ectopic",
    "001", as.Date("2020-03-25"), "induced_abortion"
  )
  
  result <- construct_pregnancy_episodes(events)
  
  testthat::expect_equal(nrow(result), 1L)
  testthat::expect_equal(result$outcome, "ectopic")
})

testthat::test_that("subsequent prenatal windows are truncated", {
  events <- tibble::tribble(
    ~patient_id, ~service_date, ~outcome,
    "001", as.Date("2021-01-01"), "livebirth",
    "001", as.Date("2021-07-10"), "livebirth"
  )
  
  result <- construct_pregnancy_episodes(events)
  
  testthat::expect_equal(nrow(result), 2L)
  testthat::expect_equal(
    result$prenatal_start[2],
    as.Date("2021-01-29")
  )
})