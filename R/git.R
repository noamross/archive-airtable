## Functions modified from pkgdown for deployment

git <- function(...) {
  processx::run("git", c(...), echo_cmd = TRUE, echo = TRUE)
}

git_clone <- function(repo, dir, branch = "master", depth = "1") {
  git("clone", "--single-branch", "-b", branch, "--depth",
      depth, repo, dir)
}

git_addpush <- function(dir, commit_message, remote = "origin", branch = "master") {
  force(commit_message)
  withr::with_dir(dir, {
    git("add", "-A", ".")
    git("commit", "--allow-empty", "-m", commit_message)
    git("push", "--force", remote, paste0("HEAD:", branch))
  })
}
