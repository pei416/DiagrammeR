#' Add new edges with identical definitions as with a
#' selection of edges
#' @description Add edges in the same direction
#' of one or more edges available as an edge selection
#' in a graph object of class \code{dgr_graph}. New
#' graph edges have the same edge definitions as those
#' in the selection except with new edge ID values.
#' There is also the option to assign a common
#' \code{rel} grouping to the newly created edges.
#' Upon addition of the edges, the edge selection will
#' be retained for further selection or traversal
#' operations.
#'
#' Selections of edges can be performed using
#' the following \code{select_...} functions:
#' \code{select_edges()},
#' \code{select_last_edge()}, or
#' \code{select_edges_by_node_id()}.
#' Selections of edges can also be performed using
#' the following traversal functions:
#' \code{trav_out_edge()}, \code{trav_in_edge()},
#' or \code{trav_both_edge()}.
#' @param graph a graph object of class
#' \code{dgr_graph}.
#' @param rel an optional string to apply a
#' \code{rel} attribute to all newly created edges.
#' @return a graph object of class \code{dgr_graph}.
#' @examples
#' # Create an empty graph, add 2 nodes to it,
#' # and create the edge `1->2`
#' graph <-
#'   create_graph() %>%
#'   add_n_nodes(
#'     n = 2,
#'     type = "type_a",
#'     label = c("a_1", "a_2")) %>%
#'   add_edge(
#'     from = 1, to = 2, rel = "a")
#'
#' # Get the graph's edges
#' graph %>%
#'   get_edge_ids()
#' #> [1] 1
#'
#' # Select the edge and create 2 additional edges
#' # with the same definition (`1->2`) but with
#' # different `rel` values (`b` and `c`)
#' graph <-
#'   graph %>%
#'   select_edges() %>%
#'   add_forward_edges_ws(rel = "b") %>%
#'   add_forward_edges_ws(rel = "c") %>%
#'   clear_selection()
#'
#' # Get the graph's edge data frame
#' get_edge_df(graph)
#' #>   id from to rel
#' #> 1  1    1  2   a
#' #> 2  2    1  2   b
#' #> 3  3    1  2   c
#' @importFrom dplyr select
#' @export add_forward_edges_ws

add_forward_edges_ws <- function(graph,
                                 rel = NULL) {

  # Get the time of function start
  time_function_start <- Sys.time()

  # Validation: Graph object is valid
  if (graph_object_valid(graph) == FALSE) {
    stop("The graph object is not valid.")
  }

  # Validation: Graph contains edges
  if (graph_contains_edges(graph) == FALSE) {
    stop("The graph contains no edges and existing edges are required.")
  }

  # Validation: Graph object has valid edge selection
  if (graph_contains_edge_selection(graph) == FALSE) {
    stop("There is no selection of edges, so, no new edges can be added.")
  }

  # Create bindings for specific variables
  from <- to <- NULL

  # If no value(s) provided for `rel`, set to NA
  if (is.null(rel)) {
    rel <- as.character(NA)
  }

  # Get a vector of edges available in the
  # graph's selection
  edges_in_selection <-
    graph$edge_selection %>%
    dplyr::select(from, to)

  # Get the number of edges in the graph
  edges_graph_1 <- graph %>% count_edges()

  # Add new edges to the graph for every edge
  # in the graph's active selection
  for (i in 1:nrow(edges_in_selection)) {

    # Create a graph edge
    graph <-
      add_edge(
        graph = graph,
        from = edges_in_selection[i, 1],
        to = edges_in_selection[i, 2],
        rel = rel)

    # Redact the signing of the action to the log
    graph$graph_log <-
      graph$graph_log[-nrow(graph$graph_log), ]
  }

  # Get the updated number of edges in the graph
  edges_graph_2 <- graph %>% count_edges()

  # Get the number of edges added to
  # the graph
  edges_added <- edges_graph_2 - edges_graph_1

  # Update the `graph_log` df with an action
  graph$graph_log <-
    add_action_to_log(
      graph_log = graph$graph_log,
      version_id = nrow(graph$graph_log) + 1,
      function_used = "add_forward_edges_ws",
      time_modified = time_function_start,
      duration = graph_function_duration(time_function_start),
      nodes = nrow(graph$nodes_df),
      edges = nrow(graph$edges_df),
      d_e = edges_added)

  # Perform graph actions, if any are available
  if (nrow(graph$graph_actions) > 0) {
    graph <-
      graph %>%
      trigger_graph_actions()
  }

  # Write graph backup if the option is set
  if (graph$graph_info$write_backups) {
    save_graph_as_rds(graph = graph)
  }

  graph
}
