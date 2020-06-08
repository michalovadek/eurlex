#' SPARQL package functions with fixed namespaces to reduce dependency load
#'

sparqlns <- c('s'='http://www.w3.org/2005/sparql-results#')
commonns <- c('xsd','<http://www.w3.org/2001/XMLSchema#>',
              'rdf','<http://www.w3.org/1999/02/22-rdf-syntax-ns#>',
              'rdfs','<http://www.w3.org/2000/01/rdf-schema#>',
              'owl','<http://www.w3.org/2002/07/owl#>',
              'skos','<http://www.w3.org/2004/02/skos/core#>',
              'dc','<http://purl.org/dc/elements/1.1/>',
              'foaf','<http://xmlns.com/foaf/0.1/>',
              'wgs84','<http://www.w3.org/2003/01/geo/wgs84_pos#>',
              'qb','<http://purl.org/linked-data/cube#>')

sparqltest <- function(...) {
  SPARQL(url='http://semanticweb.cs.vu.nl/lop/sparql/',
         query='SELECT ?et ?r ?at ?t
                WHERE {
                  ?e sem:eventType ?et .
                  ?e sem:hasActor ?a .
                  ?a sem:actorType ?at .
                  ?e sem:hasPlace ?p .
                  ?p eez:inPiracyRegion ?r .
                  ?e sem:hasTimeStamp ?t . }',
         ns=c('lop','<http://semanticweb.cs.vu.nl/poseidon/ns/instances/>',
              'eez','<http://semanticweb.cs.vu.nl/poseidon/ns/eez/>'),
         ...)
}

SPARQL <- function (url = "http://localhost/", query = "",
                    update = "", ns = NULL, param = "", extra = NULL,
                    format = "xml", curl_args = NULL, parser_args = NULL)
{
  if (!is.null(extra)) {
    extrastr <- paste("&", sapply(seq(1, length(extra)),
                                  function(i) {
                                    paste(names(extra)[i], "=", URLencode(extra[[i]]),
                                          sep = "")
                                  }), collapse = "&", sep = "")
  }
  else {
    extrastr <- ""
  }
  tf <- tempfile()
  if (query != "") {
    if (param == "") {
      param <- "query"
    }
    if (format == "xml") {
      tf <- do.call(RCurl::getURL, append(list(url = paste(url,
                                                    "?", param, "=", gsub("\\+",
                                                                          "%2B", URLencode(query, reserved = TRUE)),
                                                    extrastr, sep = ""), httpheader = c(Accept = "application/sparql-results+xml")),
                                   curl_args))
      DOM <- do.call(XML::xmlParse, append(list(tf), parser_args))
      if (length(XML::getNodeSet(DOM, "//s:result[1]",
                            namespaces = sparqlns)) == 0) {
        rm(DOM)
        df <- data.frame(c())
      }
      else {
        attrs <- unlist(XML::xpathApply(DOM, paste("//s:head/s:variable",
                                              sep = ""), namespaces = sparqlns, quote(XML::xmlGetAttr(x,
                                                                                                 "name"))))
        ns2 <- noBrackets(ns)
        res <- get_attr(attrs, DOM, ns2)
        df <- data.frame(res)
        rm(res)
        rm(DOM)
        n = names(df)
        for (r in 1:length(n)) {
          name <- n[r]
          df[name] <- as.vector(unlist(df[name]))
        }
      }
    }
    else if (format == "csv") {
      tf <- do.call(RCurl::getURL, append(list(url = paste(url,
                                                    "?", param, "=", gsub("\\+",
                                                                          "%2B", URLencode(query, reserved = TRUE)),
                                                    extrastr, sep = "")), curl_args))
      df <- do.call(SPARQL::readCSVstring, append(list(tf, blank.lines.skip = TRUE,
                                               strip.white = TRUE), parser_args))
      if (!is.null(ns))
        df <- dropNS(df, ns)
    }
    else if (format == "tsv") {
      tf <- do.call(SPARQL::getURL, append(list(url = paste(url,
                                                    "?", param, "=", gsub("\\+",
                                                                          "%2B", URLencode(query, reserved = TRUE)),
                                                    extrastr, sep = "")), curl_args))
      df <- do.call(SPARQL::readTSVstring, append(list(tf, blank.lines.skip = TRUE,
                                               strip.white = TRUE), parser_args))
      if (!is.null(ns))
        df <- dropNS(df, ns)
    }
    else {
      cat("unknown format \"", format, "\"\n\n",
          sep = "")
      return(list(results = NULL, namespaces = ns))
    }
    list(results = df, namespaces = ns)
  }
  else if (update != "") {
    if (param == "") {
      param <- "update"
    }
    extra[[param]] <- update
    do.call(RCurl::postForm, append(list(url, .params = extra),
                             curl_args))
  }
}

noBrackets <- function(ns) {
  sapply(ns,function(br_ns) {
    if(substr(br_ns,1,1)=='<')
      substr(br_ns,2,nchar(br_ns)-1)
    else
      br_ns
  })
}

substNS <- function(str0, ns) {
  regex <- paste('^', ns[2], sep="")
  gsub(regex, paste(ns[1], ":", sep=""), str0)
}

qnames <- function(str0, ns_list) {
  if(!length(ns_list))
    str0
  else
    substNS(qnames(str0, ns_list[-1:-2]), ns_list[1:2])
}

interpret_type <- function(type, literal,ns) {
  qname <- qnames(type, ns)
  if(unlist(qname) == unlist(type))
    type_uri <- paste('<', type, '>', sep="")
  else
    type_uri <- qname
  # FIXME: work out all simple types
  if(type == "http://www.w3.org/2001/XMLSchema#double" ||
     type == "http://www.w3.org/2001/XMLSchema#float" ||
     type == "http://www.w3.org/2001/XMLSchema#decimal")
    as.double(literal)
  else if(type == "http://www.w3.org/2001/XMLSchema#integer" ||
          type == "http://www.w3.org/2001/XMLSchema#int" ||
          type == "http://www.w3.org/2001/XMLSchema#long" ||
          type == "http://www.w3.org/2001/XMLSchema#short" ||
          type == "http://www.w3.org/2001/XMLSchema#byte" ||
          type == "http://www.w3.org/2001/XMLSchema#nonNegativeInteger" ||
          type == "http://www.w3.org/2001/XMLSchema#unsignedLong" ||
          type == "http://www.w3.org/2001/XMLSchema#unsignedShort" ||
          type == "http://www.w3.org/2001/XMLSchema#unsignedInt" ||
          type == "http://www.w3.org/2001/XMLSchema#unsignedByte" ||
          type == "http://www.w3.org/2001/XMLSchema#positiveInteger" ||
          type == "http://www.w3.org/2001/XMLSchema#nonPositiveInteger" ||
          type == "http://www.w3.org/2001/XMLSchema#negativeInteger")
  as.integer(literal)
  else if(type == "http://www.w3.org/2001/XMLSchema#boolean")
    as.logical(literal)
  else if(type == "http://www.w3.org/2001/XMLSchema#string" ||
          type == "http://www.w3.org/2001/XMLSchema#normalizedString")
    literal
  else if(type == "http://www.w3.org/2001/XMLSchema#dateTime")
    as.POSIXct(literal,format="%FT%T")
  else if(type == "http://www.w3.org/2001/XMLSchema#time")
    as.POSIXct(literal,format="%T")
  else if(type == "http://www.w3.org/2001/XMLSchema#date")
    as.POSIXct(literal)
  else if(type == "http://www.w3.org/2001/XMLSchema#gYearMonth")
    as.POSIXct(literal,format="%Y-%m")
  else if(type == "http://www.w3.org/2001/XMLSchema#gYear")
    as.POSIXct(literal,format="%Y")
  else if(type == "http://www.w3.org/2001/XMLSchema#gMonthDay")
    as.POSIXct(literal,format="--%m-%d")
  else if(type == "http://www.w3.org/2001/XMLSchema#gDay")
    as.POSIXct(literal,format="---%d")
  else if(type == "http://www.w3.org/2001/XMLSchema#gMonth")
    as.POSIXct(literal,format="--%m")
  else
    paste('"', literal, '"^^', type_uri, sep="")
}

dropNS <- function(df,ns) {
  data.frame(lapply(df,
                    function(c) {
                      if(is.factor(c)) {
                        c <- as.character(c)
                        c <- qnames(c,ns)
                        return(as.factor(c))
                      }
                      if (is.character(c))
                        return(qnames(c,ns))
                      return(c)
                    } ))
}

get_attr <- function (attrs, DOM, ns)
{
  rs <- XML::getNodeSet(DOM, "//s:result", namespaces = sparqlns)
  t(sapply(rs, function(r) {
    sapply(attrs, function(attr) {
      get_value(XML::getNodeSet(XML::xmlDoc(r), paste("//s:binding[@name=\"",
                                            attr, "\"]/*[1]", sep = ""), namespaces = sparqlns)[[1]],
                ns)
    }, simplify = FALSE)
  }, simplify = TRUE))
}

get_value <- function (node, ns)
{
  if (is.null(node)) {
    return(NA)
  }
  doc <- XML::xmlDoc(node)
  uri = XML::xpathSApply(doc, "/s:uri", XML::xmlValue, namespaces = sparqlns)
  if (length(uri) == 0) {
    literal = XML::xpathSApply(doc, "/s:literal", XML::xmlValue,
                          namespaces = sparqlns)
    if (length(literal) == 0) {
      bnode = XML::xpathSApply(doc, "/s:bnode", XML::xmlValue,
                          namespaces = sparqlns)
      if (length(bnode) == 0) {
        "***oops***"
      }
      else {
        paste("_:genid", bnode, sep = "")
      }
    }
    else {
      lang = XML::xpathApply(doc, "/s:literal", XML::xmlGetAttr,
                        "xml:lang", namespaces = sparqlns)
      if (is.null(lang[[1]])) {
        type = XML::xpathApply(doc, "/s:literal", XML::xmlGetAttr,
                          "datatype", namespaces = sparqlns)
        if (is.null(type[[1]])) {
          literal
        }
        else {
          interpret_type(type, literal, ns)
        }
      }
      else {
        paste("\"", literal, "\"@", lang,
              sep = "")
      }
    }
  }
  else {
    qname = qnames(uri, ns)
    if (qname == uri)
      paste("<", uri, ">", sep = "")
    else qname
  }
}
