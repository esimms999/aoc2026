#!/usr/bin/env Rscript

# We want to render all of the files in the quarto/ subdirectory, but doing
# so raises issues that the current rendering process cannot address.
# As a workaround, we move everything in quarto/ to the project root and
# delete quarto/.
# This must only happen in the GitHub Actions rendering, where none of these
# changes are kept, so a local render fails rather than rearranging the repo.

if (Sys.getenv("GITHUB_ACTIONS") != "true") {
  stop("Rendering is only allowed in GitHub Actions")
}

quarto_dir <- "quarto"
root_dir <- "."

if (!dir.exists(quarto_dir)) {
  stop("quarto/ directory not found")
}

# Includes hidden files; subdirectories are moved whole, not descended into
all_files <- list.files(
  quarto_dir,
  full.names = TRUE,
  all.files = TRUE,
  no.. = TRUE
)

# On Linux, file.rename() overwrites an existing destination
moved <- file.rename(all_files, file.path(root_dir, basename(all_files)))

# Don't delete quarto/ if any move failed, or files would be lost
if (!all(moved)) {
  stop("Failed to move: ", paste(all_files[!moved], collapse = ", "))
}

unlink(quarto_dir, recursive = TRUE)

message("Moved all files from quarto/ to project root and deleted quarto/")
