test_that("kapa_search_tool works", {
  skip_if(identical(Sys.getenv("KAPA_API_KEY"), ""))
  skip_if(identical(Sys.getenv("KAPA_PROJECT_ID"), ""))
  tool <- kapa_search_tool()

  expect_s3_class(tool, "ellmer::ToolDef")
  expect_equal(tool@name, "Posit_kapa_search")
  expect_snapshot(tool@description)
})

test_that("kapa_search_tool errors informatively", {
  old_key <- Sys.getenv("KAPA_API_KEY")
  Sys.unsetenv("KAPA_API_KEY")
  if (!identical(old_key, "")) {
    on.exit(Sys.setenv("KAPA_API_KEY" = old_key))
  }
  expect_snapshot(error = TRUE, kapa_search_tool())
})
