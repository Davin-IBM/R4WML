## wml_utils.R

# Detect and install missing packages before loading them
list.of.packages <- c('jsonlite', 'httr', 'SnowballC')
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,'Package'])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, function(x){library(x, character.only = TRUE, warn.conflicts = FALSE, quietly = TRUE)})

#' Get a Watson Machine Learning (WML) authentication token
#'
#' Given a Watson Machine Learning URL, username and password, return an authentication token for use in subsequent requests to WML.
#' @keywords WML authentication
#' @export
#' @examples
#' get_wml_auth_token()

get_wml_auth_token <- function(token_url, username, password) {
  req <- httr::GET(token_url, authenticate(username, password), encoding = 'UTF-8')
  httr::stop_for_status(req, 'authenticate with WatsonML')
  json <- fromJSON(httr::content(req, as = 'text', type = 'application/json', encoding = 'UTF-8'))
  json$token
}

#' Get Watson Machine Learning (WML) authorization headers
#'
#' Given a Watson Machine Learning URL, username and password, return an authorization headers for use in subsequent requests to WML.
#' @keywords WML authorization
#' @export
#' @examples
#' get_wml_auth_headers()

get_wml_auth_headers <- function(wml_url, username, password) {
  add_headers('Authorization' = get_wml_auth_token(paste0(wml_url, '/v3/identity/token'), username, password))
}

#' Create a Watson Machine Learning payload from an R list
#'
#' Given an R list, return a JSON payload for sending to a WML scoring endpoint
#' @keywords WML payload
#' @export
#' @examples
#' to_wml_payload()

to_wml_payload <- function(df, columns = names(df)) {
  ## TODO:  There has to be a less verbose way to do this
  toJSON(
    list(
      fields = columns,
      values = {
        ret = list()
        for(i in 1:nrow(df)) {
          rec = list()
          for(j in 1:length(columns)) {
            rec[[j]] <- df[[columns[j]]][i]
          }
          ret[[i]] <- unlist(rec)
        }
        ret
      }
    )
  )
}

#' Create a data frame from a Watson Machine Learning result
#'
#' Given a Watson Machine Learning result, return a data frame
#' @keywords WML payload
#' @export
#' @examples
#' from_wml_payload()

## Given a WML Result, return a data frame
from_wml_payload <- function(wml_results) {
  df <- do.call(rbind, wml_results$values)
  colnames(df) <- wml_results$fields
  as.data.frame(df)
}

#' Use a Watson Machine Learning REST endpoint to score a payload of records
#'
#' Given a WML REST endpoint (URL) and JSON payload, score the records in the payload
#' @keywords WML scoring
#' @export
#' @examples
#' wml_score()

wml_score <- function(scoring_url, auth_headers, payload, verbose=FALSE) {
  req <- {
    if(verbose) return(httr::POST(scoring_url, auth_headers, content_type_json(), body = payload, encoding = 'UTF-8', verbose()))
    httr::POST(scoring_url, auth_headers, content_type_json(), body = payload, encoding = 'UTF-8')
  }
  httr::stop_for_status(req, 'score with WatsonML')
  fromJSON(httr::content(req, as = 'text', type = 'application/json', encoding = 'UTF-8'))
}
