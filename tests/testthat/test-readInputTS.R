#Copyright © 2016 RTE Réseau de transport d’électricité


# >= v710----
context("Function readInputTS")
sapply(studyPathS, function(studyPath){
  
opts <- setSimulationPath(studyPath)

test_that("Load importation works", {
  input <- readInputTS(load = "all", showProgress = FALSE)
  expect_is(input, "antaresDataTable")
  expect_gt(nrow(input), 0)
  expect_equal(nrow(input) %% (24 * 7 * nweeks), 0)
})

test_that("Thermal availabilities importation works", {
  input <- readInputTS(thermalAvailabilities = "all", showProgress = FALSE)
  expect_is(input, "antaresDataTable")
  expect_gt(nrow(input), 0)
  expect_equal(nrow(input) %% (24 * 7 * nweeks), 0)
})

test_that("Run of river importation works", {
  input <- readInputTS(ror = "all", showProgress = FALSE)
  expect_is(input, "antaresDataTable")
  expect_gt(nrow(input), 0)
  expect_equal(nrow(input) %% (24 * 7 * nweeks), 0)
})

test_that("Hydro storage importation works", {
  input <- readInputTS(hydroStorage = "all", showProgress = FALSE)
  expect_is(input, "antaresDataTable")
  expect_gt(nrow(input), 0)
  expect_equal(nrow(input) %% (24 * 7 * nweeks), 0)
})

test_that("Hydro storage maximum power importation works", {
  input <- readInputTS(hydroStorageMaxPower = "all", showProgress = FALSE)
  expect_is(input, "antaresDataTable")
  expect_gt(nrow(input), 0)
  expect_equal(nrow(input) %% (24 * 7 * nweeks), 0)
})

test_that("Wind importation works", {
  input <- readInputTS(wind = "all", showProgress = FALSE)
  expect_is(input, "antaresDataTable")
  expect_gt(nrow(input), 0)
  expect_equal(nrow(input) %% (24 * 7 * nweeks), 0)
})

test_that("Solar importation works", {
  input <- readInputTS(solar = "all", showProgress = FALSE)
  expect_is(input, "antaresDataTable")
  expect_gt(nrow(input), 0)
  expect_equal(nrow(input) %% (24 * 7 * nweeks), 0)
})

test_that("Misc importation works", {
  input <- readInputTS(misc = "all", showProgress = FALSE)
  expect_is(input, "antaresDataTable")
  expect_gt(nrow(input), 0)
  expect_equal(nrow(input) %% (24 * 7 * nweeks), 0)
})

test_that("Reserve importation works", {
  input <- readInputTS(reserve = "all", showProgress = FALSE)
  expect_is(input, "antaresDataTable")
  expect_gt(nrow(input), 0)
  expect_equal(nrow(input) %% (24 * 7 * nweeks), 0)
})

test_that("Link capacity importation works", {
  input <- readInputTS(linkCapacity = "all", showProgress = FALSE)
  expect_is(input, "antaresDataTable")
  expect_gt(nrow(input), 0)
  expect_equal(nrow(input) %% (24 * 7 * nweeks), 0)
})

test_that("readInputTs must work if we change opts$timeIdMin and opts$timeIdMax", {
  input <- readInputTS(ror = "all", 
                       showProgress = FALSE, 
                       timeStep = "hourly",
                       opts = opts)
  expect_is(input, "antaresDataTable")
  
  sumRorA <- input[ , .(sumProdRor = sum(ror)), by= .(area, tsId)]
  sumRorA[, ror := sumProdRor]
  sumRorA <- sumRorA[, ror, by= .(area, tsId)]
  
  inputA <- suppressWarnings(readInputTS(ror = "all", 
                       showProgress = FALSE, 
                       timeStep = "annual",
                       opts = opts))
  
  inputA[, .(ror) , by= .(area, tsId)]
  
  expect_equal(sumRorA, inputA[, .(ror) , by= .(area, tsId)])

  optsNew <- opts
  optsNew$timeIdMin <- 3500
  optsNew$timeIdMax <- 4000
  
  inputAN <- suppressWarnings(readInputTS(ror = "all",
                        showProgress = FALSE,
                        timeStep = "annual",
                        opts = optsNew))
  
  inputH <- readInputTS(ror = "all", 
                       showProgress = FALSE, 
                       timeStep = "hourly",
                       opts = optsNew)
  
  sumRorANew <- inputH[ , .(sumProdRor = sum(ror)), by= .(area, tsId)]
  sumRorANew[, ror := sumProdRor]
  sumRorANew <- sumRorANew[, ror, by= .(area, tsId)]
  
  expect_equal(inputAN[, .( ror) , by= .(area, tsId)], sumRorANew)
  
})

})

# read latest version study
path_study_test <- grep(pattern = "test_case_study_v870", x = studyPathSV8, value = TRUE)
opts_study_test <- setSimulationPath(path_study_test, simulation = "input")

# >= v860----

test_that("readInputTs mingen file v860", {
  
  # to read 8760
  opts_study_test$timeIdMax <- 8760
  
  # read mingen file of study 
  mingen_TS <- readInputTS(mingen = "all", opts = opts_study_test, timeStep = "hourly")
  
  # test class object
  testthat::expect_true("data.table" %in% class(mingen_TS))
  testthat::expect_true("antaresDataTable" %in% class(mingen_TS))
  
  
  # select one area 
  area_mingen <- unique(mingen_TS$area)[1]
  
  # dimension of mingen file for this area
  dim_file <- max(mingen_TS[area %in% area_mingen, tsId])
  
  # check dim file
  path_file <- file.path(opts_study_test$inputPath, "hydro", "series", area_mingen, "mingen.txt")
  
  nb_col <- dim(antaresRead:::fread_antares(file = path_file, opts = opts_study_test))[2]
  
  # check similar dim
  testthat::expect_equal(dim_file, nb_col)
  
})

