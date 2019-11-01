#!/usr/bin/env Rscript

library(airtabler) # AIRTABLE_API_KEY must be set in environment
library(readr)
library(dplyr)
library(purrr)
library(webdriver)
library(jsonlite)
devtools::load_all()

if (inherits(try(run_phantomjs()), "try-error")) webdriver::install_phantomjs()

DATA_PATH = "data" # Where locally to store data
DATA_REPO_URL = Sys.getenv("REPO_URL") # storage repo
AT_BASE = Sys.getenv("AT_BASE") # The base we are working off of
AIRTABLE_LOGIN_EMAIL = Sys.getenv("AIRTABLE_LOGIN_EMAIL") #airtable creds.  Note that AIRTABLE_API_KEY is also needed in the environment
AIRTABLE_LOGIN_PWD = Sys.getenv("AIRTABLE_LOGIN_PWD")
GIT_USER = Sys.getenv("GIT_USER")
GIT_EMAIL = Sys.getenv("GIT_EMAIL")

git("config", "--global", "user.name", paste0("'", GIT_USER, "'"))
git("config", "--global", "user.email", paste0("'", GIT_EMAIL, "'"))

if (dir.exists(DATA_PATH)) unlink(DATA_PATH, recursive = TRUE)
git_clone(repo = REPO_URL, dir = DATA_PATH)
unlink(list.files(DATA_PATH, "\\.csv$", full.names = TRUE))

at_schema = get_airtable_schema(AT_BASE, AIRTABLE_LOGIN_EMAIL, AIRTABLE_LOGIN_PWD)
tables <- airtable_names(at_schema)

save_airtable(AT_BASE, tables, path = DATA_PATH, attachments_dir = file.path(DATA_PATH, "attachments"))
git_addpush(DATA_PATH, commit_message = paste("Auto-commit data update ", Sys.time()))


