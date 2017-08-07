## wml_utils.R

# Detect and install missing packages before loading them
list.of.packages <- c('jsonlite', 'httr')
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,'Package'])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, function(x){library(x, character.only = TRUE, warn.conflicts = FALSE, quietly = TRUE)})

## Given a WML url, username and password, return an authentication token for use in subsequent requests to WML
get_wml_auth_token <- function(token_url, username, password) {
  req <- httr::GET(token_url, authenticate(username, password))
  httr::stop_for_status(req, 'authenticate with WatsonML')
  json <- httr::content(req)
  json$token
}

## Given a WML url, username and password, return authentication headers for use in subsequent requests to WML
get_wml_auth_headers <- function(wml_url, username, password) {
  add_headers('Authorization' = get_auth_token(paste0(wml_url, '/v3/identity/token'), username, password))
}

## Given a data frame, return a JSON payload for sending to a WML scoring endpoint
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

## Given a WML Result, return a data frame
from_wml_payload <- function(wml_results) {
  df <- do.call(rbind, wml_results$values)
  colnames(df) <- wml_results$fields
  df
}

wml_score <- function(scoring_url, auth_headers, payload, verbose=FALSE) {
  req <- {
    if(verbose) return(httr::POST(scoring_url, auth_headers, content_type_json(), body = payload, verbose()))
    httr::POST(scoring_url, auth_headers, content_type_json(), body = payload)
  }
  httr::stop_for_status(req, 'score with WatsonML')
  fromJSON(httr::content(req, 'text'))
}
