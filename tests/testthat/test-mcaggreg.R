
context("Test mc-all build")

opts <- antaresRead::setSimulationPath(tail(studyPathS, 1))

outh <- readAntares(areas = "all",
                    links = "all", showProgress = FALSE)
outd <- readAntares(areas = "all",
                    links = "all", timeStep = "daily", showProgress = FALSE)
outw <- readAntares(areas = "all",
                    links = "all", timeStep = "weekly", showProgress = FALSE)
outm <- readAntares(areas = "all",
                    links = "all", timeStep = "monthly", showProgress = FALSE)
outa <- readAntares(areas = "all",
                    links = "all", timeStep = "annual", showProgress = FALSE)

aggregateResult_old(opts, timestep = "hourly", writeOutput = TRUE, verbose = 0)

outhafter <- readAntares(areas = "all", links = "all",
                         showProgress = FALSE)
outdafter <- readAntares(areas = "all", links = "all",
                         timeStep = "daily", showProgress = FALSE)
outwafter <- readAntares(areas = "all", links = "all",
                         timeStep = "weekly", showProgress = FALSE)
outmafter <- readAntares(areas = "all", links = "all",
                         timeStep = "monthly", showProgress = FALSE)
outaafter <- readAntares(areas = "all", links = "all",
                         timeStep = "annual", showProgress = FALSE)

.testDT <- function(dt, dt2, seuil){
  max(unlist(lapply(names(dt), function(X){
    if(is.numeric(dt[[X]])){
      max(dt[[X]] - dt2[[X]])
    }
  })), na.rm = T) < seuil
}

all_ts <- list(list(outh, outhafter),
               list(outd, outdafter),
               list(outw, outwafter),
               list(outm, outmafter),
               list(outa, outaafter))

test_that("Aggregation mc-all", {
  lapply(all_ts, function(X){
    
    expect_equal(names(X[[1]]$areas), names(X[[2]]$areas))
    expect_equal(names(X[[1]]$links), names(X[[2]]$links))
    
    expect_true(.testDT(X[[1]]$areas, X[[2]]$areas, 3))
    expect_true(.testDT(X[[1]]$links, X[[2]]$links, 3))
    
  })
})

