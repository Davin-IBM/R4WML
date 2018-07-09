#' Get a Watson Machine Learning (WML) authentication token
#'
#' Given a Watson Machine Learning URL, username and password, return an authentication token for use in subsequent requests to WML.
#' @keywords WML authentication
#' @param token_url The WML URL to autenticate against
#' @param username The WML user name
#' @param password The WML password
#' @return Authentication token for use in subsequent requests to WML
#' @export
#' @examples
#' get_wml_auth_token()

get_wml_auth_token <- function(token_url, username, password) {
  req <- httr::GET(token_url, httr::authenticate(username, password), encoding = 'UTF-8')
  httr::stop_for_status(req, 'authenticate with WatsonML')
  json <- jsonlite::fromJSON(httr::content(req, as = 'text', type = 'application/json', encoding = 'UTF-8'))
  json$token
}

#' Get Watson Machine Learning (WML) authorization headers
#'
#' Given a Watson Machine Learning URL, username and password, return an authorization headers for use in subsequent requests to WML.
#' @keywords WML authorization
#' @param token_url The WML URL to autenticate against
#' @param username The WML user name
#' @param password The WML password
#' @return Authorization headers for use in subsequent requests to WML
#' @export
#' @examples
#' get_wml_auth_headers()

get_wml_auth_headers <- function(wml_url, username, password) {
  httr::add_headers('Authorization' = paste('Bearer', get_wml_auth_token(paste0(wml_url, '/v3/identity/token'), username, password)))
}

#' Create a Watson Machine Learning (WML) payload from an R list
#'
#' Given an R list, return a JSON payload for sending to a WML scoring endpoint
#' @keywords WML payload
#' @export
#' @examples
#' to_wml_payload()

# 

to_wml_payload <- function(df, columns = names(df)) {
  jsonlite::toJSON(
    list(
      fields = columns,
      values = {
        unname(df[,])
      }
    )
  )
}

#' Create a data frame from a Watson Machine Learning result
#'
#' Given a Watson Machine Learning result, return a data frame
#' @param wml_results JSON results from a WML scoring endpoint
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
    if(verbose) return(httr::POST(scoring_url, auth_headers, httr::content_type_json(), body = payload, encoding = 'UTF-8', httr::verbose()))
    httr::POST(scoring_url, auth_headers, httr::content_type_json(), body = payload, encoding = 'UTF-8')
  }
  httr::stop_for_status(req, 'score with WatsonML')
  jsonlite::fromJSON(httr::content(req, as = 'text', type = 'application/json', encoding = 'UTF-8'))
}
