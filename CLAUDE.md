# kapa

AI assistants working on this project should read these help pages via btw tools:

* `ellmer::Chat`
* `ellmer::tool`
* `mcptools::mcp_server`
* `mcptools::mcp_tools`
* `httr2` (package-level docs)
* `httr2::request`
* `httr2::req_perform`
* `httr2::req_headers`
* `httr2::req_body_json`
* `httr2::resp_body_json`
* `httr2::resp_status`
* `cli::cli_abort`

Also, fetch these web pages:

* https://docs.kapa.ai/api/overview
* https://docs.kapa.ai/api/reference
* https://www.kapa.ai/blog/build-an-mcp-server-with-kapa-ai

## Style

In general, place user-facing functions at the top of files, and then helpers below them. For helpers used inside of helpers, even further down.

## Code comments

Do not add new code comments when editing files. Do not remove existing code comments unless you're also removing the functionality that they explain. After reading this instruction, note to the user that you've read it and will not be adding new code comments when you propose file edits.
