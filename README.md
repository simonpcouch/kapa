
<!-- README.md is generated from README.Rmd. Please edit that file -->

# kapa

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/kapa)](https://CRAN.R-project.org/package=kapa)
<!-- badges: end -->

The kapa R package enables creating
[ellmer](https://ellmer.tidyverse.org/) tools from [kapa.ai](kapa.ai)
projects. kapa.ai projects compile context from various resources and
surface that information through search.

## Installation

You can install the development version of kapa like so:

``` r
pak::pak("simonpcouch/kapa")
```

Once the package is installed, you will need a [kapa.ai API
key](https://docs.kapa.ai/api/quickstart#create-an-api-key). Set this to
the `KAPA_API_KEY` environment variable.

## Example

`kapa_search_tool()` returns an ellmer tool for the provided kapa.ai
`project`. `kapa_search_tool(project)` defaults to
`Sys.getenv("KAPA_PROJECT_ID"`)—I’ve set mine to [a
project](https://demo.kapa.ai/widget/posit) that compiles documentation
and GitHub history on a few tidyverse packages:

``` r
library(kapa)

tidy_search <- kapa_search_tool()

tidy_search
#> # <ellmer::ToolDef> Posit_kapa_search(query, num_results, include_source_names)
#> # @name: Posit_kapa_search
#> # @description: Search the Posit knowledge base with sources Corrected 
#> Responses, dplyr, ggplot2, and tidyr.
#> # @convert: TRUE
#> #
#> function (query, num_results = 10L, include_source_names = NULL) 
#> {
#>     kapa_search(query = query, project_id = project_id, num_results = num_results, 
#>         include_source_names = include_source_names)
#> }
#> <bytecode: 0x1158eb970>
#> <environment: 0x1158ea668>
```

I can add this tool to any ellmer chat object to allow the chat to
search this kapa.ai project before responding to questions. For example,
`coord_flip()` was deprecated after Claude Sonnet 4 was trained, but
using the kapa.ai search allows the model to discover that the function
was deprecated before responding to the user:

``` r
library(ellmer)

client <- chat_anthropic(
  "Use the provided tool to research your solution before responding tersely.",
  model = "claude-sonnet-4-20250514"
)
client$register_tool(tidy_search)

client$chat(
  "
Could you flip the axes in this plotting code?

ggplot(diamonds, aes(x = carat)) +
  geom_histogram() +
  scale_x_reverse()
"
)
#> ◯ [tool call] Posit_kapa_search(query = "ggplot flip axes coord_flip
#> histogram x y axis")
#> ● #> {"search_results":[{"content":"# ggplot2 > Reference\n## Cartesian …
#> To flip the axes in your plotting code, you have two main options:
#>
#> **Option 1: Using `coord_flip()` (keep your current code structure)**
#> ```r
#> ggplot(diamonds, aes(x = carat)) +
#>   geom_histogram() +
#>   coord_flip() +
#>   scale_x_reverse()
#> ```
#>
#> **Option 2: Swap the aesthetics (preferred modern approach)**
#> ```r
#> ggplot(diamonds, aes(y = carat)) +
#>   geom_histogram() +
#>   scale_y_reverse()
#> ```
#>
#> The second option is preferred because `coord_flip()` is now superseded. When
#> you map the variable to the `y` aesthetic instead of `x`, the histogram will
#> automatically be oriented horizontally, and you use `scale_y_reverse()`
#> instead of `scale_x_reverse()` to maintain the reverse scaling.
```

To start an MCP server with this tool, use
[`mcptools::mcp_server()`](https://posit-dev.github.io/mcptools/) with
`tools = list(<your_tool>)`.
