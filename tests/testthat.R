# Load algorithm files
invisible(
  lapply(
    list.files("R", pattern = "\\.R$", full.names = TRUE),
    source
  )
)

# Run tests
testthat::test_dir("tests/testthat")