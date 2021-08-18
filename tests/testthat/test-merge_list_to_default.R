test_that("merge list to default", {
  l_expect_result <- list(A = 10L,
                          B = 20L,
                          C = 3L,
                          D = 4L,
                          E = 5L)
  n_count <- length(l_expect_result)
  l_test_base <- list(A = 10L, B = 20L)
  l_test_default <- lapply(1:n_count, function(x) x)
  names(l_test_default) <- LETTERS[1:n_count]
  l_computed_result <- merge_list_to_default(pl_base = l_test_base, pl_default = l_test_default)
  # compare
  expect_equal(l_computed_result, l_expect_result)
})
