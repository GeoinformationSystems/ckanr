#' List related items
#'
#' @export
#' @template paging
#' @template args
#' @examples \dontrun{
#' related_list()
#' related_list(as = 'json')
#' related_list(as = 'table')
#' }
related_list <- function(offset = 0, limit = 31, url = get_default_url(),
                         as = 'list', ...) {
  args <- cc(list(offset = offset, limit = limit))
  res <- ckan_GET(url, method = 'related_list', args, key = NULL, ...)
  switch(as, json = res, list = lapply(jsl(res), as.ckan_related), table = jsd(res))
}
