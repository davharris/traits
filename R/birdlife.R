#' Get bird habitat information from BirdLife/IUCN
#'
#' @importFrom XML readHTMLTable
#' @export
#'
#' @param id A single IUCN species ID
#'
#' @return a \code{data.frame} with level 1 and level 2 habitat classes, as well as importance
#' ratings and occurrence type (e.g. breeding or non-breeding).  The habitat classification
#' scheme is described at http://www.iucnredlist.org/technical-documents/classification-schemes/habitats-classification-scheme-ver3
#' @author David J. Harris \email{harry491@@gmail.com}
#' @examples
#' \dontrun{birdlife_habitat(22721692)}
#' @seealso \code{\link{birdlife_threats}}

birdlife_habitat = function(id){

  stopifnot(length(id) == 1)

  url = paste0(
    "http://www.birdlife.org/datazone/species/factsheet/",
    id,
    "/additional"
  )

  tables = XML::readHTMLTable(url, stringsAsFactors = FALSE)

  # Find the table that has "Habitat" as a column name
  habitat_table_number = which(
    sapply(tables, function(table){any(grepl("Habitat", colnames(table)))})
  )

  out = cbind(id, tables[[habitat_table_number]])
  out[-nrow(out), ] # Drop last row (altitude)
}

#' Get bird threat information from BirdLife/IUCN
#'
#' @importFrom XML readHTMLTable
#' @export
#'
#' @param id A single IUCN species ID
#'
#' @return a \code{data.frame} with the species ID and two levels of threat descriptions,
#' plus stresses, timing, scope, severity, and impact associated with each stressor.
#' @author David J. Harris \email{harry491@@gmail.com}
#' @examples
#' \dontrun{birdlife_threats(22721692)}
#' @export
#' @seealso \code{\link{birdlife_habitat}}
birdlife_threats = function(id){

  stopifnot(length(id) == 1)

  url = paste0(
    "http://www.birdlife.org/datazone/species/factsheet/",
    id,
    "/additional"
  )

  tables = XML::readHTMLTable(url, stringsAsFactors = FALSE)

  is_threats = sapply(
    tables,
    function(x){
      all(c("Scope", "Severity", "Impact", "Timing") %in% unlist(x))
    }
  )

  if(sum(is_threats) > 1){
    stop("Malformed input. Multiple threat tables in ID ", id)
  }

  if(sum(is_threats) == 1){
    threats = tables[is_threats][[1]]

    rownums = seq_len(nrow(threats))

    out = data.frame(
      id = id,
      threat1  = threats[rownums %% 5 == 1, 1],
      threat2  = threats[rownums %% 5 == 1, 2],
      stresses = threats[rownums %% 5 == 0, 1],
      timing   = threats[rownums %% 5 == 2, 1],
      scope    = threats[rownums %% 5 == 2, 2],
      severity = threats[rownums %% 5 == 2, 3],
      impact   = threats[rownums %% 5 == 2, 4]
    )
  }else{
    out = NULL
  }

  out
}
