# ====================================================================== #
# This script contains useful functions I think I may use again sometime
# ====================================================================== #

load_pkgs <- function(pkgs){
  #' Loads a list of packages, installing them if not already installed
  #' pkgs is a vector of package names as strings
  #' =================================================================== #
  for(pkg in pkgs){
    if(!(require(pkg, character.only=TRUE))){
      install.packages(pkg)
      library(pkg, character.only=TRUE)
    }
  }
}

slim_glm <- function(fat_glm){
  #' Strips out superfluous members of glm (or class inheriting from glm)
  #' instance fat_glm, greatly reducing memory usage. summary() and
  #' predict() functions still work.
  #' ==================================================================== #
  fat_glm$y = c()
  fat_glm$model = c()
  fat_glm$residuals = c()
  fat_glm$fitted.values = c()
  fat_glm$effects = c()
  fat_glm$qr$qr = c()  
  fat_glm$linear.predictors = c()
  fat_glm$weights = c()
  fat_glm$prior.weights = c()
  fat_glm$data = c()
  fat_glm$family$variance = c()
  fat_glm$family$dev.resids = c()
  fat_glm$family$aic = c()
  fat_glm$family$validmu = c()
  fat_glm$family$simulate = c()
  attr(fat_glm$terms,".Environment") = c()
  attr(fat_glm$formula,".Environment") = c()
  return(fat_glm)
}

load_pkgs <- function(pkgs){
  #' Loads a list of packages, installing them if not already installed
  #' pkgs is a vector of package names as strings
  #' =================================================================== #
  for(pkg in pkgs){
    if(!(require(pkg, character.only=TRUE))){
      install.packages(pkg)
      library(pkg, character.only=TRUE)
    }
  }
}

add_lags <- function(x, fields, lags = 1){
  #' takes as input a time series object (x) and returns a copy with
  #' specified lags of fields added
  #' lags may be either atomic or list/vector
  #' =================================================================
  for(field in fields){
    cols <- colnames(x)
    if(is.null(cols)) cols <- fields
    x <- merge(x, Lag(x[, field], lags))
    colnames(x) <- c(cols, paste0(field, '_lag', lags))
  }
  return(x[, sort(colnames(x))])
}

add_diffs <- function(x, fields, lags = 1, differences = 1){
  #' takes as input a time series object (x) and returns a copy with
  #' the specified differences of fields added
  #' lags argument as in diff: how many timesteps back to calculate
  #' difference on
  #' differences may be either atomic or list/vector
  #' =================================================================
  for(field in fields){
    z <- do.call(
      'merge',
      lapply(
        differences,
        function(y){
          diff(x[, field], lag = lags, differences = y)
        }
      )
    )
    cols <- colnames(x)
    if(is.null(cols)) cols <- fields
    x <- merge(x, z)
    colnames(x) <- c(cols, paste0(field, '_diff', differences))
  }
  return(x[, sort(colnames(x))])
}

load_fred_data <- function(series, new_names=NULL){
  #' loads FRED data series specified in series and renames them to
  #' new_names if given
  #' if zoo object created does not have the same number of columns as
  #' new_names' length, new_names is ignored
  #' =================================================================
  if(length(series) > 1){
    z <- lapply(
      series,
      getSymbols,
      src = 'FRED',
      auto.assign = FALSE,
      return.class = 'zoo'
    ) %>% do.call('merge', .)
  } else {
    z <- getSymbols(
      series,
      src = 'FRED',
      auto.assign = FALSE,
      return.class = 'zoo'
    )
  }
  if(length(colnames(z) == length(new_names))){
    colnames(z) <- new_names
  }
  return(z)
}

months_between <- function(date1, date2){
  return(month(date1) - month(date2) + 12 * (year(date1) - year(date2)))
}

week_number_start <- function(yr, method = 'US'){
  # returns the date of the first day of the first week of yr
  # method of counting weeks can be specified via method
  # argument; currently only US is supported
  # methods -
  #  - US - first week is week that contains Jan 1
  #  - ISO - first week is week that contains first Thursday of year
  # ==================================================================
  yr_st <- paste(yr, '01', '01', sep = '-')
  if(method == 'US'){
    return(as.Date(yr_st) - as.integer(strftime(yr_st, '%w')))
  } else {
    stop(paste(method, ' method not implemented'))
  }
}
