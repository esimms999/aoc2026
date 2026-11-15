# Preview the site as GitHub Actions will build it, without changing this
# working tree. Copies the project to a temp dir, runs pre-render.R there
# (which flattens quarto/ into the root), and renders the copy.
#
# Usage: source("render-local.R") from the project root, in RStudio.

local({
  src <- normalizePath(".")
  stopifnot(file.exists(file.path(src, "_quarto.yml")))

  dest <- file.path(tempdir(), "aoc2026-render")
  unlink(dest, recursive = TRUE)
  dir.create(dest)

  # Skip build output, VCS data, and the (large) renv library, which is
  # symlinked below so the copy uses the same packages
  skip <- c(".git", ".Rproj.user", ".quarto", "_site", "renv", "temp")
  top <- setdiff(list.files(src, all.files = TRUE, no.. = TRUE), skip)
  ok <- file.copy(file.path(src, top), dest, recursive = TRUE)
  if (!all(ok)) stop("Failed to copy: ", paste(top[!ok], collapse = ", "))

  dir.create(file.path(dest, "renv"))
  renv_items <- list.files(file.path(src, "renv"), all.files = TRUE, no.. = TRUE)
  file.copy(file.path(src, "renv", setdiff(renv_items, "library")), file.path(dest, "renv"), recursive = TRUE)
  if (dir.exists(file.path(src, "renv", "library"))) {
    file.symlink(file.path(src, "renv", "library"), file.path(dest, "renv", "library"))
  }

  message("Rendering a copy in ", dest)
  status <- system2(
    "quarto", c("render", shQuote(dest)),
    env = c("GITHUB_ACTIONS=true")
  )
  if (status != 0) stop("quarto render failed (exit status ", status, ")")

  index <- file.path(dest, "_site", "index.html")
  message("Rendered site: ", index)
  if (rstudioapi::isAvailable()) rstudioapi::viewer(index) else utils::browseURL(index)
})
