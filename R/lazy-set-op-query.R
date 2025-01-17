#' @export
#' @rdname sql_build
lazy_set_op_query <- function(x,
                              y,
                              type,
                              all,
                              call = caller_env()) {
  check_lazy_query(x, call = call)
  check_lazy_query(y, call = call)
  check_string(type, call = call)
  check_bool(all, call = call)

  lazy_query(
    query_type = "set_op",
    x = x,
    y = y,
    type = type,
    all = all
  )
}

#' @export
print.lazy_set_op_query <- function(x, ..., con = NULL) {
  cat_line("<SQL ", toupper(x$type), ">")

  cat_line("X:")
  cat_line(indent_print(sql_build(x$x, simulate_dbi())))

  cat_line("Y:")
  cat_line(indent_print(sql_build(x$y, simulate_dbi())))
}

#' @export
op_vars.lazy_set_op_query <- function(op) {
  union(op_vars(op$x), op_vars(op$y))
}

#' @export
sql_build.lazy_set_op_query <- function(op, con, ..., use_star = TRUE) {
  # add_op_set_op() ensures that both have same variables
  set_op_query(
    sql_optimise(sql_build(op$x, con, use_star = use_star), con),
    sql_optimise(sql_build(op$y, con, use_star = use_star), con),
    type = op$type,
    all = op$all
  )
}

#' @export
#' @rdname sql_build
lazy_union_query <- function(x,
                             unions,
                             call = caller_env()) {
  check_lazy_query(x, call = call)
  # check_lazy_query(y, call = call)

  lazy_query(
    query_type = "union",
    x = x,
    unions = unions
  )
}

#' @export
print.lazy_union_query <- function(x, ..., con = NULL) {
  cat_line("<SQL ", toupper(x$type), ">")

  cat_line("X:")
  cat_line(indent_print(sql_build(x$x, simulate_dbi())))

  cat_line("Y:")
  cat_line(indent_print(sql_build(x$y, simulate_dbi())))
}

#' @export
op_vars.lazy_union_query <- function(op) {
  purrr::reduce(op$unions$table, ~ union(.x, op_vars(.y$lazy_query)), .init = op_vars(op$x))
}

#' @export
sql_build.lazy_union_query <- function(op, con, ..., use_star = TRUE) {
  # add_union() ensures that both have same variables
  unions <- list(
    table = purrr::map(
      op$unions$table,
      ~ sql_optimise(sql_build(.x, con, use_star = use_star), con)
    ),
    all = op$unions$all
  )

  union_query(
    sql_optimise(sql_build(op$x, con, use_star = use_star), con),
    unions
  )
}
