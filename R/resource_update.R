#' @title Update a resource's file attachment
#'
#'
#' @description This function will only update a resource's file attachment and
#' the metadata key "last_updated". Other metadata, such as name or description,
#' are not updated.
#'
#' The new file must exist on a local path. R objects have to be written to a
#' file, e.g. using \code{tempfile()} - see example.
#'
#' For convenience, CKAN base url and API key default to the global options,
#' which are set by \code{ckanr_setup}.
#'
#' @export
#'
#' @param id (character) Resource ID to update (required)
#' @param path (character) Local path of the file to upload (required)
#' @template key
#' @template args
#' @return The HTTP response from CKAN, formatted as list (default), table, or JSON.
#' @references
#' \url{http://docs.ckan.org/en/latest/api/index.html#ckan.logic.action.create.resource_create}
#' @examples \dontrun{
#' ckanr_setup(url = "http://demo.ckan.org/", key = getOption("ckan_demo_key"))
#'
#' # Get file
#' path <- system.file("examples", "actinidiaceae.csv", package = "ckanr")
#'
#' # Create package, then a resource within that package
#' (res <- package_create("newpackage9"))
#' (xx <- resource_create(package_id = res$id,
#'                        description = "my resource",
#'                        name = "bears",
#'                        upload = path,
#'                        rcurl = "http://google.com"
#' ))
#'
#' # Modify dataset, here lowercase strings in one column
#' dat <- read.csv(path, stringsAsFactors = FALSE)
#' dat$Family <- tolower(dat$Family)
#' newpath <- tempfile(fileext = ".csv")
#' write.csv(dat, file = newpath, row.names = FALSE)
#'
#' # Upload modified dataset
#' ## Directly from output of resource_create
#' resource_update(xx, path=newpath)
#'
#' ## or from the resource id
#' resource_update(xx$id, path=newpath)
#'
#' #######
#' # Using default settings
#' ckanr_setup(url = "http://demo.ckan.org/", key = "my-demo-ckan-org-api-key")
#' path <- system.file("examples", "actinidiaceae.csv", package = "ckanr")
#' resource_update(id="an-existing-resource-id", path = path)
#'
#' # Using an R object written to a tempfile, and implicit CKAN URL and API key
#' write.csv(data <- installed.packages(), path <- tempfile(fileext = ".csv"))
#' ckanr_setup(url = "http://demo.ckan.org/", key = "my-demo-ckan-org-api-key")
#' resource_update(id="an-existing-resource-id", path = path)
#'
#' # Testing: see ?ckanr_setup to set default test CKAN url, key, package id
#' ckanr_setup(test_url = "http://my-ckan.org/",
#'             test_key = "my-ckan-api-key",
#'             test_did = "an-existing-package-id",
#'             test_rid = "an-existing-resource-id")
#' resource_update(id = get_test_rid(),
#'                 path = system.file("examples",
#'                                    "actinidiaceae.csv",
#'                                    package = "ckanr"),
#'                 key = get_test_key(),
#'                 url = get_test_url())
#'
#' # other file formats
#' ## html
#' path <- system.file("examples", "mapbox.html", package = "ckanr")
#'
#' # Create package, then a resource within that package
#' (res <- package_create("mappkg"))
#' (xx <- resource_create(package_id = res$id,
#'                        description = "a map, yay",
#'                        name = "mapyay",
#'                        upload = path,
#'                        rcurl = "http://google.com"
#' ))
#' browseURL(xx$url)
#'
#' # Modify dataset, here lowercase strings in one column
#' dat <- readLines(path)
#' dat <- sub("-111.06", "-115.06", dat)
#' newpath <- tempfile(fileext = ".html")
#' cat(dat, file = newpath, sep = "\n")
#'
#' # Upload modified dataset
#' ## Directly from output of resource_create
#' (xxx <- resource_update(xx, path=newpath))
#' browseURL(xxx$url)
#' }
resource_update <- function(id, path, key = get_default_key(),
                            url = get_default_url(), as = 'list', ...) {
  id <- as.ckan_resource(id, url = url)
  path <- path.expand(path)
  up <- upload_file(path)
  format <- pick_type(up$type)
  body <- list(id = id$id, format = format, upload = up, last_modified = Sys.time(), url = "update")
  res <- ckan_POST(url, 'resource_update', body = body, key = key, ...)
  switch(as, json = res, list = as_ck(jsl(res), "ckan_resource"), table = jsd(res))
}

pick_type <- function(x) {
  switch(x,
         `text/html` = "html",
         `text/csv` = "csv",
         `text/plain` = "txt",
         `application/vnd.openxmlformats-officedocument.wordprocessingml.document` = "docx",
         `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet` = "xlsx",
         `application/vnd.ms-excel.sheet.macroEnabled.12` = "xlsm",
         `application/json` = "json",
         `application/vnd.geo+json` = "geojson",
         `application/pdf` = "pdf",
         `image/jpeg` = "jpeg",
         `image/png` = "png",
         `image/bmp` = "bmp"
         )
}
