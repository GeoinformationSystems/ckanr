#' Get a resource.
#'
#' @export
#'
#' @param id (character) Resource identifier.
#' @template args
#' @examples \dontrun{
#' # Setup
#' ckanr_setup(url = "http://demo.ckan.org/", key = getOption("ckan_demo_key"))
#'
#' # create a package
#' (res <- package_create("yellow7"))
#'
#' # then create a resource
#' file <- system.file("examples", "actinidiaceae.csv", package = "ckanr")
#' (xx <- resource_create(package_id = res$id,
#'                        description = "my resource",
#'                        name = "bears",
#'                        upload = file,
#'                        rcurl = "http://google.com"
#' ))
#'
#' # downloads the resource
#' resource_get(xx$id)
#'
#' # process downloaded file, e.g. read as table
#' x <- resource_get(xx$id)
#' table <- read.table(textConnection(x))
#'
#' }
resource_get <- function(id, url = get_default_url(), key = get_default_key(), as = 'list', ...) {
  id <- as.ckan_resource(id, url = url)
  res <- ckan_GET(id$url, 'resource_get', list(id = id$id), key, ...)
}
