#Copyright © 2016 RTE Réseau de transport d’électricité

#' Import clusters description
#'
#' @description 
#' This function reads in the input files of an antares study the
#' characteristics of each cluster. 
#' 
#' Be aware that clusters descriptions are read
#' in the input files so they may have changed since a simulation has been run.
#'
#' @inheritParams readAntares
#'
#' @return
#' A data.table with one line per cluster. The columns of the data.table may
#' change between different projects, but there will always be the following 
#' columns:
#' 
#' \item{area}{Name of the area containing the cluster}
#' \item{cluster}{Name of the cluster}
#' \item{group}{Type of cluster (gaz, nuclear, etc.)}
#' \item{unitcount}{number of production units}
#' \item{nominalcapacity}{production capacity of each unit}
#' 
#' The other present columns depends on the version of antares and the options
#' that have been set: if an option is unset for all clusters, it will not 
#' appear in the table.
#' 
#' By default, the function reads the cluster description of the default antares
#' study. You can use the argument \code{opts} to specify another study.
#' 
#' \code{readClusterDesc} : read thermal clusters
#' 
#' \code{readClusterResDesc} : read renewable clusters (Antares >= V8.1)
#' 
#' \code{readClusterSTDesc} : read st-storage clusters (Antares >= V8.6)
#'
#' @examples
#' 
#' \dontrun{
#' 
#' # thermal
#' readClusterDesc()
#' 
#' # renewable
#' readClusterResDesc()
#' 
#' # st-storage
#' readClusterSTDesc()
#' 
#' # By default, the function reads cluster descriptions for the default study,
#' # but it is possible to specify another study with parameter "opts"
#' sim1 <- setSimulationPath()
#' 
#' #[... code that modifies the default antares study]
#' 
#' readClusterDesc(sim1)
#' 
#' }
#' 
#' @export
#' 
#' @rdname readClusterDesc
readClusterDesc <- function(opts = simOptions()) {
  .readClusterDesc(opts = opts, dir = "thermal/clusters")
}

#' @export
#'
#' @rdname readClusterDesc
readClusterResDesc <- function(opts = simOptions()) {
  if((!is.null(opts$parameters$`other preferences`$`renewable-generation-modelling`) &&
      !opts$parameters$`other preferences`$`renewable-generation-modelling` %in% "clusters") || 
     is.null(opts$parameters$`other preferences`$`renewable-generation-modelling`)){
    stop("readClusterDesc is available only on studies with 'renewable-generation-modelling' = 'clusters' (and Antares >= 8.1)", call. = FALSE)
  }
  .readClusterDesc(opts = simOptions(), dir = "renewables/clusters")
}


#' @export
#'
#' @rdname readClusterDesc
readClusterSTDesc <- function(opts = simOptions()) {
  if (opts$antaresVersion < 860) {
    stop("readClusterSTDesc is available only on Antares >= 8.6)", call. = FALSE)
  }
  .readClusterDesc(opts = simOptions(), dir = "st-storage/clusters")
}


  
.readClusterDesc <- function(opts = simOptions(), 
                             dir = "thermal/clusters") {
  
  if(isH5Opts(opts)){
    if(dir %in% "thermal/clusters"){
      if(.requireRhdf5_Antares(stopP = FALSE)){
        return(h5ReadClusterDesc(opts))
      } else {
        stop(rhdf5_message, call. = FALSE)
      }
    } else {
      stop("Read cluster Description from '", dir, "' not available using .h5", call. = FALSE)
    }
  }
  
  path <- file.path(opts$inputPath, dir)
  
  if(opts$typeLoad == 'api'){
    jsoncld <- read_secure_json(paste0(path, "&depth=4"), token = opts$token, timeout = opts$timeout, config = opts$httr_config)
    res <-  rbindlist(mapply(function(X1, Y1){
      clusters <- rbindlist(
        mapply(function(X, Y){
          out <- as.data.frame(X)
          if(nrow(out) == 0)return(NULL)
          out$area = Y
          out
        }, X1$list, names(X1$list), SIMPLIFY = FALSE), fill = TRUE)
      if(is.null(clusters))return(NULL)
      if(nrow(clusters)==0)return(NULL)
      clusters$area <- Y1
      clusters[, .SD, .SDcols = order(names(clusters))]
    },jsoncld, names(jsoncld), SIMPLIFY = FALSE), fill = TRUE)
    
    if(length(res) == 0) 
      stop("Cannot find cluster description.", call. = FALSE)
    
    res <-  res[, .SD, .SDcols = c("area", "name", "group", names(res)[!names(res) %in%c("area", "name", "group")])]
    
  }else{
    
    areas <- list.files(path)
    
    res <- ldply(areas, function(x) {
      clusters <- readIniFile(file.path(path, x, "list.ini"))
      
      if (length(clusters) == 0) return(NULL)
      
      clusters <- ldply(clusters, as.data.frame)
      clusters$.id <- NULL
      clusters$area <- x
      
      clusters[, c(ncol(clusters), 1:(ncol(clusters) - 1))]
    })
    
  }
  
  if(length(res) == 0) stop("Cannot find cluster description.", call. = FALSE)
  
  res <- as.data.table(res)
  setnames(res, "name", "cluster")
  
  res$cluster <- as.factor(tolower(res$cluster))
  
  res
}
