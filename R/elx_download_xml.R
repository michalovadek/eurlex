#' Download XML notice associated with a URL
#'
#' Downloads an XML notice of a given type associated with a Cellar resource.
#'
#' @param url A valid url as character vector of length one based on a resource identifier such as CELEX or Cellar URI.
#' @param file A character string with the name where the downloaded file is saved.
#' @param notice The type of notice requested controls what kind of metadata are returned.
#' @param language_1 The priority language in which the data will be attempted to be retrieved, in ISO 639 2-char code
#' @param language_2 If data not available in `language_1`, try `language_2`
#' @param language_3 If data not available in `language_2`, try `language_3`
#' @param mode A character string specifying the mode with which to write the file. Useful values are "w", "wb" (binary), "a" (append) and "ab".
#' @return
#' Path of downloaded file (invisibly) if server validates request (http status code has to be 200).
#' @export
#' @examples
#' \donttest{
#' elx_download_xml(url = "http://publications.europa.eu/resource/celex/32014R0001", notice = "branch")
#' }

elx_download_xml <- function(url, file = basename(url), notice = c("branch", "object"),
                             language_1 = "en", language_2 = "fr", language_3 = "de",
                             mode = "wb"){
  
  stopifnot("url must be specified" = !missing(url),
            "notice type must be specified" = !missing(notice),
            "notice type must be correctly specified" = notice %in% c("branch", "object"))
  
  language <- paste(language_1,", ",language_2,";q=0.8, ",language_3,";q=0.7", sep = "")
  
  if (stringr::str_detect(url,"celex.*[\\(|\\)|\\/]")){
    
    clx <- stringr::str_extract(url, "(?<=celex\\/).*") |> 
      stringr::str_replace_all("\\(","%28") |> 
      stringr::str_replace_all("\\)","%29") |> 
      stringr::str_replace_all("\\/","%2F")
    
    url <- paste("http://publications.europa.eu/resource/celex/",
                 clx,
                 sep = "")
    
  }
  
  accept_header <- paste('application/xml; notice=',
                         notice,
                         sep = "")
  
  # generate url with desired notice type and check validity
  head <- graceful_http(url,
                        headers = httr::add_headers('Accept-Language' = language,
                                                    'Accept' = accept_header),
                        verb = "HEAD")
  
  stopifnot("Unsuccessful http request (status code != 200" = head$status_code == 200)
  
  utils::download.file(url = head$url,
                       destfile = file,
                       mode = mode)

}