% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/search.R
\name{kapa_search_tool}
\alias{kapa_search_tool}
\title{Create an ellmer tool to search kapa.ai sources}
\usage{
kapa_search_tool(project_id = Sys.getenv("KAPA_PROJECT_ID"))
}
\arguments{
\item{project_id}{The kapa.ai project ID. Defaults to
\code{Sys.getenv("KAPA_PROJECT_ID")}.}
}
\value{
An ellmer tool for searching the specified kapa.ai project.
}
\description{
Creates an ellmer tool for searching a kapa.ai project. The tool description
is automatically generated based on the project's name and available sources.
}
\details{
You will need to set a \code{KAPA_API_KEY} before using this function. See
\url{https://docs.kapa.ai/api/quickstart#create-an-api-key} to learn more.
}
\examples{
if (!identical(Sys.getenv("KAPA_API_KEY"), "") &&
    !identical(Sys.getenv("KAPA_PROJECT_ID"), "")) {
  # Create a search tool for the default project
  search_tool <- kapa_search_tool()
}

\dontrun{
  # Create a search tool for a specific project
  search_tool <- kapa_search_tool("your-project-id")
}

if (!identical(Sys.getenv("ANTHROPIC_API_KEY"), "") &&
    exists("search_tool")) {
  # Use with ellmer
  library(ellmer)
  client <- chat_anthropic()
  client$register_tool(search_tool)
}

}
