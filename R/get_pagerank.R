#' Get the PageRank values for nodes in the graph
#' @description Get the PageRank values for
#' all nodes in the graph.
#' @param graph a graph object of class
#' \code{dgr_graph}.
#' @param directed if \code{TRUE} (the default)
#' then directed paths will be considered for
#' directed graphs. This is ignored for undirected
#' graphs.
#' @param damping the damping factor. The default
#' value is set to \code{0.85}.
#' @return a data frame with PageRank values for
#' each of the nodes.
#' @examples
#' # Create a random graph using the
#' # `add_gnm_graph()` function
#' graph <-
#'   create_graph() %>%
#'   add_gnm_graph(
#'     n = 10,
#'     m = 15,
#'     set_seed = 23)
#'
#' # Get the PageRank scores
#' # for all nodes in the graph
#' get_pagerank(graph)
#' #>    id pagerank
#' #> 1   1   0.1302
#' #> 2   2   0.1037
#' #> 3   3   0.0450
#' #> 4   4   0.0450
#' #> 5   5   0.1501
#' #> 6   6   0.0578
#' #> 7   7   0.0871
#' #> 8   8   0.1780
#' #> 9   9   0.0744
#' #> 10 10   0.1287
#'
#' # Colorize nodes according to their
#' # PageRank scores
#' graph <-
#'   graph %>%
#'   join_node_attrs(
#'     df = get_pagerank(graph = .)) %>%
#'   colorize_node_attrs(
#'     node_attr_from = pagerank,
#'     node_attr_to = fillcolor,
#'     palette = "RdYlGn")
#' @importFrom igraph page_rank
#' @export get_pagerank

get_pagerank <- function(graph,
                         directed = TRUE,
                         damping = 0.85) {

  # Validation: Graph object is valid
  if (graph_object_valid(graph) == FALSE) {
    stop("The graph object is not valid.")
  }

  # Convert the graph to an igraph object
  ig_graph <- to_igraph(graph)

  # Get the PageRank values for each of the
  # graph's nodes
  pagerank_values <-
    igraph::page_rank(
      graph = ig_graph,
      directed = directed,
      damping = damping)$vector

  # Create df with the PageRank values
  data.frame(
    id = pagerank_values %>%
      names() %>%
      as.integer(),
    pagerank = pagerank_values %>% round(4),
    stringsAsFactors = FALSE)
}
