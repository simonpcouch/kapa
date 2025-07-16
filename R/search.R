#' Create an ellmer tool to search kapa.ai sources
#'
#' @description
#' Creates an ellmer tool for searching a kapa.ai project. The tool description
#' is automatically generated based on the project's name and available sources.
#'
#' @details
#' You will need to set a `KAPA_API_KEY` before using this function. See
#' <https://docs.kapa.ai/api/quickstart#create-an-api-key> to learn more.
#'
#' @param project_id The kapa.ai project ID. Defaults to
#' `Sys.getenv("KAPA_PROJECT_ID")`.
#' @return An ellmer tool for searching the specified kapa.ai project.
#' @examples
#' if (!identical(Sys.getenv("KAPA_API_KEY"), "") &&
#'     !identical(Sys.getenv("KAPA_PROJECT_ID"), "")) {
#'   # Create a search tool for the default project
#'   search_tool <- kapa_search_tool()
#' }
#'
#' \dontrun{
#'   # Create a search tool for a specific project
#'   search_tool <- kapa_search_tool("your-project-id")
#' }
#'
#' if (!identical(Sys.getenv("ANTHROPIC_API_KEY"), "") &&
#'     exists("search_tool")) {
#'   # Use with ellmer
#'   library(ellmer)
#'   client <- chat_anthropic()
#'   client$register_tool(search_tool)
#' }
#'
#' @export
kapa_search_tool <- function(project_id = Sys.getenv("KAPA_PROJECT_ID")) {
  project_details <- get_project_details(project_id)
  sources_list <- get_project_sources(project_id)

  description <- generate_tool_description(project_details, sources_list)

  create_kapa_search_tool(
    project_id = project_id,
    name = project_details$project_name,
    description = description
  )
}

create_kapa_search_tool <- function(project_id, name, description) {
  ellmer::tool(
    function(query, num_results = 10L, include_source_names = NULL) {
      kapa_search(
        query = query,
        project_id = project_id,
        num_results = num_results,
        include_source_names = include_source_names
      )
    },
    name = paste0(name, "_kapa_search"),
    description = description,
    arguments = list(
      query = ellmer::type_string("The search query"),
      num_results = ellmer::type_integer(
        "Number of results to return (default: 10)",
        required = FALSE
      ),
      include_source_names = ellmer::type_array(
        ellmer::type_string(),
        "Source types to include",
        required = FALSE
      )
    )
  )
}

kapa_search <- function(
  query,
  project_id,
  num_results,
  include_source_names,
  call = rlang::caller_env()
) {
  api_key <- kapa_api_key()

  body <- list(query = query, num_results = num_results)

  if (!is.null(include_source_names)) {
    body$include_source_names <- include_source_names
  }

  req <- httr2::request("https://api.kapa.ai")
  req <- httr2::req_url_path_append(
    req,
    "query/v1/projects",
    project_id,
    "search/"
  )
  req <- httr2::req_headers(
    req,
    `X-API-KEY` = api_key,
    `Accept` = "application/json"
  )
  req <- httr2::req_body_json(req, body)
  resp <- httr2::req_perform(req)

  if (httr2::resp_status(resp) != 200) {
    cli::cli_abort(
      "Kapa API request failed with status: {httr2::resp_status(resp)}",
      call = call
    )
  }

  httr2::resp_body_json(resp)
}

get_project_details <- function(project_id, call = rlang::caller_env()) {
  api_key <- kapa_api_key(call = call)

  req <- httr2::request("https://api.kapa.ai")
  req <- httr2::req_url_path_append(req, "org/v1/projects", project_id)
  req <- httr2::req_headers(
    req,
    `X-API-KEY` = api_key,
    `Accept` = "application/json"
  )
  resp <- httr2::req_perform(req)

  if (httr2::resp_status(resp) != 200) {
    cli::cli_abort(
      "Failed to fetch project details: {httr2::resp_status(resp)}",
      call = call
    )
  }

  httr2::resp_body_json(resp)
}

get_project_sources <- function(project_id) {
  api_key <- kapa_api_key()

  req <- httr2::request("https://api.kapa.ai")
  req <- httr2::req_url_path_append(
    req,
    "ingestion/v1/projects",
    project_id,
    "sources/"
  )
  req <- httr2::req_headers(
    req,
    `X-API-KEY` = api_key,
    `Accept` = "application/json"
  )
  resp <- httr2::req_perform(req)

  if (httr2::resp_status(resp) != 200) {
    cli::cli_abort(
      "Failed to fetch project sources: {httr2::resp_status(resp)}"
    )
  }

  httr2::resp_body_json(resp)
}

generate_tool_description <- function(project_details, sources_list) {
  project_name <- project_details$project_name

  sources <- sources_list$results %||% list()

  if (length(sources) == 0) {
    return(cli::format_inline("Search the {project_name} knowledge base."))
  }

  source_names <- vapply(
    sources,
    function(source) {
      source$name %||% source$type %||% "Unknown source"
    },
    character(1)
  )

  cli::format_inline(
    "Search the {project_name} knowledge base with sources {source_names}."
  )
}

kapa_api_key <- function(call = rlang::caller_env()) {
  api_key <- Sys.getenv("KAPA_API_KEY")

  if (api_key == "") {
    cli::cli_abort(
      "{.envvar KAPA_API_KEY} environment variable is not set.",
      call = call
    )
  }

  api_key
}
