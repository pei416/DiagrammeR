#' Move layout positions of a selection of nodes
#' @description With an active selection of nodes,
#' move the position in either the \code{x} or
#' \code{y} directions, or both. Nodes in the
#' selection that do not have position information
#' (i.e., \code{NA} values for the \code{x} or
#' \code{y} node attributes) will be ignored.
#' @param graph a graph object of class
#' \code{dgr_graph} that is created using
#' \code{create_graph}.
#' @param node a single-length vector containing
#' either a node ID value (integer) or a node label
#' (character) for which position information should
#' be applied.
#' @param dx a single numeric value specifying the
#' amount that selected nodes (with non-\code{NA}
#' values for the \code{x} and \code{y} attributes)
#' will be moved in the x direction. A positive
#' value will move nodes right, negative left.
#' @param dy a single numeric value specifying the
#' amount that selected nodes (with non-\code{NA}
#' values for the \code{x} and \code{y} attributes)
#' will be moved in the y direction. A positive
#' value will move nodes up, negative down.
#' @return a graph object of class \code{dgr_graph}.
#' @examples
#' # Create a simple graph with 4 nodes
#' graph <-
#'   create_graph() %>%
#'   add_node(type = "a", label = "one") %>%
#'   add_node(type = "a", label = "two") %>%
#'   add_node(type = "b", label = "three") %>%
#'   add_node(type = "b", label = "four")
#'
#' # Add position information to each of
#' # the graph's nodes
#' graph <-
#'   graph %>%
#'   set_node_position(
#'     node = 1, x = 1, y = 1) %>%
#'   set_node_position(
#'     node = 2, x = 2, y = 2) %>%
#'   set_node_position(
#'     node = 3, x = 3, y = 3) %>%
#'   set_node_position(
#'     node = 4, x = 4, y = 4)
#'
#' # Select all of the graph's nodes using the
#' # `select_nodes()` function (and only specifying
#' # the graph object)
#' graph <- select_nodes(graph)
#'
#' # Move the selected nodes (all the nodes,
#' # in this case) 5 units to the right
#' graph <-
#'   graph %>%
#'   nudge_node_positions_ws(
#'     dx = 5, dy = 0)
#'
#' # View the graph's node data frame
#' get_node_df(graph)
#' #>   id type label x y
#' #> 1  1    a   one 6 1
#' #> 2  2    a   two 7 2
#' #> 3  3    b three 8 3
#' #> 4  4    b  four 9 4
#'
#' # Now select nodes that have `type == "b"`
#' # and move them in the `y` direction 2 units
#' # (the graph still has an active selection
#' # and so it must be cleared first)
#' graph <-
#'   graph %>%
#'   clear_selection() %>%
#'   select_nodes("type", "b") %>%
#'   nudge_node_positions_ws(
#'     dx = 0, dy = 2)
#'
#' # View the graph's node data frame
#' get_node_df(graph)
#' #>   id type label x y
#' #> 1  1    a   one 6 1
#' #> 2  2    a   two 7 2
#' #> 3  3    b three 8 5
#' #> 4  4    b  four 9 6
#' @importFrom dplyr filter case_when coalesce
#' @export nudge_node_positions_ws

nudge_node_positions_ws <- function(graph,
                                    dx,
                                    dy) {

  # Bind variables to workspace
  nodes <- x <- y <- NULL

  # Get the graph's node data frame as an object; stop
  # function if this doesn't exist
  if (is.null(graph$nodes_df)) {
    stop("This graph does not contain any nodes.")
  } else {
    ndf <- graph$nodes_df
  }

  # If both the `x` and `y` attributes do not exist,
  # stop the function
  if (!("x" %in% colnames(ndf)) |
      !("y" %in% colnames(ndf))) {
    stop("There are no `x` and `y` attribute values to modify.")
  }

  # Get the current selection of nodes if a selection
  # of nodes is available; otherwise, stop function
  if (!is.null(graph$selection)) {
    if (!is.null(graph$selection$nodes)) {
      nodes <- graph$selection$nodes
    } else {
      stop("There is no active selection of nodes")
    }
  } else {
    stop("There is no active selection of nodes")
  }

  # Determine which of the nodes selected have position
  # information set (i.e., not NA)
  ndf_filtered <-
    ndf %>%
    dplyr::filter(id %in% nodes) %>%
    dplyr::filter(!is.na(x) & !is.na(y))

  # If there are nodes to move, replace the `nodes`
  # vector with those node ID values; otherwise,
  # stop function
  if (nrow(ndf_filtered) == 0) {
    stop("There are no nodes can be moved to different `x` or `y` locations.")
  } else {
    nodes <- ndf_filtered$id
  }

  # Use `case_when` statements to selectively perform
  # a vectorized `if` statement across all nodes for
  # the `x` and `y` node attribute
  x_attr_new <-
    dplyr::case_when(
      ndf$id == nodes ~ ndf$x + dx,
      TRUE ~ as.numeric(ndf$x))

  y_attr_new <-
    dplyr::case_when(
      ndf$id == nodes ~ ndf$y + dy,
      TRUE ~ as.numeric(ndf$y))

  # Replace the `x` column to the ndf with a
  # coalesced version of the column contents
  ndf$x <- dplyr::coalesce(x_attr_new, ndf$x)

  # Replace the `y` column to the ndf with a
  # coalesced version of the column contents
  ndf$y <- dplyr::coalesce(y_attr_new, ndf$y)

  # Replace the graph's node data frame with `ndf`
  graph$nodes_df <- ndf

  return(graph)
}